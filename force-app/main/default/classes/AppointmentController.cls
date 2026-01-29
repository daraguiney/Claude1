/**
 * Controller class for managing Appointment operations
 * Provides CRUD operations and conflict detection for appointments
 */
public with sharing class AppointmentController {

    /**
     * Get appointments for a specific patient
     */
    @AuraEnabled(cacheable=true)
    public static List<Appointment__c> getPatientAppointments(Id patientId) {
        try {
            return [
                SELECT Id, Name, Appointment_Date_Time__c, Duration_Minutes__c,
                       Type__c, Status__c, Location__c, Notes__c,
                       Provider__c, Provider__r.Name, Provider__r.Specialty__c
                FROM Appointment__c
                WHERE Patient__c = :patientId
                ORDER BY Appointment_Date_Time__c DESC
                LIMIT 100
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving appointments: ' + e.getMessage());
        }
    }

    /**
     * Get upcoming appointments for a provider
     */
    @AuraEnabled(cacheable=true)
    public static List<Appointment__c> getProviderAppointments(Id providerId, Date startDate, Date endDate) {
        try {
            Datetime startDateTime = Datetime.newInstance(startDate, Time.newInstance(0, 0, 0, 0));
            Datetime endDateTime = Datetime.newInstance(endDate, Time.newInstance(23, 59, 59, 0));

            return [
                SELECT Id, Name, Appointment_Date_Time__c, Duration_Minutes__c,
                       Type__c, Status__c, Location__c, Notes__c,
                       Patient__c, Patient__r.First_Name__c, Patient__r.Last_Name__c
                FROM Appointment__c
                WHERE Provider__c = :providerId
                AND Appointment_Date_Time__c >= :startDateTime
                AND Appointment_Date_Time__c <= :endDateTime
                ORDER BY Appointment_Date_Time__c ASC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving provider appointments: ' + e.getMessage());
        }
    }

    /**
     * Check for appointment conflicts for a specific provider
     */
    @AuraEnabled
    public static Boolean checkForConflicts(Id providerId, Datetime appointmentDateTime, Integer durationMinutes, Id excludeAppointmentId) {
        try {
            Datetime endTime = appointmentDateTime.addMinutes(durationMinutes);

            String query = 'SELECT Id FROM Appointment__c WHERE Provider__c = :providerId ';
            query += 'AND Status__c NOT IN (\'Cancelled\', \'No Show\', \'Completed\') ';
            query += 'AND ((Appointment_Date_Time__c <= :appointmentDateTime ';
            query += 'AND Appointment_Date_Time__c >= :appointmentDateTime) ';
            query += 'OR (Appointment_Date_Time__c < :endTime ';
            query += 'AND Appointment_Date_Time__c > :appointmentDateTime))';

            if (excludeAppointmentId != null) {
                query += ' AND Id != :excludeAppointmentId';
            }
            query += ' LIMIT 1';

            List<Appointment__c> conflicts = Database.query(query);
            return !conflicts.isEmpty();
        } catch (Exception e) {
            throw new AuraHandledException('Error checking conflicts: ' + e.getMessage());
        }
    }

    /**
     * Create a new appointment
     */
    @AuraEnabled
    public static Id createAppointment(Appointment__c appointment) {
        try {
            // Check for conflicts before creating
            Boolean hasConflict = checkForConflicts(
                appointment.Provider__c,
                appointment.Appointment_Date_Time__c,
                Integer.valueOf(appointment.Duration_Minutes__c),
                null
            );

            if (hasConflict) {
                throw new AuraHandledException('Time slot conflicts with existing appointment');
            }

            insert appointment;
            return appointment.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating appointment: ' + e.getMessage());
        }
    }

    /**
     * Update an existing appointment
     */
    @AuraEnabled
    public static void updateAppointment(Appointment__c appointment) {
        try {
            // Check for conflicts if date/time or provider changed
            Boolean hasConflict = checkForConflicts(
                appointment.Provider__c,
                appointment.Appointment_Date_Time__c,
                Integer.valueOf(appointment.Duration_Minutes__c),
                appointment.Id
            );

            if (hasConflict) {
                throw new AuraHandledException('Time slot conflicts with existing appointment');
            }

            update appointment;
        } catch (Exception e) {
            throw new AuraHandledException('Error updating appointment: ' + e.getMessage());
        }
    }

    /**
     * Cancel an appointment
     */
    @AuraEnabled
    public static void cancelAppointment(Id appointmentId, String cancellationReason) {
        try {
            Appointment__c apt = [SELECT Id, Status__c, Notes__c FROM Appointment__c WHERE Id = :appointmentId];
            apt.Status__c = 'Cancelled';
            apt.Notes__c = (apt.Notes__c != null ? apt.Notes__c + '\n' : '') +
                          'Cancellation Reason: ' + cancellationReason;
            update apt;
        } catch (Exception e) {
            throw new AuraHandledException('Error cancelling appointment: ' + e.getMessage());
        }
    }

    /**
     * Get appointments needing reminders (24 hours before)
     */
    public static List<Appointment__c> getAppointmentsNeedingReminders() {
        Datetime tomorrow = Datetime.now().addDays(1);
        Datetime tomorrowEnd = tomorrow.addHours(24);

        return [
            SELECT Id, Patient__c, Patient__r.Email__c, Patient__r.Phone__c,
                   Patient__r.First_Name__c, Appointment_Date_Time__c,
                   Provider__r.Name, Location__c, Type__c
            FROM Appointment__c
            WHERE Appointment_Date_Time__c >= :tomorrow
            AND Appointment_Date_Time__c < :tomorrowEnd
            AND Status__c = 'Scheduled'
        ];
    }
}
