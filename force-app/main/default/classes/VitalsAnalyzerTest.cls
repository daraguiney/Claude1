/**
 * Test class for VitalsAnalyzer
 */
@isTest
private class VitalsAnalyzerTest {

    @TestSetup
    static void setupTestData() {
        // Create test patient
        Patient__c patient = new Patient__c(
            First_Name__c = 'Jane',
            Last_Name__c = 'Smith',
            Date_of_Birth__c = Date.newInstance(1985, 5, 15),
            Medical_Record_Number__c = 'MRN002'
        );
        insert patient;

        // Create vital signs records with varying alert levels
        List<Vital_Signs__c> vitals = new List<Vital_Signs__c>();

        // Normal vitals
        vitals.add(new Vital_Signs__c(
            Patient__c = patient.Id,
            Recorded_Date_Time__c = Datetime.now().addDays(-1),
            Blood_Pressure_Systolic__c = 110,
            Blood_Pressure_Diastolic__c = 70,
            Heart_Rate__c = 75,
            Temperature__c = 98.6,
            Weight__c = 150,
            Oxygen_Saturation__c = 98,
            Alert_Level__c = 'Normal'
        ));

        // Warning level vitals
        vitals.add(new Vital_Signs__c(
            Patient__c = patient.Id,
            Recorded_Date_Time__c = Datetime.now().addHours(-12),
            Blood_Pressure_Systolic__c = 145,
            Blood_Pressure_Diastolic__c = 92,
            Heart_Rate__c = 105,
            Temperature__c = 100.8,
            Weight__c = 152,
            Oxygen_Saturation__c = 93,
            Alert_Level__c = 'Warning'
        ));

        // Critical vitals
        vitals.add(new Vital_Signs__c(
            Patient__c = patient.Id,
            Recorded_Date_Time__c = Datetime.now().addHours(-2),
            Blood_Pressure_Systolic__c = 185,
            Blood_Pressure_Diastolic__c = 125,
            Heart_Rate__c = 125,
            Temperature__c = 103.5,
            Weight__c = 151,
            Oxygen_Saturation__c = 88,
            Alert_Level__c = 'Critical'
        ));

        insert vitals;
    }

    @isTest
    static void testAnalyzeNormalVitals() {
        Vital_Signs__c normalVitals = new Vital_Signs__c(
            Blood_Pressure_Systolic__c = 110,
            Blood_Pressure_Diastolic__c = 70,
            Heart_Rate__c = 75,
            Temperature__c = 98.6,
            Oxygen_Saturation__c = 98
        );

        Test.startTest();
        String alertLevel = VitalsAnalyzer.analyzeVitalSigns(normalVitals);
        Test.stopTest();

        System.assertEquals('Normal', alertLevel, 'Should be normal vitals');
    }

    @isTest
    static void testAnalyzeWarningVitals() {
        Vital_Signs__c warningVitals = new Vital_Signs__c(
            Blood_Pressure_Systolic__c = 145,
            Blood_Pressure_Diastolic__c = 92,
            Heart_Rate__c = 105,
            Temperature__c = 100.8,
            Oxygen_Saturation__c = 93
        );

        Test.startTest();
        String alertLevel = VitalsAnalyzer.analyzeVitalSigns(warningVitals);
        Test.stopTest();

        System.assertEquals('Warning', alertLevel, 'Should be warning level');
    }

    @isTest
    static void testAnalyzeCriticalVitals() {
        Vital_Signs__c criticalVitals = new Vital_Signs__c(
            Blood_Pressure_Systolic__c = 185,
            Blood_Pressure_Diastolic__c = 125,
            Heart_Rate__c = 125,
            Temperature__c = 103.5,
            Oxygen_Saturation__c = 88
        );

        Test.startTest();
        String alertLevel = VitalsAnalyzer.analyzeVitalSigns(criticalVitals);
        Test.stopTest();

        System.assertEquals('Critical', alertLevel, 'Should be critical level');
    }

    @isTest
    static void testGetPatientVitals() {
        Patient__c patient = [SELECT Id FROM Patient__c LIMIT 1];

        Test.startTest();
        List<Vital_Signs__c> vitals = VitalsAnalyzer.getPatientVitals(patient.Id, 10);
        Test.stopTest();

        System.assertEquals(3, vitals.size(), 'Should return 3 vital signs records');
        System.assertNotEquals(null, vitals[0].Alert_Level__c, 'Alert level should be set');
    }

    @isTest
    static void testGetVitalsTrend() {
        Patient__c patient = [SELECT Id FROM Patient__c LIMIT 1];

        Test.startTest();
        Map<String, List<Decimal>> trends = VitalsAnalyzer.getVitalsTrend(patient.Id, 7);
        Test.stopTest();

        System.assertNotEquals(null, trends, 'Should return trend data');
        System.assert(trends.containsKey('systolic'), 'Should contain systolic data');
        System.assert(trends.get('systolic').size() > 0, 'Should have systolic values');
    }

    @isTest
    static void testRecordVitalSigns() {
        Patient__c patient = [SELECT Id FROM Patient__c LIMIT 1];

        Vital_Signs__c newVitals = new Vital_Signs__c(
            Patient__c = patient.Id,
            Recorded_Date_Time__c = Datetime.now(),
            Blood_Pressure_Systolic__c = 120,
            Blood_Pressure_Diastolic__c = 80,
            Heart_Rate__c = 80,
            Temperature__c = 98.6,
            Weight__c = 155,
            Oxygen_Saturation__c = 97
        );

        Test.startTest();
        Id vitalId = VitalsAnalyzer.recordVitalSigns(newVitals);
        Test.stopTest();

        System.assertNotEquals(null, vitalId, 'Vital signs should be recorded');
        Vital_Signs__c recorded = [SELECT Id, Alert_Level__c FROM Vital_Signs__c WHERE Id = :vitalId];
        System.assertNotEquals(null, recorded.Alert_Level__c, 'Alert level should be set');
    }

    @isTest
    static void testGetCriticalVitals() {
        Test.startTest();
        List<Vital_Signs__c> criticalVitals = VitalsAnalyzer.getCriticalVitals();
        Test.stopTest();

        System.assert(criticalVitals.size() > 0, 'Should return critical vitals');
        for (Vital_Signs__c vital : criticalVitals) {
            System.assertEquals('Critical', vital.Alert_Level__c, 'All should be critical');
        }
    }

    @isTest
    static void testGetAverageVitals() {
        Patient__c patient = [SELECT Id FROM Patient__c LIMIT 1];

        Test.startTest();
        Map<String, Decimal> averages = VitalsAnalyzer.getAverageVitals(patient.Id, 7);
        Test.stopTest();

        System.assertNotEquals(null, averages, 'Should return average data');
        if (averages.containsKey('systolic')) {
            System.assert(averages.get('systolic') > 0, 'Average systolic should be greater than 0');
        }
    }

    @isTest
    static void testBulkVitalsRecording() {
        Patient__c patient = [SELECT Id FROM Patient__c LIMIT 1];

        List<Vital_Signs__c> bulkVitals = new List<Vital_Signs__c>();
        for (Integer i = 0; i < 200; i++) {
            bulkVitals.add(new Vital_Signs__c(
                Patient__c = patient.Id,
                Recorded_Date_Time__c = Datetime.now().addHours(-i),
                Blood_Pressure_Systolic__c = 110 + Math.mod(i, 20),
                Blood_Pressure_Diastolic__c = 70 + Math.mod(i, 10),
                Heart_Rate__c = 70 + Math.mod(i, 15),
                Temperature__c = 98.0 + Math.mod(i, 2),
                Weight__c = 150,
                Oxygen_Saturation__c = 95 + Math.mod(i, 4),
                Alert_Level__c = 'Normal'
            ));
        }

        Test.startTest();
        insert bulkVitals;
        List<Vital_Signs__c> retrieved = VitalsAnalyzer.getPatientVitals(patient.Id, 100);
        Test.stopTest();

        System.assert(retrieved.size() > 0, 'Should handle bulk operations');
    }

    @isTest
    static void testLowBloodPressureWarning() {
        Vital_Signs__c lowBP = new Vital_Signs__c(
            Blood_Pressure_Systolic__c = 85,
            Blood_Pressure_Diastolic__c = 55,
            Heart_Rate__c = 75,
            Temperature__c = 98.6,
            Oxygen_Saturation__c = 98
        );

        Test.startTest();
        String alertLevel = VitalsAnalyzer.analyzeVitalSigns(lowBP);
        Test.stopTest();

        System.assertEquals('Warning', alertLevel, 'Should detect low blood pressure');
    }

    @isTest
    static void testCriticalHeartRate() {
        Vital_Signs__c criticalHR = new Vital_Signs__c(
            Blood_Pressure_Systolic__c = 120,
            Blood_Pressure_Diastolic__c = 80,
            Heart_Rate__c = 35,
            Temperature__c = 98.6,
            Oxygen_Saturation__c = 98
        );

        Test.startTest();
        String alertLevel = VitalsAnalyzer.analyzeVitalSigns(criticalHR);
        Test.stopTest();

        System.assertEquals('Critical', alertLevel, 'Should detect critical heart rate');
    }
}
