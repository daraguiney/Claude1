# Security & Permission Sets Guide

## Overview
This healthcare application implements a robust, role-based security model using Salesforce Permission Sets. This approach provides flexibility, HIPAA-readiness, and principle of least privilege access.

## Permission Sets Created

### 1. Healthcare Provider
**File:** [Healthcare_Provider.permissionset-meta.xml](force-app/main/default/permissionsets/Healthcare_Provider.permissionset-meta.xml)

**Role:** Doctors, Physicians, Primary Care Providers

**Access Level:**
- ✅ **Full Access**: All patient data, care plans, vitals, medications, medical notes
- ✅ **Create/Edit/Delete**: Most clinical records
- ✅ **View All**: Can see all patients and appointments in the system
- ❌ **Limited**: Cannot create/delete providers (admin function)

**Use Cases:**
- Complete patient care management
- Clinical decision making
- Medical documentation
- Prescription management
- Care plan development

**Assign to:**
```bash
sf org assign permset --name Healthcare_Provider --target-org myOrg
```

---

### 2. Nurse Practitioner
**File:** [Nurse_Practitioner.permissionset-meta.xml](force-app/main/default/permissionsets/Nurse_Practitioner.permissionset-meta.xml)

**Role:** Nurses, Nurse Practitioners, Clinical Staff

**Access Level:**
- ✅ **Full Access**: Vital signs (create, edit, delete)
- ✅ **Create/Edit**: Care plans, appointments, medications, medical notes
- ✅ **Edit**: Patient information (but cannot create or delete patients)
- ✅ **Read Only**: Provider information
- ❌ **Cannot Delete**: Patients, appointments, care plans

**Use Cases:**
- Recording vital signs
- Updating care plans
- Medication administration tracking
- Clinical notes
- Appointment management
- Patient monitoring

**Assign to:**
```bash
sf org assign permset --name Nurse_Practitioner --target-org myOrg
```

---

### 3. Administrative Staff
**File:** [Administrative_Staff.permissionset-meta.xml](force-app/main/default/permissionsets/Administrative_Staff.permissionset-meta.xml)

**Role:** Front Desk, Schedulers, Medical Assistants

**Access Level:**
- ✅ **Full Access**: Appointments (scheduling focus)
- ✅ **Create/Edit**: Patient demographics, Provider schedules
- ✅ **Read Only**: Care plans, vitals, medications (for context)
- ❌ **No Access**: Medical notes (clinical documentation)
- ❌ **Cannot Delete**: Most clinical records

**Use Cases:**
- Appointment scheduling
- Patient registration
- Provider calendar management
- Basic patient information updates
- Insurance verification support

**Assign to:**
```bash
sf org assign permset --name Administrative_Staff --target-org myOrg
```

---

### 4. Patient Portal User
**File:** [Patient_Portal_User.permissionset-meta.xml](force-app/main/default/permissionsets/Patient_Portal_User.permissionset-meta.xml)

**Role:** Patients (Self-Service Access)

**Access Level:**
- ✅ **Read Only**: Own patient data, care plans, vitals, medications, medical notes
- ✅ **Create**: Appointment requests
- ✅ **View**: Provider information, own appointments
- ❌ **Cannot Edit**: Any clinical data
- ❌ **Cannot View**: Other patients' data

**Use Cases:**
- View personal health information
- Request appointments
- Review medications
- Access medical history
- View care plans
- Self-service portal access

**Assign to:**
```bash
sf org assign permset --name Patient_Portal_User --target-org myOrg
```

---

## Security Model Architecture

### Object-Level Security (OLS)

| Object | Healthcare Provider | Nurse Practitioner | Admin Staff | Patient Portal |
|--------|--------------------|--------------------|-------------|----------------|
| **Patient__c** | Full Access | Edit Only | Create/Edit | Read Own |
| **Care_Plan__c** | Full Access | Create/Edit | Read Only | Read Own |
| **Appointment__c** | Full Access | Create/Edit | Full Access | Read Own/Request |
| **Vital_Signs__c** | Full Access | Full Access | Read Only | Read Own |
| **Medication__c** | Full Access | Create/Edit | Read Only | Read Own |
| **Provider__c** | Edit/Read All | Read Only | Edit/Read All | Read Only |
| **Medical_Note__c** | Full Access | Create/Edit | No Access | Read Own |

### Sharing Model

**Private Sharing with Manual Sharing:**
- Objects use `Private` or `ControlledByParent` sharing models
- Access granted via Permission Sets
- Additional sharing rules can be configured for team-based access
- Master-Detail relationships inherit parent security

**Master-Detail Relationships:**
```
Patient__c (Parent)
├── Care_Plan__c (inherits Patient security)
├── Vital_Signs__c (inherits Patient security)
└── Medical_Note__c (inherits Patient security)
```

### Apex Class Security

Both Apex classes use `with sharing` to respect user-level security:

- **AppointmentController**: Enforces record-level security
- **VitalsAnalyzer**: Enforces record-level security

```apex
public with sharing class AppointmentController { }
public with sharing class VitalsAnalyzer { }
```

---

## Deployment & Setup

### 1. Deploy Permission Sets
```bash
# Deploy all metadata including permission sets
sf project deploy start --target-org myOrg

# Or deploy permission sets only
sf project deploy start --metadata PermissionSet --target-org myOrg
```

### 2. Assign Permission Sets to Users

**Via CLI:**
```bash
# List users
sf org list users --target-org myOrg

# Assign permission set
sf org assign permset --name Healthcare_Provider --target-org myOrg

# Assign to specific user
sf org assign permset --name Nurse_Practitioner --on-behalf-of user@example.com --target-org myOrg
```

**Via Salesforce UI:**
1. Setup → Users → Select User
2. Permission Set Assignments → Edit Assignments
3. Select appropriate permission set(s)
4. Save

### 3. Create Profiles (Optional)

While permission sets provide flexibility, you can also clone standard profiles:

1. Clone "Standard User" profile
2. Name it "Healthcare User"
3. Assign base permissions
4. Stack permission sets on top for role-specific access

---

## HIPAA Compliance Considerations

### Implemented Security Features

✅ **Private Sharing Model**: Ensures data is private by default
✅ **Role-Based Access**: Principle of least privilege
✅ **Audit Fields**: CreatedBy, LastModifiedBy tracked automatically
✅ **Field-Level Security**: Can be configured per field
✅ **With Sharing Apex**: Respects user permissions in code

### Additional Recommendations

#### Enable Field History Tracking
```bash
# For each object, enable field tracking
Setup → Object Manager → [Object] → Fields & Relationships → Set History Tracking
```

Track changes to sensitive fields:
- Patient demographics
- Medical conditions
- Medication changes
- Vital signs

#### Enable Login IP Ranges
```bash
Setup → Profiles → [Profile] → Login IP Ranges
```

#### Enable Multi-Factor Authentication (MFA)
```bash
Setup → Identity → Multi-Factor Authentication
```

#### Configure Session Settings
```bash
Setup → Session Settings
- Timeout after 15 minutes
- Require HttpOnly cookies
- Enable clickjack protection
```

#### Field-Level Security
Add additional FLS restrictions for sensitive data:
```bash
Setup → Object Manager → [Object] → Fields → [Field] → Set Field-Level Security
```

Recommended sensitive fields:
- Medical_Record_Number__c
- Allergies__c
- Medical notes content
- Prescribing information

---

## Testing Permission Sets

### Test User Creation

Create test users for each role:

```bash
# Create test users (in sandbox)
sf org create user --set-alias testDoctor --definition-file config/doctor-user-def.json
sf org create user --set-alias testNurse --definition-file config/nurse-user-def.json
sf org create user --set-alias testAdmin --definition-file config/admin-user-def.json
```

### Permission Validation Checklist

**Healthcare Provider:**
- [ ] Can create patients
- [ ] Can create/edit all clinical records
- [ ] Can view all appointments
- [ ] Can prescribe medications
- [ ] Can author medical notes

**Nurse Practitioner:**
- [ ] Can record vital signs
- [ ] Can update care plans
- [ ] Cannot delete patients
- [ ] Can view assigned patients only
- [ ] Can create medical notes

**Administrative Staff:**
- [ ] Can schedule appointments
- [ ] Can create patients (demographics only)
- [ ] Cannot view medical notes
- [ ] Can see appointment conflicts
- [ ] Cannot prescribe medications

**Patient Portal User:**
- [ ] Can view own data only
- [ ] Can request appointments
- [ ] Cannot edit any clinical data
- [ ] Cannot view other patients
- [ ] Can view own medications

---

## Sharing Rules (Future Enhancement)

For team-based care, configure sharing rules:

### Example: Care Team Sharing
```
Setup → Sharing Settings → Patient__c → New Sharing Rule

Rule Name: Care_Team_Access
Owned By: Provider__c.Team_Member__c
Share With: Public Group (Care Team)
Access Level: Read/Write
```

### Example: Department-Based Sharing
```
Rule Name: Cardiology_Department
Criteria: Provider__c.Specialty__c = "Cardiology"
Share With: Public Group (Cardiology Team)
Access Level: Read Only
```

---

## Monitoring & Compliance

### Setup Audit Trail
```bash
Setup → Security → View Setup Audit Trail
```

Monitor:
- Permission set assignments
- Object permission changes
- Field-level security changes
- Sharing rule modifications

### Field History Tracking
```bash
Setup → Object Manager → [Object] → Fields & Relationships → Set History Tracking
```

### Login History
```bash
Setup → Users → Login History
```

Review:
- Failed login attempts
- Login IP addresses
- Login times
- Browser/device info

---

## Quick Reference Commands

```bash
# Deploy all metadata
sf project deploy start

# Deploy permission sets only
sf project deploy start --metadata PermissionSet

# List permission sets
sf org list permsets --target-org myOrg

# Assign permission set
sf org assign permset --name Healthcare_Provider

# View user permissions
sf org display user --target-org myOrg

# Run permission set tests
sf apex test run --class-names AppointmentControllerTest,VitalsAnalyzerTest
```

---

## Support & Documentation

- **Salesforce Permission Sets**: https://help.salesforce.com/articleView?id=perm_sets_overview.htm
- **HIPAA Compliance**: https://www.hhs.gov/hipaa/for-professionals/security/index.html
- **Security Best Practices**: https://developer.salesforce.com/docs/atlas.en-us.securityImplGuide.meta

---

## Summary

The healthcare application includes **4 comprehensive permission sets** covering all user roles from clinical staff to patients. The security model implements:

- ✅ Role-based access control (RBAC)
- ✅ Private sharing model
- ✅ Master-detail security inheritance
- ✅ Apex security with `with sharing`
- ✅ HIPAA-ready architecture
- ✅ Audit trail support
- ✅ Flexible permission stacking

All permission sets are production-ready and can be deployed immediately!
