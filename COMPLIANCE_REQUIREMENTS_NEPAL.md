# Dr. Saathi - Healthcare Compliance Requirements for Nepal

**Document Version:** 1.0  
**Last Updated:** January 8, 2025  
**Status:** Pre-Deployment Compliance Assessment  

---

## Executive Summary

This document outlines the legal, regulatory, and compliance requirements that must be addressed before Dr. Saathi can be deployed for production use in Nepal. **The application is currently NOT compliant** with Nepal's healthcare, data protection, and financial regulations.

**Risk Level:** 🔴 **HIGH** - Deployment without compliance exposes the organization to significant legal, financial, and reputational risks.

---

## Table of Contents

1. [Critical Non-Compliance Issues](#1-critical-non-compliance-issues)
2. [Legal Framework in Nepal](#2-legal-framework-in-nepal)
3. [Required Licenses and Registrations](#3-required-licenses-and-registrations)
4. [Data Protection and Privacy Requirements](#4-data-protection-and-privacy-requirements)
5. [Healthcare Service Requirements](#5-healthcare-service-requirements)
6. [Financial and Payment Compliance](#6-financial-and-payment-compliance)
7. [Technical Security Requirements](#7-technical-security-requirements)
8. [Legal Documentation Required](#8-legal-documentation-required)
9. [Implementation Roadmap](#9-implementation-roadmap)
10. [Estimated Costs and Timeline](#10-estimated-costs-and-timeline)
11. [Contacts and Resources](#11-contacts-and-resources)

---

## 1. Critical Non-Compliance Issues

### 1.1 Data Protection Violations

| Issue | Current Status | Risk Level | Legal Consequence |
|-------|----------------|------------|-------------------|
| No Privacy Policy | ❌ Missing | HIGH | Violations of IT Act 2000 |
| No patient consent mechanism | ❌ Missing | HIGH | Civil liability, penalties |
| Unencrypted data storage | ❌ Missing | CRITICAL | Data breach liability |
| No data retention policy | ❌ Missing | MEDIUM | Regulatory penalties |
| No patient data rights (access/delete) | ❌ Missing | HIGH | Legal complaints |

### 1.2 Healthcare Service Violations

| Issue | Current Status | Risk Level | Legal Consequence |
|-------|----------------|------------|-------------------|
| Unlicensed telemedicine service | ❌ Missing | CRITICAL | Ministry shutdown, fines |
| Unverified doctor credentials | ❌ Missing | HIGH | Professional liability |
| Symptom checker without approval | ❌ Missing | HIGH | Medical device violations |
| No informed consent for treatment | ❌ Missing | HIGH | Malpractice claims |
| No audit trail for medical decisions | ❌ Missing | MEDIUM | Regulatory penalties |

### 1.3 Financial Compliance Violations

| Issue | Current Status | Risk Level | Legal Consequence |
|-------|----------------|------------|-------------------|
| Payment gateway licensing unclear | ⚠️ Unknown | MEDIUM | NRB penalties |
| No VAT/tax compliance system | ❌ Missing | MEDIUM | Tax penalties |
| Insurance information not verified | ❌ Missing | LOW | Misinformation liability |

---

## 2. Legal Framework in Nepal

### 2.1 Primary Legislation

#### **Nepal Medical Council Act, 1964 (Amended 2020)**
- **Purpose:** Regulates medical practice and practitioners
- **Requirements for Dr. Saathi:**
  - Doctor verification through NMC registry
  - Compliance with ethical practice guidelines
  - Telemedicine practice standards

#### **Health Service Act, 1997 (Nepal Health Service Act, 2053)**
- **Purpose:** Governs health service delivery
- **Requirements for Dr. Saathi:**
  - Patient rights protection
  - Informed consent procedures
  - Quality of care standards

#### **Information Technology Act, 2000 (IT Act 2057)**
- **Purpose:** Regulates electronic data and transactions
- **Requirements for Dr. Saathi:**
  - Data security measures
  - Electronic record keeping
  - Cybercrime prevention

#### **Electronic Transaction Act, 2008 (ETA 2063)**
- **Purpose:** Provides legal framework for electronic transactions
- **Requirements for Dr. Saathi:**
  - Digital signature compliance
  - Electronic contract validity
  - Data protection measures

#### **Nepal Rastra Bank Act, 2002**
- **Purpose:** Regulates payment systems
- **Requirements for Dr. Saathi:**
  - Licensed payment gateway usage
  - Transaction record keeping
  - Anti-money laundering compliance

#### **Consumer Protection Act, 2018**
- **Purpose:** Protects consumer rights
- **Requirements for Dr. Saathi:**
  - Clear service terms
  - Pricing transparency
  - Complaint resolution mechanism

### 2.2 Regulatory Bodies

#### **Ministry of Health and Population (MoHP)**
- **Contact:** Ramshah Path, Kathmandu
- **Phone:** 01-4262802
- **Website:** www.mohp.gov.np
- **Jurisdiction:** Overall health services regulation

#### **Nepal Medical Council (NMC)**
- **Contact:** Bansbari, Kathmandu
- **Phone:** 01-4370798
- **Website:** www.nmc.org.np
- **Jurisdiction:** Medical practitioners, telemedicine

#### **Department of Health Services (DoHS)**
- **Jurisdiction:** Health service delivery standards

#### **Nepal Rastra Bank (NRB)**
- **Contact:** Baluwatar, Kathmandu
- **Phone:** 01-4410158
- **Website:** www.nrb.org.np
- **Jurisdiction:** Payment systems

#### **Insurance Board Nepal**
- **Contact:** Teku, Kathmandu
- **Phone:** 01-5970180
- **Website:** www.hib.gov.np
- **Jurisdiction:** Health insurance regulation

---

## 3. Required Licenses and Registrations

### 3.1 Business Registration

✅ **Company Registration**
- Register with Office of Company Registrar (OCR)
- Choose appropriate legal structure (Private Limited, etc.)
- Estimated Time: 2-4 weeks
- Cost: NPR 10,000 - 50,000

✅ **PAN Registration**
- Obtain Permanent Account Number from Inland Revenue Department
- Required for tax compliance
- Estimated Time: 1 week
- Cost: Free

✅ **VAT Registration** (if annual turnover > NPR 5 million)
- Register with Inland Revenue Department
- Estimated Time: 2 weeks
- Cost: Free

### 3.2 Healthcare-Specific Licenses

⚠️ **Telemedicine License**
- **Issuing Authority:** Ministry of Health and Population
- **Requirements:**
  - Licensed medical facility affiliation
  - Quality assurance protocols
  - Data security measures
  - Emergency backup procedures
- **Estimated Time:** 3-6 months
- **Cost:** NPR 50,000 - 200,000
- **Status:** **REQUIRED - Not Yet Obtained**

⚠️ **Medical Device Registration** (if applicable)
- **Issuing Authority:** Department of Drug Administration (DDA)
- **Note:** May be required if symptom checker is classified as medical device
- **Estimated Time:** 6-12 months
- **Cost:** NPR 100,000+
- **Status:** **Assessment Needed**

⚠️ **Health Information System Registration**
- **Issuing Authority:** DoHS, Health Information Management Section
- **Requirements:** Compliance with national health information standards
- **Estimated Time:** 2-3 months
- **Cost:** NPR 25,000 - 75,000
- **Status:** **REQUIRED - Not Yet Obtained**

### 3.3 Technology and Payment Licenses

⚠️ **Payment Gateway License**
- **Issuing Authority:** Nepal Rastra Bank
- **Requirements:**
  - Partnership with NRB-licensed PSP/PSO
  - PCI DSS compliance
  - Transaction security measures
- **Estimated Time:** Already licensed through partner
- **Status:** **Verify Partner License**

⚠️ **Data Center/Cloud Compliance**
- **Note:** If storing data outside Nepal, special approval may be required
- **Issuing Authority:** Ministry of Communication and Information Technology
- **Status:** **Assessment Needed**

---

## 4. Data Protection and Privacy Requirements

### 4.1 Privacy Policy (MANDATORY)

**Status:** ❌ **NOT IMPLEMENTED**

**Requirements:**
- Must be in both English and Nepali
- Must be accessible before app use
- Must be updated annually or when practices change

**Minimum Content Required:**

1. **Data Collection**
   - What personal/medical data is collected
   - How data is collected (forms, sensors, etc.)
   - Purpose of each data type

2. **Data Usage**
   - How patient data is used
   - Who has access to the data
   - Whether data is shared with third parties

3. **Data Storage**
   - Where data is stored (local vs cloud)
   - Data retention period
   - Data deletion procedures

4. **Patient Rights**
   - Right to access personal data
   - Right to correct inaccurate data
   - Right to delete data
   - Right to data portability
   - Process to exercise these rights

5. **Security Measures**
   - Encryption methods
   - Access controls
   - Breach notification procedures

6. **Cookies and Tracking** (if applicable)
   - What tracking technologies are used
   - How to opt-out

7. **Contact Information**
   - Data Protection Officer contact
   - Complaint procedures

### 4.2 Informed Consent Mechanism

**Status:** ❌ **NOT IMPLEMENTED**

**Required Consent Types:**

1. **Registration Consent**
   ```
   ☐ I agree to the collection and processing of my personal information
   ☐ I have read and understood the Privacy Policy
   ☐ I consent to receive health-related communications
   ☐ I understand this is not a substitute for professional medical advice
   ```

2. **Medical Service Consent**
   ```
   ☐ I consent to telemedicine consultation
   ☐ I understand the limitations of remote diagnosis
   ☐ I agree to provide accurate medical information
   ☐ I understand the doctor-patient relationship terms
   ```

3. **Data Sharing Consent** (Optional, if applicable)
   ```
   ☐ I consent to share my anonymized data for research
   ☐ I consent to receive marketing communications
   ```

**Implementation Requirements:**
- Explicit checkbox (not pre-checked)
- Available in user's language
- Can be withdrawn at any time
- Logged with timestamp and IP address

### 4.3 Data Security Requirements

**Status:** ⚠️ **PARTIALLY IMPLEMENTED - NEEDS IMPROVEMENT**

**Mandatory Security Measures:**

| Security Control | Current Status | Required Action |
|------------------|----------------|-----------------|
| Data Encryption at Rest | ❌ Not Implemented | Add AES-256 encryption |
| Data Encryption in Transit | ⚠️ HTTPS only | Add certificate pinning |
| Access Control | ⚠️ Basic auth | Add role-based access (RBAC) |
| Audit Logging | ❌ Not Implemented | Log all data access/changes |
| Password Policy | ⚠️ Minimal (6 chars) | Enforce strong passwords (8+ chars, complexity) |
| Two-Factor Authentication | ❌ Not Implemented | Add 2FA for sensitive access |
| Session Management | ⚠️ Basic | Add secure session timeout |
| Backup and Recovery | ❌ Not Documented | Implement daily encrypted backups |
| Breach Response Plan | ❌ Not Implemented | Create incident response plan |

### 4.4 Data Retention and Deletion

**Status:** ❌ **NOT IMPLEMENTED**

**Required Policies:**

1. **Medical Records:**
   - Retention: Minimum 5 years from last visit (Nepal Health Service Act)
   - After retention period: Secure anonymization or deletion

2. **Financial Records:**
   - Retention: 7 years (Nepal tax law)

3. **Patient Requests:**
   - Process to delete account and all data
   - Response time: Within 30 days
   - Exceptions: Legal obligations to retain

4. **Inactive Accounts:**
   - Define inactive period (e.g., 2 years no activity)
   - Notification before deletion
   - Secure data removal

---

## 5. Healthcare Service Requirements

### 5.1 Doctor Verification System

**Status:** ❌ **NOT IMPLEMENTED**

**Requirements:**
- Verify NMC registration number
- Check license validity and status
- Verify specialization credentials
- Regular re-verification (annual)

**Implementation:**
```
1. Doctor onboarding:
   - Collect NMC registration number
   - Upload license copy
   - Verify with NMC database (manual or API if available)
   - Store verification date and expiry

2. Ongoing verification:
   - Alert when license renewal due
   - Periodic NMC status check
   - Suspend account if license expires
```

### 5.2 Telemedicine Standards

**Status:** ❌ **NOT COMPLIANT**

**Nepal Telemedicine Guidelines (MoHP, 2020):**

1. **Pre-Consultation Requirements:**
   - Patient identity verification
   - Informed consent
   - Emergency contact collection
   - Prior medical history review

2. **During Consultation:**
   - Audio-visual communication quality standards
   - Consultation duration standards
   - Proper documentation
   - Emergency escalation procedures

3. **Post-Consultation:**
   - Electronic prescription compliance
   - Follow-up scheduling
   - Medical record storage
   - Patient feedback mechanism

4. **Emergency Protocols:**
   - Clear identification of emergency cases
   - Immediate referral procedures
   - Emergency contact notifications
   - 24/7 emergency helpline number display

### 5.3 Symptom Checker Compliance

**Status:** ⚠️ **NEEDS REGULATORY CLARIFICATION**

**Potential Classification:**
- May be classified as "Software as a Medical Device" (SaMD)
- Requires DDA registration if diagnostic claims are made

**Risk Mitigation:**
- Add prominent disclaimers
- State it's for "information only"
- Recommend professional consultation
- Avoid definitive diagnoses
- Regular AI model auditing

**Required Disclaimers:**
```
⚠️ IMPORTANT MEDICAL DISCLAIMER:

This symptom checker is for informational purposes only and is not 
intended to be a substitute for professional medical advice, diagnosis, 
or treatment. Always seek the advice of your physician or other 
qualified health provider with any questions you may have regarding 
a medical condition.

In case of emergency, call [Emergency Number] or visit the nearest 
hospital immediately.
```

### 5.4 Prescription System Compliance

**Status:** ⚠️ **NEEDS ENHANCEMENT**

**Nepal Drug Act, 1978 Requirements:**

1. **Electronic Prescription Standards:**
   - Doctor's full name and NMC number
   - Patient's full name and age
   - Date of prescription
   - Medication name (generic name preferred)
   - Dosage and frequency
   - Duration of treatment
   - Digital signature or unique identifier

2. **Controlled Substances:**
   - Special authorization for Schedule drugs
   - Additional documentation requirements
   - Tracking and reporting to DDA

3. **Prescription Storage:**
   - Minimum 3 years retention
   - Secure and accessible for audits
   - Tamper-proof records

---

## 6. Financial and Payment Compliance

### 6.1 Payment Gateway Compliance

**Status:** ⚠️ **VERIFICATION NEEDED**

**Nepal Rastra Bank Requirements:**

1. **Partner with Licensed PSP/PSO:**
   - Verify partner has NRB license
   - Check license validity
   - Review service agreement

2. **PCI DSS Compliance:**
   - Level depends on transaction volume
   - Annual compliance certification
   - Secure cardholder data handling

3. **Transaction Reporting:**
   - Daily transaction reconciliation
   - Monthly reporting to NRB (if applicable)
   - Suspicious transaction reporting

**Action Items:**
- [ ] Obtain copy of payment partner's NRB license
- [ ] Review PCI DSS compliance status
- [ ] Implement transaction logging
- [ ] Create reconciliation procedures

### 6.2 Tax Compliance

**Status:** ❌ **NOT IMPLEMENTED**

**Requirements:**

1. **VAT (Value Added Tax):**
   - Register if annual turnover > NPR 5 million
   - 13% standard rate on taxable services
   - Monthly VAT returns
   - Digital VAT invoicing

2. **Income Tax:**
   - Corporate tax rate: 25%
   - Healthcare services may have special rates
   - Quarterly advance tax payments
   - Annual return filing

3. **Withholding Tax:**
   - 15% on doctor payments (if applicable)
   - Monthly remittance to IRD

**Implementation Requirements:**
- Automated VAT calculation in billing
- Tax invoice generation (Nepali format)
- Payment gateway integration with tax system
- Accounting software integration

### 6.3 Billing and Invoicing

**Status:** ⚠️ **BASIC IMPLEMENTATION**

**Legal Requirements:**

1. **Invoice Content (Nepal):**
   - Sequential invoice number
   - PAN number of provider
   - Date and time
   - Patient details
   - Service description
   - Amount before tax
   - VAT amount (if applicable)
   - Total amount
   - Payment method

2. **Record Keeping:**
   - 7 years retention minimum
   - Available for tax audits
   - Both digital and physical copies

3. **Patient Billing Rights:**
   - Itemized billing
   - Transparent pricing
   - Dispute resolution process
   - Refund policy

---

## 7. Technical Security Requirements

### 7.1 Application Security

**Status:** ⚠️ **NEEDS SIGNIFICANT IMPROVEMENT**

**Required Security Measures:**

| Security Control | Priority | Current Status | Target |
|------------------|----------|----------------|--------|
| Secure Authentication | HIGH | Basic email/password | Multi-factor auth |
| Password Hashing | HIGH | Unknown | bcrypt/Argon2 |
| SQL Injection Prevention | HIGH | Using SQLite queries | Parameterized queries |
| XSS Prevention | MEDIUM | Framework default | Input sanitization |
| CSRF Protection | MEDIUM | Unknown | Token-based |
| API Security | HIGH | Unknown | OAuth 2.0, rate limiting |
| Secure File Upload | MEDIUM | Unknown | Type/size validation |
| Error Handling | MEDIUM | Unknown | No sensitive data leakage |

### 7.2 Data Encryption

**Status:** ❌ **NOT IMPLEMENTED**

**Requirements:**

1. **Encryption at Rest:**
   - AES-256 for database
   - Encrypted file storage
   - Secure key management (not hardcoded)

2. **Encryption in Transit:**
   - TLS 1.3 minimum
   - Certificate pinning
   - Perfect Forward Secrecy (PFS)

3. **Key Management:**
   - Separate encryption keys per environment
   - Regular key rotation
   - Hardware Security Module (HSM) for production

### 7.3 Audit and Logging

**Status:** ❌ **NOT IMPLEMENTED**

**Required Audit Logs:**

1. **Access Logs:**
   - User login/logout
   - Failed login attempts
   - Session creation/termination
   - IP address and device info

2. **Data Access Logs:**
   - Patient record views
   - Medical data modifications
   - Prescription creations
   - Data exports

3. **System Logs:**
   - Application errors
   - Security events
   - Configuration changes
   - Database modifications

**Log Retention:**
- Security logs: 1 year minimum
- Medical access logs: 5 years minimum
- Tamper-proof storage
- Regular log review

### 7.4 Backup and Disaster Recovery

**Status:** ❌ **NOT DOCUMENTED**

**Requirements:**

1. **Backup Schedule:**
   - Daily incremental backups
   - Weekly full backups
   - Monthly archive backups

2. **Backup Storage:**
   - Off-site storage
   - Encrypted backups
   - Geographically separate locations

3. **Disaster Recovery:**
   - Recovery Time Objective (RTO): < 4 hours
   - Recovery Point Objective (RPO): < 24 hours
   - Documented recovery procedures
   - Annual disaster recovery drill

### 7.5 Penetration Testing

**Status:** ❌ **NOT PERFORMED**

**Requirements:**
- Annual penetration testing by certified firm
- Vulnerability assessment every 6 months
- Remediation of critical issues within 30 days
- Report filing with regulatory authorities (if required)

---

## 8. Legal Documentation Required

### 8.1 Privacy Policy

**Status:** ❌ **NOT CREATED**

**Must Include:**
- Data collection practices
- Data usage and sharing
- Patient rights (DSAR)
- Security measures
- Cookie policy
- Contact information
- Last updated date

**Languages:** English and Nepali  
**Review Frequency:** Annually or upon practice change  
**Cost:** NPR 50,000 - 150,000 (legal drafting)

### 8.2 Terms of Service

**Status:** ❌ **NOT CREATED**

**Must Include:**
- Service description
- User obligations
- Payment terms
- Cancellation policy
- Liability limitations
- Dispute resolution
- Governing law (Nepal)
- Jurisdiction (Nepal courts)

**Languages:** English and Nepali  
**Cost:** NPR 50,000 - 150,000 (legal drafting)

### 8.3 Medical Disclaimer

**Status:** ⚠️ **BASIC VERSION EXISTS**

**Current Status:** Basic disclaimer in code  
**Required:** Prominent, legally-vetted disclaimer throughout app

**Placement:**
- Splash screen
- Before symptom checker
- Before doctor consultation
- In prescription interface
- Footer of every page

### 8.4 Patient Consent Forms

**Status:** ❌ **NOT CREATED**

**Required Forms:**

1. **Registration Consent**
   - Data processing consent
   - Terms acceptance
   - Communication preferences

2. **Telemedicine Consent**
   - Consultation agreement
   - Technology limitations acknowledgment
   - Emergency procedures understanding
   - Recording consent (if applicable)

3. **Prescription Consent**
   - Understanding of medication
   - Side effects acknowledgment
   - Follow-up agreement

**Format:** Digital with e-signature capability  
**Retention:** 5 years after last service  
**Languages:** English and Nepali

### 8.5 Doctor Service Agreement

**Status:** ❌ **NOT CREATED**

**Must Include:**
- Scope of services
- Payment terms
- Professional liability insurance requirements
- License verification procedures
- Termination clauses
- Non-compete/confidentiality (if applicable)
- Indemnification clauses

**Review:** By healthcare attorney  
**Execution:** Digital signature

### 8.6 Data Processing Agreement (DPA)

**Status:** ❌ **NOT CREATED**

**Required if using third-party services:**
- Cloud hosting providers
- Payment processors
- SMS/notification services
- Analytics providers

**Must Include:**
- Data processing purposes
- Data security measures
- Sub-processor disclosure
- Data breach notification
- Audit rights
- Data return/deletion obligations

---

## 9. Implementation Roadmap

### Phase 1: Legal Foundation (Month 1-2)

**Priority: CRITICAL**

| Task | Owner | Duration | Cost (NPR) | Dependencies |
|------|-------|----------|------------|--------------|
| Engage healthcare attorney | Management | 1 week | 50,000+ | - |
| Company registration (if not done) | Legal | 2-4 weeks | 10,000-50,000 | - |
| Draft Privacy Policy | Legal | 2 weeks | 50,000-100,000 | Attorney hired |
| Draft Terms of Service | Legal | 2 weeks | 50,000-100,000 | Attorney hired |
| Create consent forms | Legal | 1 week | 25,000-50,000 | Attorney hired |
| Medical disclaimer review | Legal | 1 week | 20,000 | Attorney hired |
| Doctor service agreement | Legal | 2 weeks | 40,000 | Attorney hired |

**Milestone:** Legal documentation complete and reviewed

### Phase 2: Regulatory Compliance (Month 2-6)

**Priority: CRITICAL**

| Task | Owner | Duration | Cost (NPR) | Dependencies |
|------|-------|----------|------------|--------------|
| Telemedicine license application | Compliance | 3-6 months | 50,000-200,000 | Company registration |
| NMC consultation | Medical Director | 2 weeks | 10,000 | - |
| Health IT system registration | Compliance | 2-3 months | 25,000-75,000 | Company registration |
| Payment gateway license verification | Finance | 1 week | - | - |
| Medical device classification assessment | Compliance | 4 weeks | 30,000 | Legal review |
| Tax registration (PAN, VAT) | Finance | 2 weeks | Free | Company registration |

**Milestone:** All required licenses obtained or in process

### Phase 3: Technical Implementation (Month 2-4)

**Priority: HIGH**

| Task | Owner | Duration | Cost (NPR) | Dependencies |
|------|-------|----------|------------|--------------|
| Implement data encryption (at rest) | Dev Team | 2 weeks | - | - |
| Implement audit logging | Dev Team | 2 weeks | - | - |
| Add consent mechanisms | Dev Team | 1 week | - | Consent forms ready |
| Implement 2FA | Dev Team | 1 week | - | - |
| Doctor verification system | Dev Team | 2 weeks | - | NMC consultation |
| Privacy policy integration | Dev Team | 1 week | - | Policy ready |
| Enhanced disclaimers | Dev Team | 1 week | - | Legal review |
| Patient data rights (export/delete) | Dev Team | 2 weeks | - | - |
| Tax calculation system | Dev Team | 2 weeks | - | Tax registration |

**Milestone:** Technical compliance features implemented

### Phase 4: Security Hardening (Month 3-4)

**Priority: HIGH**

| Task | Owner | Duration | Cost (NPR) | Dependencies |
|------|-------|----------|------------|--------------|
| Security audit | Security Firm | 2 weeks | 100,000-300,000 | - |
| Penetration testing | Security Firm | 1 week | 150,000-400,000 | - |
| Vulnerability remediation | Dev Team | 2-4 weeks | - | Testing complete |
| PCI DSS assessment (if applicable) | Security Firm | 4 weeks | 200,000+ | Payment system |
| Backup and DR implementation | DevOps | 2 weeks | 50,000 | - |
| SSL/TLS certificate setup | DevOps | 1 week | 20,000/year | - |

**Milestone:** Security certifications obtained

### Phase 5: Testing and Quality Assurance (Month 4-5)

**Priority: MEDIUM-HIGH**

| Task | Owner | Duration | Cost (NPR) | Dependencies |
|------|-------|----------|------------|--------------|
| User acceptance testing | QA Team | 2 weeks | - | Phase 3 complete |
| Compliance testing | Legal/Compliance | 2 weeks | 30,000 | All phases |
| Accessibility testing | QA Team | 1 week | - | - |
| Performance testing | DevOps | 1 week | - | - |
| Medical accuracy review | Medical Team | 2 weeks | 50,000 | - |
| Nepali language QA | Translators | 1 week | 20,000 | - |

**Milestone:** System tested and compliant

### Phase 6: Soft Launch (Month 5-6)

**Priority: MEDIUM**

| Task | Owner | Duration | Cost (NPR) | Dependencies |
|------|-------|----------|------------|--------------|
| Pilot program with limited users | Product Team | 4 weeks | - | All testing complete |
| Staff training (doctors, support) | Training | 2 weeks | 50,000 | - |
| Monitoring and feedback | Product Team | Ongoing | - | Soft launch |
| Compliance monitoring | Compliance | Ongoing | 30,000/month | Soft launch |
| Insurance procurement | Management | 2 weeks | 100,000+/year | Licenses |

**Milestone:** Limited production deployment

### Phase 7: Full Launch (Month 6+)

**Priority: MEDIUM**

| Task | Owner | Duration | Cost (NPR) | Dependencies |
|------|-------|----------|------------|--------------|
| Marketing and promotion | Marketing | Ongoing | Variable | Successful pilot |
| Scaling infrastructure | DevOps | 2 weeks | 50,000+ | Pilot success |
| Ongoing compliance monitoring | Compliance | Ongoing | 50,000/month | - |
| Regular security audits | Security | Quarterly | 100,000/quarter | - |

**Milestone:** Full production launch

---

## 10. Estimated Costs and Timeline

### 10.1 One-Time Costs

| Category | Item | Low Estimate (NPR) | High Estimate (NPR) |
|----------|------|-------------------|-------------------|
| **Legal** | Privacy Policy & ToS | 100,000 | 200,000 |
| | Consent Forms | 25,000 | 50,000 |
| | Service Agreements | 40,000 | 80,000 |
| | Ongoing Legal Consultation | 50,000 | 150,000 |
| **Licensing** | Company Registration | 10,000 | 50,000 |
| | Telemedicine License | 50,000 | 200,000 |
| | Health IT Registration | 25,000 | 75,000 |
| | Medical Device Registration (if req) | 100,000 | 500,000 |
| **Security** | Penetration Testing | 150,000 | 400,000 |
| | Security Audit | 100,000 | 300,000 |
| | PCI DSS Certification | 200,000 | 500,000 |
| **Development** | Compliance Features | - | - |
| | (internal development time) | - | - |
| **Infrastructure** | Backup Systems | 50,000 | 150,000 |
| | SSL Certificates (1 year) | 20,000 | 50,000 |
| **Training** | Staff Training | 50,000 | 100,000 |
| **TOTAL ONE-TIME** | | **970,000** | **2,805,000** |

### 10.2 Recurring Annual Costs

| Category | Item | Low Estimate (NPR) | High Estimate (NPR) |
|----------|------|-------------------|-------------------|
| **Legal** | Annual Legal Retainer | 100,000 | 300,000 |
| **Licensing** | License Renewals | 50,000 | 150,000 |
| **Compliance** | Compliance Officer/Consulting | 360,000 | 600,000 |
| **Security** | Annual Penetration Testing | 150,000 | 400,000 |
| | Security Monitoring | 120,000 | 300,000 |
| **Insurance** | Professional Liability Insurance | 200,000 | 500,000 |
| | Cyber Insurance | 100,000 | 300,000 |
| **Infrastructure** | SSL Certificates | 20,000 | 50,000 |
| | Backup Storage | 60,000 | 150,000 |
| **Auditing** | Annual Compliance Audit | 100,000 | 250,000 |
| **TOTAL ANNUAL** | | **1,260,000** | **3,000,000** |

### 10.3 Timeline Summary

| Phase | Duration | Can Start |
|-------|----------|-----------|
| Phase 1: Legal Foundation | 1-2 months | Immediately |
| Phase 2: Regulatory Compliance | 3-6 months | After Phase 1 starts |
| Phase 3: Technical Implementation | 2-4 months | Parallel with Phase 1 |
| Phase 4: Security Hardening | 1-2 months | After Phase 3 |
| Phase 5: Testing & QA | 1-2 months | After Phase 4 |
| Phase 6: Soft Launch | 1-2 months | After Phase 5 |
| Phase 7: Full Launch | Ongoing | After Phase 6 |
| **TOTAL MINIMUM TIME** | **6 months** | |
| **REALISTIC TIME** | **9-12 months** | |

---

## 11. Contacts and Resources

### 11.1 Regulatory Bodies

#### Ministry of Health and Population
- **Address:** Ramshah Path, Kathmandu, Nepal
- **Phone:** +977-1-4262802, 4262987
- **Email:** info@mohp.gov.np
- **Website:** www.mohp.gov.np
- **Services:** Telemedicine licensing, health service regulation

#### Nepal Medical Council
- **Address:** Bansbari, Kathmandu
- **Phone:** +977-1-4370798, 4371178
- **Email:** info@nmc.org.np
- **Website:** www.nmc.org.np
- **Services:** Doctor verification, medical ethics

#### Department of Drug Administration
- **Address:** Khumaltar, Lalitpur
- **Phone:** +977-1-5542444
- **Website:** www.dda.gov.np
- **Services:** Medical device registration, pharmaceutical regulation

#### Nepal Rastra Bank
- **Address:** Baluwatar, Kathmandu
- **Phone:** +977-1-4410158
- **Website:** www.nrb.org.np
- **Services:** Payment system regulation

#### Insurance Board Nepal
- **Address:** Teku, Kathmandu
- **Phone:** +977-1-5970180, 5970181
- **Email:** info@hib.gov.np
- **Website:** www.hib.gov.np
- **Services:** Insurance regulation

#### Inland Revenue Department
- **Address:** Lazimpat, Kathmandu
- **Phone:** +977-1-4415802
- **Website:** www.ird.gov.np
- **Services:** Tax registration, compliance

### 11.2 Professional Services

#### Healthcare Law Firms in Nepal
- **Nepal Law Campus Associates**
- **Pioneer Law Associates**
- **Legal Clinic Nepal**
- **Suresh Acharya & Associates**
- (Contact details available through Nepal Bar Association)

#### Security Audit Firms
- **Infosec Nepal Pvt. Ltd.**
- **Grepsr Security**
- **CloudFactory (tech services)**
- International firms: Deloitte Nepal, PwC Nepal

#### Healthcare Consultants
- **Nepal Health Research Council (NHRC)**
- **Nepal Public Health Association**
- Healthcare IT consultants (various)

### 11.3 Useful Resources

#### Legal Frameworks
- Nepal Law Commission: www.lawcommission.gov.np
- All Nepal laws in English and Nepali

#### Standards and Guidelines
- WHO Telemedicine Guidelines
- HL7 FHIR Standards (health data)
- OWASP Security Standards
- PCI DSS Requirements

#### Industry Associations
- **Computer Association of Nepal (CAN)**
  - Phone: +977-1-4169178
  - Email: info@can.org.np

- **Nepal Software Association (P) Ltd**
  - Website: www.nepalsoft.org

---

## 12. Risk Assessment

### 12.1 Risk Matrix

| Risk | Likelihood | Impact | Risk Level | Mitigation Priority |
|------|-----------|---------|-----------|---------------------|
| Regulatory shutdown | HIGH | CRITICAL | 🔴 EXTREME | IMMEDIATE |
| Data breach | MEDIUM | CRITICAL | 🔴 HIGH | IMMEDIATE |
| Medical malpractice claim | MEDIUM | HIGH | 🟠 HIGH | HIGH |
| Payment fraud | LOW | HIGH | 🟡 MEDIUM | MEDIUM |
| Tax penalties | HIGH | MEDIUM | 🟠 MEDIUM-HIGH | HIGH |
| Reputation damage | MEDIUM | HIGH | 🟠 HIGH | HIGH |
| Privacy violations | HIGH | HIGH | 🔴 HIGH | IMMEDIATE |

### 12.2 Consequences of Non-Compliance

#### Legal Consequences
- **Criminal Liability:** Potential imprisonment under IT Act for data breaches
- **Civil Liability:** Patient lawsuits for medical negligence or data misuse
- **Regulatory Penalties:** Fines ranging from NPR 100,000 - 5,000,000
- **Business Closure:** Ministry can order immediate shutdown
- **Personal Liability:** Directors may be personally liable

#### Financial Consequences
- **Direct Fines:** NPR 100,000 - 5,000,000 per violation
- **Legal Costs:** NPR 500,000 - 5,000,000+ for defending cases
- **Compensation:** Unlimited liability for damages to patients
- **Lost Revenue:** Business shutdown during compliance remediation
- **Insurance Invalidity:** Claims denied if non-compliant

#### Reputational Consequences
- Loss of patient trust
- Negative media coverage
- Doctor unwillingness to use platform
- Investor concerns
- Difficulty in future funding

---

## 13. Action Plan Summary

### IMMEDIATE ACTIONS (Within 1 Month)

1. ✅ **STOP production deployment immediately**
2. ✅ **Engage healthcare attorney** (Budget: NPR 50,000+)
3. ✅ **Conduct compliance gap analysis** (This document)
4. ⚠️ **Start Privacy Policy drafting** (Cost: NPR 50,000-100,000)
5. ⚠️ **Begin company registration** if not done (Cost: NPR 10,000-50,000)
6. ⚠️ **Assess telemedicine license requirements** with MoHP

### SHORT-TERM ACTIONS (1-3 Months)

7. Complete legal documentation (Privacy Policy, ToS, Consents)
8. Implement consent mechanisms in app
9. Add enhanced medical disclaimers
10. Start telemedicine license application
11. Implement data encryption
12. Add audit logging
13. Tax registrations (PAN, VAT)

### MEDIUM-TERM ACTIONS (3-6 Months)

14. Complete technical compliance features
15. Security audit and penetration testing
16. Doctor verification system
17. Obtain telemedicine license
18. Vulnerability remediation
19. Staff training
20. Pilot testing with limited users

### LONG-TERM ACTIONS (6+ Months)

21. Full production launch (only after all compliance achieved)
22. Ongoing compliance monitoring
23. Regular security audits
24. Annual license renewals
25. Continuous improvement

---

## 14. Disclaimer and Limitations

### About This Document

**Purpose:** This document provides a compliance assessment and roadmap for Dr. Saathi application to operate legally in Nepal. It is intended as a guide for management and development teams.

**Limitations:**
- This is NOT legal advice
- Laws and regulations change frequently
- Specific circumstances may require additional compliance measures
- Professional legal consultation is MANDATORY
- Regulatory interpretations may vary

**Recommendations:**
1. Engage a qualified healthcare attorney licensed in Nepal
2. Consult directly with regulatory bodies before proceeding
3. Update this assessment as laws change
4. Conduct periodic compliance reviews
5. Maintain ongoing legal counsel

### Legal Consultation Required

**DO NOT proceed with deployment without:**
- Written legal opinion from healthcare attorney
- Confirmation of required licenses
- Approved privacy policy and terms
- Security audit completion
- Professional liability insurance

---

## 15. Conclusion

### Current Status: 🔴 **NOT COMPLIANT FOR PRODUCTION USE**

The Dr. Saathi application shows promise as a healthcare technology solution for Nepal, but it currently **does not meet the legal, regulatory, and compliance requirements** for production deployment.

### Critical Path to Compliance

**Minimum Requirements Before Launch:**
1. ✅ Legal documentation (Privacy Policy, ToS, Consents)
2. ✅ Telemedicine license from MoHP
3. ✅ Data encryption and security measures
4. ✅ Doctor verification system
5. ✅ Payment compliance verification
6. ✅ Tax registrations
7. ✅ Professional liability insurance
8. ✅ Security audit completion

### Estimated Investment

- **One-time costs:** NPR 970,000 - 2,805,000
- **Annual recurring costs:** NPR 1,260,000 - 3,000,000
- **Time to compliance:** 6-12 months

### Recommendation

**DO NOT launch Dr. Saathi for production use in Nepal until:**
- All critical compliance issues are resolved
- Required licenses are obtained
- Legal documentation is complete and approved
- Security measures are implemented and tested
- Professional legal counsel confirms compliance

### Next Steps

1. Present this assessment to management
2. Secure budget for compliance (minimum NPR 1-3 million)
3. Engage healthcare attorney within 1 week
4. Begin legal documentation process
5. Start license application processes
6. Implement technical compliance features
7. Plan for 6-12 month timeline before launch

---

## Document Control

**Version:** 1.0  
**Date:** January 8, 2025  
**Prepared by:** Compliance Assessment Team  
**Reviewed by:** [Pending Legal Review]  
**Approved by:** [Pending Management Approval]  

**Next Review Date:** [To be scheduled after legal consultation]

**Distribution:**
- Management Team
- Development Team
- Legal Counsel
- Compliance Officer

---

## Appendices

### Appendix A: Compliance Checklist

**Pre-Launch Compliance Checklist:**

#### Legal Documentation
- [ ] Privacy Policy (English & Nepali)
- [ ] Terms of Service (English & Nepali)
- [ ] Medical Disclaimer
- [ ] Patient Consent Forms
- [ ] Doctor Service Agreement
- [ ] Data Processing Agreements

#### Licenses and Registrations
- [ ] Company Registration
- [ ] PAN Registration
- [ ] VAT Registration (if applicable)
- [ ] Telemedicine License
- [ ] Health IT System Registration
- [ ] Medical Device Registration (if required)
- [ ] Payment Gateway Verification

#### Technical Compliance
- [ ] Data Encryption (at rest)
- [ ] Data Encryption (in transit)
- [ ] Audit Logging
- [ ] Two-Factor Authentication
- [ ] Secure Password Hashing
- [ ] Doctor Verification System
- [ ] Patient Data Rights (export/delete)
- [ ] Consent Management System
- [ ] Enhanced Disclaimers

#### Security
- [ ] Security Audit Completed
- [ ] Penetration Testing Completed
- [ ] Vulnerability Remediation
- [ ] PCI DSS Compliance (if applicable)
- [ ] Backup and Disaster Recovery
- [ ] SSL/TLS Certificates
- [ ] Security Monitoring

#### Operational
- [ ] Staff Training Completed
- [ ] Compliance Monitoring Process
- [ ] Incident Response Plan
- [ ] Professional Liability Insurance
- [ ] Cyber Insurance
- [ ] Emergency Procedures
- [ ] Quality Assurance Process

### Appendix B: Key Nepal Healthcare Laws

1. **Nepal Medical Council Act, 1964 (Amended 2020)**
2. **Health Service Act, 1997 (Nepal Health Service Act, 2053)**
3. **Information Technology Act, 2000 (IT Act 2057)**
4. **Electronic Transaction Act, 2008 (ETA 2063)**
5. **Nepal Rastra Bank Act, 2002**
6. **Consumer Protection Act, 2018**
7. **Nepal Drug Act, 1978**
8. **Public Health Service Act, 2018**

### Appendix C: Glossary

- **DDA:** Department of Drug Administration
- **DoHS:** Department of Health Services
- **DPA:** Data Processing Agreement
- **DSAR:** Data Subject Access Request
- **ETA:** Electronic Transaction Act
- **FHIR:** Fast Healthcare Interoperability Resources
- **HIB:** Health Insurance Board
- **HSM:** Hardware Security Module
- **IRD:** Inland Revenue Department
- **IT Act:** Information Technology Act
- **MoHP:** Ministry of Health and Population
- **NMC:** Nepal Medical Council
- **NPR:** Nepali Rupees
- **NRB:** Nepal Rastra Bank
- **OCR:** Office of Company Registrar
- **PAN:** Permanent Account Number
- **PCI DSS:** Payment Card Industry Data Security Standard
- **PSO:** Payment System Operator
- **PSP:** Payment Service Provider
- **RBAC:** Role-Based Access Control
- **RPO:** Recovery Point Objective
- **RTO:** Recovery Time Objective
- **SaMD:** Software as a Medical Device
- **ToS:** Terms of Service
- **VAT:** Value Added Tax

---

**END OF DOCUMENT**

*This document should be converted to PDF for formal distribution and record-keeping.*
