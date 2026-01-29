# Contributing to Patient Care Coordination Platform

First off, thank you for considering contributing to the Patient Care Coordination Platform! It's people like you that make this project a great tool for the Salesforce healthcare community.

## 🎯 Code of Conduct

This project and everyone participating in it is governed by respect, collaboration, and professionalism. By participating, you are expected to uphold this standard.

## 🚀 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

**Bug Report Template:**
```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Salesforce Org Details:**
- Org Type: [e.g., Developer, Sandbox, Production]
- API Version: [e.g., 65.0]
- Browser: [e.g., Chrome, Firefox]

**Additional context**
Add any other context about the problem here.
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

**Enhancement Template:**
```markdown
**Is your feature request related to a problem?**
A clear and concise description of what the problem is.

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
A clear and concise description of any alternative solutions or features you've considered.

**Additional context**
Add any other context or screenshots about the feature request here.
```

### Pull Requests

1. **Fork the repo** and create your branch from `main`
2. **Follow the coding standards** outlined below
3. **Write tests** for any new functionality
4. **Ensure 100% test coverage** on modified/new classes
5. **Update documentation** as needed
6. **Test your changes** in a scratch org
7. **Submit a pull request**

## 📋 Development Process

### Setting Up Your Development Environment

```bash
# 1. Fork and clone the repository
git clone https://github.com/YOUR_USERNAME/salesforce-healthcare-app.git
cd salesforce-healthcare-app

# 2. Create a scratch org for development
sf org create scratch --definition-file config/project-scratch-def.json \
  --alias dev-scratch --set-default --duration-days 30

# 3. Deploy the code
sf project deploy start

# 4. Run tests
sf apex test run --test-level RunLocalTests --code-coverage
```

### Making Changes

```bash
# 1. Create a feature branch
git checkout -b feature/your-feature-name

# 2. Make your changes

# 3. Run tests locally
sf apex test run --test-level RunLocalTests --code-coverage

# 4. Commit your changes
git add .
git commit -m "Add: Brief description of your changes"

# 5. Push to your fork
git push origin feature/your-feature-name

# 6. Open a Pull Request
```

## 💻 Coding Standards

### Apex Guidelines

1. **Class Naming:**
   - Use PascalCase for class names
   - Controllers should end with `Controller`
   - Test classes should end with `Test`
   - Utility classes should end with `Utils` or `Helper`

2. **Method Naming:**
   - Use camelCase for method names
   - Methods should be descriptive and verb-based
   - Example: `getPatientAppointments()`, `validateVitalSigns()`

3. **Comments:**
   - Use JavaDoc-style comments for classes and public methods
   - Include `@param` and `@return` annotations
   ```apex
   /**
    * Retrieves appointments for a specific patient
    * @param patientId The ID of the patient
    * @return List of appointments ordered by date
    */
   @AuraEnabled(cacheable=true)
   public static List<Appointment__c> getPatientAppointments(Id patientId) {
       // implementation
   }
   ```

4. **Error Handling:**
   - Always wrap public methods in try-catch blocks
   - Throw `AuraHandledException` for Lightning components
   - Log errors appropriately
   ```apex
   try {
       // logic here
   } catch (Exception e) {
       throw new AuraHandledException('Error message: ' + e.getMessage());
   }
   ```

5. **Security:**
   - Always use `with sharing` for classes that query data
   - Validate all inputs
   - Use `@AuraEnabled` sparingly and only when needed
   - Never expose sensitive data without proper checks

### Lightning Web Component Guidelines

1. **File Structure:**
   ```
   componentName/
   ├── componentName.js
   ├── componentName.html
   ├── componentName.css
   ├── componentName.js-meta.xml
   └── __tests__/
       └── componentName.test.js (future)
   ```

2. **Naming:**
   - Use camelCase for component names
   - Properties should be descriptive
   - Event handlers should start with `handle`

3. **Best Practices:**
   - Use `@wire` for data retrieval when possible
   - Implement proper error handling
   - Use Lightning Design System (SLDS) for styling
   - Make components responsive

### Testing Requirements

**All code must meet these testing standards:**

1. **Test Coverage:**
   - Minimum 90% code coverage for all classes
   - Aim for 100% coverage
   - Test all public methods
   - Test error scenarios

2. **Test Structure:**
   ```apex
   @isTest
   private class YourControllerTest {

       @TestSetup
       static void setupTestData() {
           // Create test data once for all test methods
       }

       @isTest
       static void testPositiveScenario() {
           // Test expected behavior
       }

       @isTest
       static void testNegativeScenario() {
           // Test error handling
       }

       @isTest
       static void testBulkScenario() {
           // Test with 200+ records
       }
   }
   ```

3. **Test Data:**
   - Use `@TestSetup` for creating test data
   - Never use hardcoded IDs
   - Test with bulk data (200+ records)
   - Create all required parent records

## 📦 Pull Request Process

1. **Update Documentation:**
   - Update README.md if adding new features
   - Update SECURITY_GUIDE.md if changing permissions
   - Add inline code comments

2. **Test Your Changes:**
   ```bash
   # Run all tests
   sf apex test run --test-level RunLocalTests --code-coverage

   # Deploy to a scratch org
   sf project deploy start
   ```

3. **Commit Message Format:**
   ```
   Type: Brief description (50 chars or less)

   More detailed explanation if necessary. Wrap at 72 characters.

   - Bullet points are okay
   - Use present tense: "Add feature" not "Added feature"

   Closes #123
   ```

   **Types:**
   - `Add:` New feature
   - `Fix:` Bug fix
   - `Update:` Update existing feature
   - `Refactor:` Code refactoring
   - `Docs:` Documentation changes
   - `Test:` Adding tests
   - `Security:` Security improvements

4. **Pull Request Template:**
   Your PR will use this template automatically:
   ```markdown
   ## Description
   Brief description of changes

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update

   ## Testing
   - [ ] All tests pass
   - [ ] Added new tests
   - [ ] Test coverage maintained/improved

   ## Checklist
   - [ ] Code follows project standards
   - [ ] Self-review completed
   - [ ] Documentation updated
   - [ ] No breaking changes (or documented)
   ```

5. **Review Process:**
   - At least one maintainer review required
   - All comments must be resolved
   - All checks must pass
   - Keep PR scope focused

## 🏗️ Project Structure

```
force-app/main/default/
├── classes/                 # Apex classes
│   ├── controllers/         # Lightning controllers
│   ├── services/            # Business logic
│   ├── utils/              # Utility classes
│   └── tests/              # Test classes
├── lwc/                    # Lightning Web Components
├── objects/                # Custom objects
├── permissionsets/         # Permission sets
└── triggers/               # Apex triggers
```

## 🎨 Style Guide

### Apex
- Indentation: 4 spaces
- Line length: 120 characters max
- Braces: Same line
- Use meaningful variable names

### JavaScript (LWC)
- Indentation: 4 spaces
- Use ES6+ features
- Use `const` by default, `let` when needed
- No `var`

### XML/Metadata
- Indentation: 4 spaces
- Follow Salesforce metadata structure

## 🔍 Review Checklist

Before submitting your PR, ensure:

- [ ] Code compiles without errors
- [ ] All tests pass with 90%+ coverage
- [ ] No security vulnerabilities introduced
- [ ] Documentation updated
- [ ] Follows coding standards
- [ ] Commits are well-structured
- [ ] PR description is clear and complete

## 📞 Questions?

- Open an issue for questions
- Tag maintainers for urgent items
- Join discussions in existing issues

## 🙏 Thank You!

Your contributions make this project better for everyone in the Salesforce healthcare community!

---

**Happy Coding!** 🚀
