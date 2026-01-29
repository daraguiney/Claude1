/**
 * Test class for AppointmentController
 */
@isTest
private class AppointmentControllerTest {

    @TestSetup
    static void setupTestData() {
        // Create test patient
        Patient__c patient = new Patient__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Date_of_Birth__c = Date.newInstance(1990, 1, 1),
            Medical_Record_Number__c = 'MRN001',
            Email__c = 'john.doe@test.com',
            Phone__c = '555-0123'
        );
        insert patient;

        // Create test provider
        Provider__c provider = new Provider__c(
            Name = 'Dr. Smith',
            Specialty__c = 'Cardiology',
            License_Number__c = 'LIC001',
            Email__c = 'smith@test.com'
        );
        insert provider;

        // Create test appointments
        List<Appointment__c> appointments = new List<Appointment__c>();
        appointments.add(new Appointment__c(
            Patient__c = patient.Id,
            Provider__c = provider.Id,
            Appointment_Date_Time__c = Datetime.now().addDays(2),
            Duration_Minutes__c = 30,
            Type__c = 'Follow-Up',
            Status__c = 'Scheduled',
            Location__c = 'Room 101'
        ));
        appointments.add(new Appointment__c(
            Patient__c = patient.Id,
            Provider__c = provider.Id,
            Appointment_Date_Time__c = Datetime.now().addDays(7),
            Duration_Minutes__c = 60,
            Type__c = 'Annual Physical',
            Status__c = 'Scheduled',
            Location__c = 'Room 102'
        ));
        insert appointments;
    }

    @isTest
    static void testGetPatientAppointments() {
        Patient__c patient = [SELECT Id FROM Patient__c LIMIT 1];

        Test.startTest();
        List<Appointment__c> appointments = AppointmentController.getPatientAppointments(patient.Id);
        Test.stopTest();

        System.assertEquals(2, appointments.size(), 'Should return 2 appointments');
        System.assertNotEquals(null, appointments[0].Provider__r.Name, 'Provider name should be populated');
    }

    @isTest
    static void testGetProviderAppointments() {
        Provider__c provider = [SELECT Id FROM Provider__c LIMIT 1];
        Date startDate = Date.today();
        Date endDate = Date.today().addDays(10);

        Test.startTest();
        List<Appointment__c> appointments = AppointmentController.getProviderAppointments(
            provider.Id,
            startDate,
            endDate
        );
        Test.stopTest();

        System.assertEquals(2, appointments.size(), 'Should return 2 appointments');
    }

    @isTest
    static void testCheckForConflicts() {
        Provider__c provider = [SELECT Id FROM Provider__c LIMIT 1];
        Appointment__c existingApt = [SELECT Id, Appointment_Date_Time__c FROM Appointment__c LIMIT 1];

        Test.startTest();
        // Test conflict detection
        Boolean hasConflict = AppointmentController.checkForConflicts(
            provider.Id,
            existingApt.Appointment_Date_Time__c.addMinutes(15),
            30,
            null
        );

        // Test no conflict
        Boolean noConflict = AppointmentController.checkForConflicts(
            provider.Id,
            existingApt.Appointment_Date_Time__c.addHours(2),
            30,
            null
        );
        Test.stopTest();

        System.assertEquals(true, hasConflict, 'Should detect conflict');
        System.assertEquals(false, noConflict, 'Should not detect conflict');
    }

    @isTest
    static void testCreateAppointment() {
        Patient__c patient = [SELECT Id FROM Patient__c LIMIT 1];
        Provider__c provider = [SELECT Id FROM Provider__c LIMIT 1];

        Appointment__c newApt = new Appointment__c(
            Patient__c = patient.Id,
            Provider__c = provider.Id,
            Appointment_Date_Time__c = Datetime.now().addDays(10),
            Duration_Minutes__c = 45,
            Type__c = 'Initial Consultation',
            Status__c = 'Scheduled',
            Location__c = 'Room 201'
        );

        Test.startTest();
        Id aptId = AppointmentController.createAppointment(newApt);
        Test.stopTest();

        System.assertNotEquals(null, aptId, 'Appointment should be created');
        Appointment__c createdApt = [SELECT Id, Status__c FROM Appointment__c WHERE Id = :aptId];
        System.assertEquals('Scheduled', createdApt.Status__c, 'Status should be Scheduled');
    }

    @isTest
    static void testCreateAppointmentWithConflict() {
        Patient__c patient = [SELECT Id FROM Patient__c LIMIT 1];
        Provider__c provider = [SELECT Id FROM Provider__c LIMIT 1];
        Appointment__c existingApt = [SELECT Id, Appointment_Date_Time__c FROM Appointment__c LIMIT 1];

        Appointment__c conflictingApt = new Appointment__c(
            Patient__c = patient.Id,
            Provider__c = provider.Id,
            Appointment_Date_Time__c = existingApt.Appointment_Date_Time__c.addMinutes(10),
            Duration_Minutes__c = 30,
            Type__c = 'Follow-Up',
            Status__c = 'Scheduled'
        );

        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            AppointmentController.createAppointment(conflictingApt);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            System.assert(e.getMessage().contains('conflict'), 'Should throw conflict error');
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Should throw exception for conflict');
    }

    @isTest
    static void testUpdateAppointment() {
        Appointment__c apt = [SELECT Id, Location__c, Status__c FROM Appointment__c LIMIT 1];
        apt.Location__c = 'Room 999';

        Test.startTest();
        AppointmentController.updateAppointment(apt);
        Test.stopTest();

        Appointment__c updatedApt = [SELECT Id, Location__c FROM Appointment__c WHERE Id = :apt.Id];
        System.assertEquals('Room 999', updatedApt.Location__c, 'Location should be updated');
    }

    @isTest
    static void testCancelAppointment() {
        Appointment__c apt = [SELECT Id FROM Appointment__c LIMIT 1];

        Test.startTest();
        AppointmentController.cancelAppointment(apt.Id, 'Patient requested cancellation');
        Test.stopTest();

        Appointment__c cancelledApt = [SELECT Id, Status__c, Notes__c FROM Appointment__c WHERE Id = :apt.Id];
        System.assertEquals('Cancelled', cancelledApt.Status__c, 'Status should be Cancelled');
        System.assert(cancelledApt.Notes__c.contains('Patient requested'), 'Notes should contain reason');
    }

    @isTest
    static void testGetAppointmentsNeedingReminders() {
        // Create appointment 25 hours from now (within reminder window)
        Patient__c patient = [SELECT Id FROM Patient__c LIMIT 1];
        Provider__c provider = [SELECT Id FROM Provider__c LIMIT 1];

        Appointment__c reminderApt = new Appointment__c(
            Patient__c = patient.Id,
            Provider__c = provider.Id,
            Appointment_Date_Time__c = Datetime.now().addHours(25),
            Duration_Minutes__c = 30,
            Type__c = 'Follow-Up',
            Status__c = 'Scheduled'
        );
        insert reminderApt;

        Test.startTest();
        List<Appointment__c> reminders = AppointmentController.getAppointmentsNeedingReminders();
        Test.stopTest();

        System.assert(reminders.size() > 0, 'Should return appointments needing reminders');
    }

    @isTest
    static void testBulkAppointments() {
        Patient__c patient = [SELECT Id FROM Patient__c LIMIT 1];
        Provider__c provider = [SELECT Id FROM Provider__c LIMIT 1];

        List<Appointment__c> bulkApts = new List<Appointment__c>();
        for (Integer i = 0; i < 200; i++) {
            bulkApts.add(new Appointment__c(
                Patient__c = patient.Id,
                Provider__c = provider.Id,
                Appointment_Date_Time__c = Datetime.now().addDays(30 + i),
                Duration_Minutes__c = 30,
                Type__c = 'Follow-Up',
                Status__c = 'Scheduled'
            ));
        }

        Test.startTest();
        insert bulkApts;
        List<Appointment__c> retrieved = AppointmentController.getPatientAppointments(patient.Id);
        Test.stopTest();

        System.assert(retrieved.size() > 0, 'Should handle bulk operations');
    }
}
