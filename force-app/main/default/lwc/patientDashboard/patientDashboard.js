import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getPatientAppointments from '@salesforce/apex/AppointmentController.getPatientAppointments';
import getPatientVitals from '@salesforce/apex/VitalsAnalyzer.getPatientVitals';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PatientDashboard extends LightningElement {
    @api recordId; // Patient record ID
    @track appointments = [];
    @track vitals = [];
    @track isLoading = true;
    @track error;

    wiredAppointmentsResult;
    wiredVitalsResult;

    @wire(getPatientAppointments, { patientId: '$recordId' })
    wiredAppointments(result) {
        this.wiredAppointmentsResult = result;
        if (result.data) {
            this.appointments = result.data;
            this.error = undefined;
            this.checkLoadingComplete();
        } else if (result.error) {
            this.error = result.error;
            this.appointments = [];
            this.showErrorToast('Error loading appointments');
            this.checkLoadingComplete();
        }
    }

    @wire(getPatientVitals, { patientId: '$recordId', limitCount: 10 })
    wiredVitals(result) {
        this.wiredVitalsResult = result;
        if (result.data) {
            this.vitals = result.data;
            this.error = undefined;
            this.checkLoadingComplete();
        } else if (result.error) {
            this.error = result.error;
            this.vitals = [];
            this.showErrorToast('Error loading vitals');
            this.checkLoadingComplete();
        }
    }

    checkLoadingComplete() {
        // Check if both wires have completed
        if (this.wiredAppointmentsResult && this.wiredVitalsResult) {
            this.isLoading = false;
        }
    }

    get upcomingAppointments() {
        if (!this.appointments) return [];
        const now = new Date();
        return this.appointments.filter(apt =>
            new Date(apt.Appointment_Date_Time__c) > now &&
            apt.Status__c !== 'Cancelled'
        ).slice(0, 5);
    }

    get recentVitals() {
        return this.vitals ? this.vitals.slice(0, 5) : [];
    }

    get latestVital() {
        return this.vitals && this.vitals.length > 0 ? this.vitals[0] : null;
    }

    get hasUpcomingAppointments() {
        return this.upcomingAppointments.length > 0;
    }

    get hasRecentVitals() {
        return this.recentVitals.length > 0;
    }

    get hasLatestVital() {
        return this.latestVital !== null;
    }

    handleRefresh() {
        this.isLoading = true;
        Promise.all([
            refreshApex(this.wiredAppointmentsResult),
            refreshApex(this.wiredVitalsResult)
        ]).then(() => {
            this.showSuccessToast('Dashboard refreshed');
            this.isLoading = false;
        }).catch(error => {
            this.showErrorToast('Error refreshing dashboard');
            this.isLoading = false;
        });
    }

    formatDateTime(dateTimeString) {
        if (!dateTimeString) return '';
        const date = new Date(dateTimeString);
        return date.toLocaleString();
    }

    getAlertClass(alertLevel) {
        switch(alertLevel) {
            case 'Critical':
                return 'slds-text-color_error slds-text-title_bold';
            case 'Warning':
                return 'slds-text-color_warning slds-text-title_bold';
            case 'Normal':
                return 'slds-text-color_success';
            default:
                return '';
        }
    }

    showSuccessToast(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: message,
                variant: 'success'
            })
        );
    }

    showErrorToast(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error'
            })
        );
    }
}
