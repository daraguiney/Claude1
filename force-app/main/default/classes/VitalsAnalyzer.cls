/**
 * Analyzer class for patient vital signs
 * Determines alert levels and calculates trends
 */
public with sharing class VitalsAnalyzer {

    // Normal ranges for vital signs
    private static final Integer NORMAL_BP_SYSTOLIC_MIN = 90;
    private static final Integer NORMAL_BP_SYSTOLIC_MAX = 120;
    private static final Integer NORMAL_BP_DIASTOLIC_MIN = 60;
    private static final Integer NORMAL_BP_DIASTOLIC_MAX = 80;
    private static final Integer NORMAL_HEART_RATE_MIN = 60;
    private static final Integer NORMAL_HEART_RATE_MAX = 100;
    private static final Decimal NORMAL_TEMP_MIN = 97.0;
    private static final Decimal NORMAL_TEMP_MAX = 99.0;
    private static final Integer NORMAL_O2_SAT_MIN = 95;

    /**
     * Analyze vital signs and set alert level
     */
    public static String analyzeVitalSigns(Vital_Signs__c vitals) {
        List<String> warnings = new List<String>();
        List<String> critical = new List<String>();

        // Check Blood Pressure
        if (vitals.Blood_Pressure_Systolic__c != null) {
            if (vitals.Blood_Pressure_Systolic__c >= 180 || vitals.Blood_Pressure_Diastolic__c >= 120) {
                critical.add('Hypertensive crisis');
            } else if (vitals.Blood_Pressure_Systolic__c >= 140 || vitals.Blood_Pressure_Diastolic__c >= 90) {
                warnings.add('High blood pressure');
            } else if (vitals.Blood_Pressure_Systolic__c < 90 || vitals.Blood_Pressure_Diastolic__c < 60) {
                warnings.add('Low blood pressure');
            }
        }

        // Check Heart Rate
        if (vitals.Heart_Rate__c != null) {
            if (vitals.Heart_Rate__c > 120 || vitals.Heart_Rate__c < 40) {
                critical.add('Abnormal heart rate');
            } else if (vitals.Heart_Rate__c > 100 || vitals.Heart_Rate__c < 60) {
                warnings.add('Heart rate outside normal range');
            }
        }

        // Check Temperature
        if (vitals.Temperature__c != null) {
            if (vitals.Temperature__c >= 103.0 || vitals.Temperature__c < 95.0) {
                critical.add('Critical temperature');
            } else if (vitals.Temperature__c >= 100.4 || vitals.Temperature__c < 97.0) {
                warnings.add('Abnormal temperature');
            }
        }

        // Check Oxygen Saturation
        if (vitals.Oxygen_Saturation__c != null) {
            if (vitals.Oxygen_Saturation__c < 90) {
                critical.add('Low oxygen saturation');
            } else if (vitals.Oxygen_Saturation__c < 95) {
                warnings.add('Oxygen saturation below normal');
            }
        }

        // Determine alert level
        if (!critical.isEmpty()) {
            return 'Critical';
        } else if (!warnings.isEmpty()) {
            return 'Warning';
        } else {
            return 'Normal';
        }
    }

    /**
     * Get vital signs for a patient
     */
    @AuraEnabled(cacheable=true)
    public static List<Vital_Signs__c> getPatientVitals(Id patientId, Integer limitCount) {
        try {
            return [
                SELECT Id, Name, Recorded_Date_Time__c, Blood_Pressure_Systolic__c,
                       Blood_Pressure_Diastolic__c, Heart_Rate__c, Temperature__c,
                       Weight__c, Oxygen_Saturation__c, Alert_Level__c
                FROM Vital_Signs__c
                WHERE Patient__c = :patientId
                ORDER BY Recorded_Date_Time__c DESC
                LIMIT :limitCount
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving vitals: ' + e.getMessage());
        }
    }

    /**
     * Get vital sign trend data for charting
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, List<Decimal>> getVitalsTrend(Id patientId, Integer days) {
        try {
            Datetime startDate = Datetime.now().addDays(-days);
            List<Vital_Signs__c> vitals = [
                SELECT Recorded_Date_Time__c, Blood_Pressure_Systolic__c,
                       Blood_Pressure_Diastolic__c, Heart_Rate__c,
                       Temperature__c, Weight__c, Oxygen_Saturation__c
                FROM Vital_Signs__c
                WHERE Patient__c = :patientId
                AND Recorded_Date_Time__c >= :startDate
                ORDER BY Recorded_Date_Time__c ASC
            ];

            Map<String, List<Decimal>> trendData = new Map<String, List<Decimal>>{
                'systolic' => new List<Decimal>(),
                'diastolic' => new List<Decimal>(),
                'heartRate' => new List<Decimal>(),
                'temperature' => new List<Decimal>(),
                'weight' => new List<Decimal>(),
                'oxygenSat' => new List<Decimal>()
            };

            for (Vital_Signs__c vital : vitals) {
                if (vital.Blood_Pressure_Systolic__c != null) {
                    trendData.get('systolic').add(vital.Blood_Pressure_Systolic__c);
                }
                if (vital.Blood_Pressure_Diastolic__c != null) {
                    trendData.get('diastolic').add(vital.Blood_Pressure_Diastolic__c);
                }
                if (vital.Heart_Rate__c != null) {
                    trendData.get('heartRate').add(vital.Heart_Rate__c);
                }
                if (vital.Temperature__c != null) {
                    trendData.get('temperature').add(vital.Temperature__c);
                }
                if (vital.Weight__c != null) {
                    trendData.get('weight').add(vital.Weight__c);
                }
                if (vital.Oxygen_Saturation__c != null) {
                    trendData.get('oxygenSat').add(vital.Oxygen_Saturation__c);
                }
            }

            return trendData;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving trend data: ' + e.getMessage());
        }
    }

    /**
     * Record new vital signs
     */
    @AuraEnabled
    public static Id recordVitalSigns(Vital_Signs__c vitals) {
        try {
            // Analyze and set alert level
            vitals.Alert_Level__c = analyzeVitalSigns(vitals);
            insert vitals;
            return vitals.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error recording vitals: ' + e.getMessage());
        }
    }

    /**
     * Get critical vitals that need attention
     */
    @AuraEnabled(cacheable=true)
    public static List<Vital_Signs__c> getCriticalVitals() {
        try {
            return [
                SELECT Id, Name, Patient__c, Patient__r.First_Name__c,
                       Patient__r.Last_Name__c, Recorded_Date_Time__c,
                       Blood_Pressure_Systolic__c, Blood_Pressure_Diastolic__c,
                       Heart_Rate__c, Temperature__c, Oxygen_Saturation__c,
                       Alert_Level__c
                FROM Vital_Signs__c
                WHERE Alert_Level__c = 'Critical'
                AND Recorded_Date_Time__c = LAST_N_DAYS:7
                ORDER BY Recorded_Date_Time__c DESC
                LIMIT 50
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving critical vitals: ' + e.getMessage());
        }
    }

    /**
     * Calculate average vitals for a patient over a period
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Decimal> getAverageVitals(Id patientId, Integer days) {
        try {
            Datetime startDate = Datetime.now().addDays(-days);

            List<AggregateResult> results = [
                SELECT AVG(Blood_Pressure_Systolic__c) avgSystolic,
                       AVG(Blood_Pressure_Diastolic__c) avgDiastolic,
                       AVG(Heart_Rate__c) avgHeartRate,
                       AVG(Temperature__c) avgTemp,
                       AVG(Weight__c) avgWeight,
                       AVG(Oxygen_Saturation__c) avgO2Sat
                FROM Vital_Signs__c
                WHERE Patient__c = :patientId
                AND Recorded_Date_Time__c >= :startDate
            ];

            Map<String, Decimal> averages = new Map<String, Decimal>();
            if (!results.isEmpty() && results[0].get('avgSystolic') != null) {
                averages.put('systolic', (Decimal)results[0].get('avgSystolic'));
                averages.put('diastolic', (Decimal)results[0].get('avgDiastolic'));
                averages.put('heartRate', (Decimal)results[0].get('avgHeartRate'));
                averages.put('temperature', (Decimal)results[0].get('avgTemp'));
                averages.put('weight', (Decimal)results[0].get('avgWeight'));
                averages.put('oxygenSat', (Decimal)results[0].get('avgO2Sat'));
            }

            return averages;
        } catch (Exception e) {
            throw new AuraHandledException('Error calculating averages: ' + e.getMessage());
        }
    }
}
