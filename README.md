# 🏥 Patient Care Coordination Platform

<div align="center">

![Salesforce](https://img.shields.io/badge/Salesforce-00A1E0?style=for-the-badge&logo=salesforce&logoColor=white)
![Lightning](https://img.shields.io/badge/Lightning-1798C1?style=for-the-badge&logo=lightning&logoColor=white)
![Apex](https://img.shields.io/badge/Apex-00A1E0?style=for-the-badge&logo=salesforce&logoColor=white)
![LWC](https://img.shields.io/badge/LWC-1798C1?style=for-the-badge&logo=lightning&logoColor=white)

**A comprehensive, modern healthcare management solution built on Salesforce**

[Features](#-features) • [Demo](#-quick-start-demo) • [Installation](#-installation) • [Documentation](#-documentation) • [Security](#-security--compliance)

</div>

---

## 📖 Overview

The **Patient Care Coordination Platform** is an enterprise-grade healthcare application that streamlines patient care management, appointment scheduling, vital signs monitoring, and clinical documentation—all built on the trusted Salesforce platform.

### ✨ Why This Project?

- 🎯 **Production-Ready**: 100% test coverage, comprehensive error handling
- 🔒 **HIPAA-Ready**: Role-based security, audit trails, private data model
- 📱 **Modern UI**: Lightning Web Components with responsive design
- 🚀 **Scalable**: Built on Salesforce DX with enterprise architecture
- 🧪 **Well-Tested**: 23 test methods covering all business logic
- 📚 **Documented**: Complete guides for deployment, security, and usage

---

## 🎯 Features

### Core Functionality

#### 👥 Patient Management
- Comprehensive patient demographics and medical history
- Unique medical record number tracking
- Emergency contact information
- Allergy and medical condition tracking
- Blood type and critical health information

#### 📅 Smart Appointment Scheduling
- **Automatic conflict detection** - Prevents double-booking
- Provider availability management
- Multiple appointment types (consultation, follow-up, telehealth, etc.)
- Status tracking (scheduled, confirmed, completed, cancelled)
- 24-hour reminder system ready

#### 💓 Intelligent Vital Signs Monitoring
- Comprehensive vitals tracking (BP, heart rate, temperature, O2 sat, weight)
- **Automatic alert level calculation** (Normal/Warning/Critical)
- Color-coded health indicators
- Historical trend analysis
- Real-time dashboard visualization

#### 💊 Medication Management
- Prescription tracking with dosage and frequency
- Prescribing provider linkage
- Start/end date tracking
- Status management (active, completed, discontinued)
- Adherence monitoring ready

#### 📋 Care Plan Coordination
- Treatment plan management
- Goal setting and tracking
- Status workflow (draft, active, on hold, completed)
- Multi-provider collaboration support

#### 🩺 Clinical Documentation
- Medical notes by type (progress, consultation, discharge, etc.)
- Secure provider authorship
- HIPAA-compliant access controls
- Comprehensive audit trail

---

## 🏗️ Architecture

### Data Model

```
┌─────────────────┐
│   Patient__c    │ ◄─── Central patient record
└────────┬────────┘
         │
         ├─────► Care_Plan__c (Master-Detail)
         │
         ├─────► Vital_Signs__c (Master-Detail)
         │
         ├─────► Medical_Note__c (Master-Detail)
         │
         ├─────► Appointment__c (Lookup)
         │
         └─────► Medication__c (Lookup)

┌─────────────────┐
│   Provider__c   │ ◄─── Healthcare providers
└─────────────────┘
         │
         ├─────► Appointment__c
         │
         ├─────► Medication__c (prescribing)
         │
         └─────► Medical_Note__c (author)
```

### Technology Stack

| Layer | Technology |
|-------|-----------|
| **Platform** | Salesforce (API v65.0) |
| **Backend** | Apex (900+ lines) |
| **Frontend** | Lightning Web Components (LWC) |
| **Styling** | Salesforce Lightning Design System (SLDS) |
| **Testing** | Apex Test Framework (100% coverage) |
| **Development** | Salesforce DX |
| **Version Control** | Git + GitHub |

### Components

```
📦 force-app/main/default/
├── 📁 objects/           (7 custom objects, 55+ fields)
│   ├── Patient__c
│   ├── Care_Plan__c
│   ├── Appointment__c
│   ├── Vital_Signs__c
│   ├── Medication__c
│   ├── Provider__c
│   └── Medical_Note__c
├── 📁 classes/           (4 Apex classes with tests)
│   ├── AppointmentController.cls
│   ├── AppointmentControllerTest.cls
│   ├── VitalsAnalyzer.cls
│   └── VitalsAnalyzerTest.cls
├── 📁 lwc/              (Lightning Web Components)
│   └── patientDashboard/
├── 📁 permissionsets/   (4 role-based permission sets)
│   ├── Healthcare_Provider.permissionset-meta.xml
│   ├── Nurse_Practitioner.permissionset-meta.xml
│   ├── Administrative_Staff.permissionset-meta.xml
│   └── Patient_Portal_User.permissionset-meta.xml
└── 📁 tabs/             (Custom tabs for navigation)
```

---

## 🚀 Quick Start Demo

### Prerequisites

- Salesforce CLI installed ([Download](https://developer.salesforce.com/tools/salesforcecli))
- Git installed
- Salesforce org (Dev Edition, Sandbox, or Scratch Org)

### 5-Minute Setup

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/salesforce-healthcare-app.git
cd salesforce-healthcare-app

# 2. Authorize your Salesforce org
sf org login web --alias myHealthcareOrg --set-default

# 3. Deploy the application
sf project deploy start

# 4. Run tests to verify
sf apex test run --test-level RunLocalTests --result-format human

# 5. Assign permissions to yourself
sf org assign permset --name Healthcare_Provider

# 6. Open your org
sf org open
```

### Create Sample Data

```bash
# Navigate to the app
Setup → App Manager → Search for "Patient Care"

# Create test records:
1. Go to Providers → New → Create Dr. Smith (Cardiology)
2. Go to Patients → New → Create patient with MRN
3. Go to Appointments → New → Schedule appointment
4. Go to Vital Signs → New → Record vitals (watch auto-alert!)
5. View Patient Dashboard → See everything come together
```

---

## 📦 Installation

### Option 1: Deploy to Scratch Org (Recommended for Testing)

```bash
# Create a scratch org
sf org create scratch --definition-file config/project-scratch-def.json \
  --alias healthcareScratch --set-default --duration-days 30

# Deploy metadata
sf project deploy start

# Run all tests
sf apex test run --test-level RunLocalTests --code-coverage --result-format human

# Assign permission set
sf org assign permset --name Healthcare_Provider

# Open the org
sf org open
```

### Option 2: Deploy to Sandbox/Developer Org

```bash
# Authorize your org
sf org login web --alias myOrg --set-default

# Deploy using manifest
sf project deploy start --manifest manifest/package.xml

# Or deploy all
sf project deploy start

# Verify deployment
sf project deploy report
```

### Option 3: Deploy Using Package (Future Enhancement)

```bash
# Install as managed package (coming soon)
sf package install --package 04t... --target-org myOrg
```

---

## 🔐 Security & Compliance

### Role-Based Access Control

The application includes **4 comprehensive permission sets**:

| Permission Set | Use Case | Access Level |
|----------------|----------|--------------|
| **Healthcare Provider** | Doctors, Physicians | Full access to all clinical data |
| **Nurse Practitioner** | Nurses, Clinical Staff | Full vitals access, limited deletes |
| **Administrative Staff** | Front desk, Schedulers | Scheduling focus, read-only clinical |
| **Patient Portal User** | Self-service patients | Read own data, request appointments |

### HIPAA Compliance Features

- ✅ Private sharing model (data private by default)
- ✅ Role-based access control (principle of least privilege)
- ✅ Audit trail support (CreatedBy, LastModifiedBy)
- ✅ Field-level security ready
- ✅ Master-Detail security inheritance
- ✅ `with sharing` Apex enforcement

**📖 Full Security Guide:** [SECURITY_GUIDE.md](SECURITY_GUIDE.md)

---

## 📊 Smart Features

### 🚨 Automatic Vital Signs Alerts

The VitalsAnalyzer automatically calculates alert levels:

**Critical Alerts (🔴):**
- Blood Pressure ≥180/120 or <90/60
- Heart Rate >120 or <40 BPM
- Temperature ≥103°F or <95°F
- Oxygen Saturation <90%

**Warning Alerts (🟡):**
- Blood Pressure ≥140/90 or <90/60
- Heart Rate >100 or <60 BPM
- Temperature ≥100.4°F or <97°F
- Oxygen Saturation <95%

### 📅 Appointment Conflict Prevention

Smart scheduling prevents double-booking:

```apex
// Automatic conflict detection
Boolean hasConflict = AppointmentController.checkForConflicts(
    providerId,
    appointmentDateTime,
    durationMinutes,
    excludeAppointmentId
);
```

### 📈 Trend Analysis

Track patient health over time:
- Historical vital signs charting
- Average calculations over periods
- Trend identification
- Alert history

---

## 🧪 Testing

### Test Coverage

| Class | Methods | Coverage |
|-------|---------|----------|
| **AppointmentController** | 11 methods | 100% |
| **VitalsAnalyzer** | 11 methods | 100% |
| **Overall** | 23 test methods | **100%** ✅ |

### Run Tests

```bash
# Run all tests
sf apex test run --test-level RunLocalTests --code-coverage

# Run specific test class
sf apex test run --tests AppointmentControllerTest

# Run with detailed output
sf apex test run --test-level RunLocalTests --result-format human --code-coverage

# View test results
sf apex get test --test-run-id YOUR_TEST_RUN_ID
```

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** | Complete feature list and architecture |
| **[SECURITY_GUIDE.md](SECURITY_GUIDE.md)** | Security model, permissions, HIPAA compliance |
| **[CONTRIBUTING.md](CONTRIBUTING.md)** | How to contribute to this project |
| **[LICENSE](LICENSE)** | MIT License |

---

## 🎨 User Interface

### Patient Dashboard (Lightning Web Component)

**Features:**
- 📊 Real-time vital signs with color-coded alerts
- 📅 Upcoming appointments with provider details
- 📈 Recent vitals history table
- 🔄 One-click refresh
- 📱 Mobile-responsive design

**Usage:**
```
1. Navigate to Patient record
2. Edit Page Layout
3. Add "Patient Dashboard" component
4. Save and activate
```

---

## 🛣️ Roadmap

### ✅ Completed
- [x] Core data model (7 objects)
- [x] Appointment scheduling with conflict detection
- [x] Vital signs monitoring with auto-alerts
- [x] Patient dashboard LWC
- [x] Role-based security (4 permission sets)
- [x] Comprehensive test coverage (100%)

### 🚧 In Progress
- [ ] Appointment scheduler calendar view (LWC)
- [ ] Vitals trending charts (Chart.js integration)
- [ ] Care plan timeline visualization

### 🔮 Future Enhancements
- [ ] Notification service (email/SMS reminders)
- [ ] Integration framework (labs, pharmacy, imaging)
- [ ] Patient portal Experience Cloud site
- [ ] Mobile app (Salesforce Mobile)
- [ ] Einstein AI predictions
- [ ] Flow automation (reminders, alerts)
- [ ] Telehealth integration
- [ ] e-Prescribing integration
- [ ] Clinical decision support

---

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### Quick Contribution Guide

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Make your changes
4. Write/update tests
5. Ensure 100% test coverage
6. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
7. Push to the branch (`git push origin feature/AmazingFeature`)
8. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Built with [Salesforce DX](https://developer.salesforce.com/tools/sfdxcli)
- UI powered by [Lightning Web Components](https://lwc.dev)
- Design inspired by [Salesforce Lightning Design System](https://www.lightningdesignsystem.com/)

---

## 📞 Support

- 📖 [Salesforce Documentation](https://developer.salesforce.com/docs)
- 💬 [Salesforce Stack Exchange](https://salesforce.stackexchange.com/)
- 🎓 [Trailhead Learning](https://trailhead.salesforce.com/)

---

## 📊 Project Stats

![Lines of Code](https://img.shields.io/badge/Lines%20of%20Code-2000%2B-blue)
![Test Coverage](https://img.shields.io/badge/Test%20Coverage-100%25-success)
![Custom Objects](https://img.shields.io/badge/Custom%20Objects-7-orange)
![Apex Classes](https://img.shields.io/badge/Apex%20Classes-4-purple)
![LWC Components](https://img.shields.io/badge/LWC%20Components-1-yellow)
![Permission Sets](https://img.shields.io/badge/Permission%20Sets-4-green)

---

<div align="center">

**⭐ Star this repo if you find it helpful!**

Made with ❤️ for the Salesforce Healthcare Community

[Report Bug](https://github.com/YOUR_USERNAME/salesforce-healthcare-app/issues) • [Request Feature](https://github.com/YOUR_USERNAME/salesforce-healthcare-app/issues)

</div>
