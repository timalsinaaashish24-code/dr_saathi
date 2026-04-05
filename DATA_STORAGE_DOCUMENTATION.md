# Dr. Saathi - Data Storage Documentation

**Document Version:** 1.0  
**Last Updated:** January 8, 2025  
**Classification:** INTERNAL - CONFIDENTIAL  

---

## Executive Summary

This document details where and how patient and doctor data is stored in the Dr. Saathi application. Understanding data storage locations is **CRITICAL** for compliance, security, and privacy requirements.

⚠️ **SECURITY ALERT:** Patient and doctor data is currently stored **UNENCRYPTED** in local SQLite databases on the device.

---

## Table of Contents

1. [Data Storage Overview](#1-data-storage-overview)
2. [Database Locations by Platform](#2-database-locations-by-platform)
3. [Patient Data Storage](#3-patient-data-storage)
4. [Doctor Data Storage](#4-doctor-data-storage)
5. [Data Tables and Schema](#5-data-tables-and-schema)
6. [Security Status](#6-security-status)
7. [Cloud Storage (Currently None)](#7-cloud-storage-currently-none)
8. [Critical Security Issues](#8-critical-security-issues)
9. [Recommendations](#9-recommendations)

---

## 1. Data Storage Overview

### Storage Technology
- **Database Engine:** SQLite
- **Storage Type:** Local device storage (no cloud backup)
- **Encryption:** ❌ **NONE** (plain text storage)
- **Access Control:** File system permissions only
- **Backup:** None by default

### Two Separate Databases

The application uses **TWO separate SQLite databases**:

| Database | Purpose | File Name | Primary Tables |
|----------|---------|-----------|----------------|
| **Main Database** | Patient records, appointments, prescriptions, billing | `dr_saathi.db` | patients, prescriptions, medications, invoices, billing_items, sms_reminders |
| **Authentication Database** | Patient portal login credentials | `patients_auth.db` | patients_auth |

---

## 2. Database Locations by Platform

### macOS (Development/Desktop)

**Location:** `/Users/[username]/Library/Containers/com.example.drSaathi/Data/Documents/`

**Full Paths:**
```
/Users/test/Library/Containers/com.example.drSaathi/Data/Documents/dr_saathi.db
/Users/test/Library/Containers/com.example.drSaathi/Data/Documents/patients_auth.db
```

**Characteristics:**
- Sandboxed application container
- User-specific storage
- Survives app updates
- Accessible with admin privileges
- **NOT encrypted by default**

**Access via Terminal:**
```bash
# View database location
cd ~/Library/Containers/com.example.drSaathi/Data/Documents/

# List databases
ls -lh *.db

# Open database for inspection (requires sqlite3)
sqlite3 dr_saathi.db
```

### iOS (Mobile - Production)

**Location:** Application Documents Directory  
**Full Path (Example):**
```
/var/mobile/Containers/Data/Application/[UUID]/Documents/dr_saathi.db
/var/mobile/Containers/Data/Application/[UUID]/Documents/patients_auth.db
```

**Characteristics:**
- App-specific sandboxed directory
- Included in iTunes/iCloud backups (if enabled)
- Protected by iOS file system encryption (if device has passcode)
- Accessible only to the app (normally)
- Can be extracted via iTunes backup

**Backup Status:**
- ✅ Backed up to iCloud/iTunes if user has backups enabled
- ⚠️ Backup files are accessible if someone gains access to the backup
- ❌ No application-level encryption

### Android (Mobile - Production)

**Location:** Internal Storage - Application Data Directory  
**Full Path:**
```
/data/data/com.example.dr_saathi/databases/dr_saathi.db
/data/data/com.example.dr_saathi/databases/patients_auth.db
```

**Characteristics:**
- App-private internal storage
- Not accessible without root access (normally)
- Deleted when app is uninstalled
- Backed up to Google Drive if user enabled Android backup
- **NOT encrypted by default on older Android versions**
- Encrypted on Android 10+ with file-based encryption

**Backup Status:**
- ⚠️ Included in Android Auto Backup (if enabled)
- ⚠️ Accessible via ADB if USB debugging is enabled
- ❌ No application-level encryption

### Web Platform

**Location:** Browser IndexedDB  
**Storage Type:** Browser's internal database

**Characteristics:**
- Stored in browser's profile directory
- Varies by browser:
  - Chrome: `~/Library/Application Support/Google/Chrome/Default/IndexedDB/`
  - Safari: `~/Library/Safari/Databases/`
  - Firefox: `~/Library/Application Support/Firefox/Profiles/[profile]/storage/`
- Cleared when user clears browser data
- Limited to 5-50MB typically (browser dependent)
- Accessible via browser DevTools

**Security Concerns:**
- ❌ Easily accessible via browser developer tools
- ❌ No encryption
- ❌ Vulnerable to XSS attacks
- ❌ Can be exported by any browser extension with permissions

### Windows (Desktop)

**Location:** User's AppData directory  
**Full Path:**
```
C:\Users\[username]\AppData\Roaming\com.example.drSaathi\dr_saathi.db
C:\Users\[username]\AppData\Roaming\com.example.drSaathi\patients_auth.db
```

### Linux (Desktop)

**Location:** User's home directory  
**Full Path:**
```
/home/[username]/.local/share/com.example.drSaathi/dr_saathi.db
/home/[username]/.local/share/com.example.drSaathi/patients_auth.db
```

---

## 3. Patient Data Storage

### Main Database (dr_saathi.db)

#### Patients Table

**Table Name:** `patients`

**Stored Data:**
```sql
CREATE TABLE patients(
  id TEXT PRIMARY KEY,              -- Unique patient identifier (UUID)
  firstName TEXT NOT NULL,          -- Patient's first name
  lastName TEXT NOT NULL,           -- Patient's last name
  dateOfBirth TEXT,                 -- Date of birth (ISO format)
  age INTEGER NOT NULL,             -- Calculated age
  phoneNumber TEXT NOT NULL,        -- Contact phone number
  email TEXT,                       -- Email address
  address TEXT,                     -- Physical address
  emergencyContact TEXT,            -- Emergency contact info
  medicalHistory TEXT,              -- Full medical history
  allergies TEXT,                   -- Known allergies
  createdAt TEXT NOT NULL,          -- Record creation timestamp
  updatedAt TEXT NOT NULL,          -- Last update timestamp
  synced INTEGER DEFAULT 0          -- Sync status flag
)
```

**Data Sensitivity Level:** 🔴 **CRITICAL - Highly Sensitive**

**Contains:**
- Full Name (PII)
- Date of Birth (PII)
- Contact Information (PII)
- Medical History (PHI - Protected Health Information)
- Allergies (PHI)
- Emergency Contacts (PII)

#### Patient Authentication Table

**Database:** `patients_auth.db`  
**Table Name:** `patients_auth`

**Stored Data:**
```sql
CREATE TABLE patients_auth (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT UNIQUE NOT NULL,        -- Patient login email
  password_hash TEXT NOT NULL,       -- SHA-256 hashed password
  full_name TEXT NOT NULL,           -- Patient full name
  phone_number TEXT,                 -- Contact number
  date_of_birth TEXT,                -- Date of birth
  gender TEXT,                       -- Gender
  address TEXT,                      -- Address
  emergency_contact_name TEXT,       -- Emergency contact name
  emergency_contact_phone TEXT,      -- Emergency contact phone
  created_at TEXT NOT NULL,          -- Account creation date
  last_login TEXT,                   -- Last login timestamp
  is_active INTEGER DEFAULT 1        -- Account status
)
```

**Data Sensitivity Level:** 🔴 **CRITICAL - Authentication Credentials**

**Contains:**
- Email (PII)
- Password Hash (Security Credential)
- Personal Information (PII/PHI)

**Password Security:**
- Algorithm: SHA-256 (one-way hash)
- ⚠️ No salt used (vulnerable to rainbow table attacks)
- ❌ Should be using bcrypt or Argon2 with salt

### Other Patient-Related Tables

#### Prescriptions Table
```sql
CREATE TABLE prescriptions(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  patient_id TEXT NOT NULL,          -- References patients(id)
  doctor_name TEXT NOT NULL,
  doctor_id TEXT NOT NULL,
  prescription_date TEXT NOT NULL,
  diagnosis TEXT NOT NULL,           -- Medical diagnosis (PHI)
  notes TEXT,                        -- Doctor's notes (PHI)
  status TEXT NOT NULL,
  follow_up_date TEXT,
  is_synced INTEGER DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (patient_id) REFERENCES patients (id)
)
```

**Data Sensitivity:** 🔴 **CRITICAL - Protected Health Information**

#### Medications Table
```sql
CREATE TABLE medications(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  prescription_id INTEGER NOT NULL,
  name TEXT NOT NULL,                -- Medication name
  dosage TEXT NOT NULL,              -- Dosage information
  frequency TEXT NOT NULL,           -- How often to take
  duration TEXT NOT NULL,            -- Treatment duration
  instructions TEXT,                 -- Usage instructions
  form TEXT NOT NULL,                -- Pill, liquid, etc.
  quantity INTEGER NOT NULL,
  generic_name TEXT,
  is_generic INTEGER DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (prescription_id) REFERENCES prescriptions (id)
)
```

**Data Sensitivity:** 🔴 **CRITICAL - Medical Treatment Information**

#### Invoices Table
```sql
CREATE TABLE invoices (
  id TEXT PRIMARY KEY,
  invoice_number TEXT UNIQUE NOT NULL,
  patient_id TEXT NOT NULL,          -- References patients(id)
  patient_name TEXT NOT NULL,
  doctor_id TEXT NOT NULL,
  doctor_name TEXT NOT NULL,
  invoice_date TEXT NOT NULL,
  due_date TEXT NOT NULL,
  subtotal REAL NOT NULL,
  vat_rate REAL NOT NULL,
  vat_amount REAL NOT NULL,
  tax_rate REAL NOT NULL,
  tax_amount REAL NOT NULL,
  total_amount REAL NOT NULL,        -- Financial information
  status TEXT NOT NULL,
  notes TEXT,
  created_at TEXT NOT NULL,
  paid_at TEXT,
  payment_method TEXT,               -- Payment details
  payment_reference TEXT,
  FOREIGN KEY (patient_id) REFERENCES patients (id)
)
```

**Data Sensitivity:** 🟠 **HIGH - Financial Information**

#### SMS Reminders Table
```sql
CREATE TABLE sms_reminders(
  id TEXT PRIMARY KEY,
  patientId TEXT NOT NULL,
  patientName TEXT NOT NULL,
  phoneNumber TEXT NOT NULL,         -- Contact information
  message TEXT NOT NULL,             -- SMS content
  scheduledTime TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL,
  type TEXT NOT NULL,
  status TEXT NOT NULL,
  errorMessage TEXT,
  retryCount INTEGER DEFAULT 0,
  synced INTEGER DEFAULT 0,
  FOREIGN KEY (patientId) REFERENCES patients (id)
)
```

**Data Sensitivity:** 🟠 **HIGH - Communication Records**

---

## 4. Doctor Data Storage

### Doctor Authentication

**Location:** Separate authentication database (similar to patients)  
**Service:** `auth_service.dart`

**Stored Information:**
- Doctor Email
- Password Hash (SHA-256)
- Doctor Name
- License Number (NMC registration)
- Specialization
- Contact Information

**Data Sensitivity:** 🔴 **CRITICAL - Professional Credentials**

### Doctor Profile Data

Stored in:
- Invoices table (doctor_id, doctor_name)
- Prescriptions table (doctor_id, doctor_name)
- Authentication records

**Contains:**
- Professional Identity
- Login Credentials
- Consultation Records
- Financial Records

---

## 5. Data Tables and Schema

### Complete Table List

| Table Name | Purpose | Sensitivity | Encryption Status |
|------------|---------|-------------|-------------------|
| `patients` | Patient demographic & medical data | CRITICAL | ❌ None |
| `patients_auth` | Patient login credentials | CRITICAL | ❌ None |
| `prescriptions` | Medical prescriptions | CRITICAL | ❌ None |
| `medications` | Prescribed medications | CRITICAL | ❌ None |
| `invoices` | Billing records | HIGH | ❌ None |
| `billing_items` | Invoice line items | HIGH | ❌ None |
| `sms_reminders` | SMS notifications | HIGH | ❌ None |
| `sms_templates` | SMS templates | MEDIUM | ❌ None |
| `sync_queue` | Offline sync queue | MEDIUM | ❌ None |

### Database Size Estimates

**Typical Storage Per Record:**
- Patient record: ~2-5 KB
- Prescription: ~1-2 KB
- Invoice: ~1-3 KB
- SMS reminder: ~0.5-1 KB

**For 1,000 Patients:**
- Main database: ~5-10 MB
- Auth database: ~200-500 KB
- **Total: ~5-10 MB**

**For 10,000 Patients:**
- Main database: ~50-100 MB
- Auth database: ~2-5 MB
- **Total: ~50-105 MB**

---

## 6. Security Status

### Current Security Measures

| Security Control | Status | Details |
|------------------|--------|---------|
| **Data Encryption at Rest** | ❌ **NOT IMPLEMENTED** | All data stored in plain text |
| **Data Encryption in Transit** | ⚠️ Partial | HTTPS for network, but N/A for local |
| **Password Hashing** | ⚠️ Weak | SHA-256 without salt |
| **Access Control** | ⚠️ Minimal | OS-level file permissions only |
| **Database Password** | ❌ **NOT SET** | No database password protection |
| **Audit Logging** | ❌ **NOT IMPLEMENTED** | No access logs |
| **Data Backup** | ❌ **NO SYSTEM** | Relies on OS/device backups |
| **Intrusion Detection** | ❌ **NONE** | No monitoring |

### Vulnerability Assessment

#### CRITICAL Vulnerabilities (Immediate Risk)

1. **Unencrypted Patient Data**
   - **Risk Level:** 🔴 CRITICAL
   - **Impact:** Anyone with device access can read all patient data
   - **Attack Vectors:**
     - Physical device access
     - Stolen device
     - Device backup extraction
     - Malware/spyware
     - ADB access (Android)
   - **GDPR/HIPAA Impact:** Major compliance violation

2. **Unencrypted Medical Records**
   - **Risk Level:** 🔴 CRITICAL
   - **Impact:** Protected Health Information (PHI) exposed
   - **Attack Vectors:** Same as above
   - **Legal Impact:** Violations of Nepal IT Act, potential malpractice

3. **Weak Password Hashing**
   - **Risk Level:** 🔴 CRITICAL
   - **Impact:** Passwords vulnerable to rainbow table attacks
   - **Attack Vectors:**
     - Database extraction
     - Rainbow table lookup
     - Brute force (no rate limiting on database)
   - **User Impact:** All patient accounts compromised

4. **No Database Access Control**
   - **Risk Level:** 🔴 HIGH
   - **Impact:** Any app on device (with permissions) can read database
   - **Attack Vectors:**
     - Malicious apps
     - Rooted/jailbroken devices
     - Developer tools

#### HIGH Vulnerabilities

5. **No Audit Trail**
   - **Risk Level:** 🟠 HIGH
   - **Impact:** Cannot detect unauthorized access
   - **Regulatory Impact:** Non-compliance with healthcare regulations

6. **No Backup System**
   - **Risk Level:** 🟠 HIGH
   - **Impact:** Data loss if device fails
   - **Business Impact:** Cannot recover patient records

7. **Browser Storage (Web Platform)**
   - **Risk Level:** 🟠 HIGH
   - **Impact:** Data accessible via DevTools, extensions
   - **Attack Vectors:**
     - XSS attacks
     - Malicious extensions
     - Browser vulnerabilities

---

## 7. Cloud Storage (Currently None)

### Current Status
- ❌ **NO cloud storage or backup**
- ❌ **NO synchronization between devices**
- ❌ **NO remote access capability**
- ❌ **NO disaster recovery**

### Sync Queue Table
```sql
CREATE TABLE sync_queue(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  patientId TEXT NOT NULL,
  operation TEXT NOT NULL,
  data TEXT,
  createdAt TEXT NOT NULL,
  FOREIGN KEY (patientId) REFERENCES patients (id)
)
```

**Purpose:** Intended for future cloud sync, but NOT currently implemented  
**Status:** Table exists but sync functionality not active

### Implications

**Positive:**
- No cloud service provider to comply with
- No third-party data processing agreements needed
- No cross-border data transfer concerns (for now)

**Negative:**
- No backup if device is lost/damaged
- Cannot access data from multiple devices
- No collaboration between healthcare providers
- No central management
- No disaster recovery plan

---

## 8. Critical Security Issues

### Issue 1: Plain Text Medical Data

**Severity:** 🔴 **CRITICAL**

**Problem:**
All patient medical records are stored in plain text SQLite databases that can be:
- Opened with any SQLite browser tool
- Extracted from device backups
- Read by anyone with file system access
- Stolen via malware

**Example - How Easy It Is:**
```bash
# On macOS (development)
cd ~/Library/Containers/com.example.drSaathi/Data/Documents/
sqlite3 dr_saathi.db
sqlite> SELECT firstName, lastName, medicalHistory, allergies FROM patients;
# ALL patient data displayed in plain text!
```

**Legal/Regulatory Impact:**
- ❌ Violates Nepal IT Act 2000
- ❌ Violates Electronic Transaction Act 2008
- ❌ Violates patient confidentiality requirements
- ❌ Potential GDPR violations (if EU citizens' data)
- ❌ Medical negligence liability

### Issue 2: Weak Password Security

**Severity:** 🔴 **CRITICAL**

**Current Implementation:**
```dart
String _hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
```

**Problems:**
- No salt added to passwords
- Vulnerable to rainbow table attacks
- Same password always produces same hash
- No key stretching (fast to brute force)

**What Happens If Database Is Stolen:**
1. Attacker gets `patients_auth.db`
2. Extracts password hashes
3. Uses rainbow table to crack common passwords
4. Within minutes, weak passwords are revealed
5. Attacker gains access to patient portal

### Issue 3: No Access Monitoring

**Severity:** 🟠 **HIGH**

**Problem:**
- No logs of who accessed what data
- No detection of suspicious activity
- No audit trail for compliance
- Cannot investigate security incidents
- Cannot prove compliance during audits

### Issue 4: Backup Vulnerability

**Severity:** 🟠 **HIGH**

**iOS Backup Exposure:**
```
Patient installs app → Creates account → App backs up to iCloud
Attacker compromises iCloud account → Downloads backup
Extracts dr_saathi.db → All patient data exposed
```

**Android Backup Exposure:**
```
Patient uses app → Android Auto Backup to Google Drive
Attacker compromises Google account → Downloads backup
Extracts database files → All patient data exposed
```

### Issue 5: Multi-User Device Risk

**Severity:** 🟠 **MEDIUM-HIGH**

**Scenario:**
- Family members share a tablet/computer
- Doctor uses app on shared clinic computer
- IT staff has admin access to computers

**Risk:**
Anyone with physical access can:
1. Navigate to database directory
2. Copy database files
3. Open with SQLite browser
4. View all patient data

---

## 9. Recommendations

### IMMEDIATE Actions (Critical - Within 1 Week)

#### 1. Implement Database Encryption

**Solution:** Use SQLCipher (encrypted SQLite)

**Implementation:**
```yaml
# pubspec.yaml
dependencies:
  sqflite_sqlcipher: ^2.2.0  # Encrypted SQLite
```

**Code Changes:**
```dart
// Add database password
Future<Database> _initDatabase() async {
  String path = join(await getDatabasesPath(), 'dr_saathi.db');
  
  // Generate secure key (store securely, not in code!)
  String databasePassword = await SecureStorage.getDatabaseKey();
  
  return await openDatabase(
    path,
    password: databasePassword,  // SQLCipher encryption
    version: 5,
    onCreate: _createDatabase,
  );
}
```

**Benefits:**
- ✅ AES-256 encryption
- ✅ Entire database encrypted
- ✅ Cannot be opened without password
- ✅ FIPS compliant

**Estimated Effort:** 3-5 days  
**Cost:** Free (open source)

#### 2. Fix Password Hashing

**Solution:** Use bcrypt or Argon2

**Implementation:**
```dart
import 'package:bcrypt/bcrypt.dart';

String _hashPassword(String password) {
  // Generate hash with automatic salt
  return BCrypt.hashpw(password, BCrypt.gensalt());
}

bool _verifyPassword(String password, String hash) {
  return BCrypt.checkpw(password, hash);
}
```

**Benefits:**
- ✅ Secure password hashing
- ✅ Automatic salt generation
- ✅ Configurable work factor
- ✅ Industry standard

**Estimated Effort:** 1 day  
**Cost:** Free

#### 3. Add Sensitive Data Markers

**Solution:** Add metadata to identify sensitive fields

```sql
-- Add sensitivity classification
ALTER TABLE patients ADD COLUMN data_classification TEXT DEFAULT 'sensitive';
```

**Create data classification policy document**

### SHORT-TERM Actions (Within 1 Month)

#### 4. Implement Audit Logging

**Create audit log table:**
```sql
CREATE TABLE audit_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp TEXT NOT NULL,
  user_id TEXT NOT NULL,
  user_type TEXT NOT NULL,  -- 'patient' or 'doctor'
  action TEXT NOT NULL,      -- 'view', 'update', 'delete'
  table_name TEXT NOT NULL,
  record_id TEXT NOT NULL,
  ip_address TEXT,
  device_info TEXT,
  success INTEGER NOT NULL,
  error_message TEXT
);
```

**Log all access:**
```dart
await _logAccess(
  userId: currentUserId,
  action: 'view',
  tableName: 'patients',
  recordId: patientId,
);
```

**Estimated Effort:** 1 week  
**Cost:** Development time

#### 5. Implement Secure Backup

**Solution:** Encrypted cloud backup system

**Options:**
- AWS S3 with encryption
- Google Cloud Storage with encryption
- Azure Blob Storage with encryption

**Requirements:**
- End-to-end encryption
- Encrypted before leaving device
- Secure key management
- Regular backup schedule
- Restore capability

**Estimated Effort:** 2-3 weeks  
**Cost:** Cloud storage fees (~$10-50/month for small scale)

#### 6. Add Data Retention Policies

**Implementation:**
```dart
// Delete data older than retention period
Future<void> enforceRetentionPolicy() async {
  // Medical records: 5 years (Nepal law)
  await db.delete(
    'patients',
    where: 'updatedAt < ?',
    whereArgs: [fiveYearsAgo.toIso8601String()],
  );
  
  // Financial records: 7 years (Nepal tax law)
  await db.delete(
    'invoices',
    where: 'invoice_date < ?',
    whereArgs: [sevenYearsAgo.toIso8601String()],
  );
}
```

### MEDIUM-TERM Actions (Within 3 Months)

#### 7. Implement Role-Based Access Control

**Create permissions table:**
```sql
CREATE TABLE user_permissions (
  id INTEGER PRIMARY KEY,
  user_id TEXT NOT NULL,
  user_type TEXT NOT NULL,
  permission TEXT NOT NULL,
  resource TEXT,
  granted_at TEXT NOT NULL
);
```

#### 8. Add Data Export/Delete Features

**For GDPR/Patient Rights Compliance:**

```dart
// Export all patient data
Future<Map<String, dynamic>> exportPatientData(String patientId);

// Delete all patient data
Future<void> deletePatientData(String patientId);
```

#### 9. Implement Database Backup Encryption

**Even local backups should be encrypted**

#### 10. Security Penetration Testing

**Hire security firm to:**
- Test database security
- Attempt data extraction
- Test encryption
- Validate access controls

**Cost:** NPR 150,000 - 400,000

### LONG-TERM Actions (Within 6 Months)

#### 11. Cloud Sync with Encryption

**Implement proper cloud synchronization**

#### 12. Multi-Factor Authentication

**Add 2FA for sensitive access**

#### 13. Hardware Security Module (HSM)

**For production deployment:**
- Store encryption keys in HSM
- Hardware-based security

#### 14. Regular Security Audits

**Quarterly security reviews**

---

## 10. Data Access Methods

### Legitimate Access (Application)

**Patient Portal:**
1. Patient logs in via `patient_login.dart`
2. Credentials verified against `patients_auth.db`
3. Access granted to patient's own records only
4. Data displayed in app UI

**Doctor Portal:**
1. Doctor logs in via `doctor_login.dart`
2. Credentials verified against doctor auth database
3. Access to assigned patients only
4. Can view/edit medical records

### Development Access

**Via Code:**
```dart
// Using DatabaseService
final db = DatabaseService();
final patients = await db.getAllPatients();
```

**Via SQLite Command Line:**
```bash
# Open database
cd ~/Library/Containers/com.example.drSaathi/Data/Documents/
sqlite3 dr_saathi.db

# Query data
sqlite> .tables
sqlite> SELECT * FROM patients;
sqlite> .exit
```

### Unauthorized Access (Vulnerabilities)

**Method 1: Physical Device Access**
```bash
# If someone gets physical access to device
# Navigate to database folder
# Copy databases
# Open with DB Browser for SQLite
# ALL DATA EXPOSED
```

**Method 2: Backup Extraction**
```bash
# Extract iOS backup
idevicebackup2 backup --full ~/backup/
# Find database in backup
# Extract and open
# ALL DATA EXPOSED
```

**Method 3: ADB (Android Debug Bridge)**
```bash
# If USB debugging enabled
adb pull /data/data/com.example.dr_saathi/databases/dr_saathi.db
# Open extracted database
# ALL DATA EXPOSED
```

**Method 4: Malware**
- Malicious app with storage permissions
- Reads database files
- Exfiltrates data to attacker

**Method 5: Browser DevTools (Web)**
```javascript
// In browser console
indexedDB.open('dr_saathi.db').onsuccess = (e) => {
  const db = e.target.result;
  // Access all data
};
```

---

## 11. Compliance Implications

### Data Protection Violations

| Requirement | Current Status | Risk |
|-------------|----------------|------|
| Data must be encrypted | ❌ Not encrypted | CRITICAL |
| Access must be logged | ❌ No audit logs | HIGH |
| Passwords must be secure | ⚠️ Weak hashing | CRITICAL |
| Backups must be secure | ❌ Not implemented | HIGH |
| Data retention must be enforced | ❌ Not implemented | MEDIUM |
| Patient data rights | ⚠️ Partial | HIGH |
| Breach notification plan | ❌ None | HIGH |

### Potential Legal Consequences

**If Data Breach Occurs:**

1. **Criminal Liability:**
   - Nepal IT Act 2000: Up to 2 years imprisonment
   - Unauthorized data access charges
   - Cyber crime prosecution

2. **Civil Liability:**
   - Patient lawsuits for privacy violations
   - Compensation for damages
   - Unlimited liability potential

3. **Regulatory Penalties:**
   - Ministry of Health fines
   - License suspension/revocation
   - Mandatory public disclosure

4. **Professional Consequences:**
   - Nepal Medical Council disciplinary action
   - Professional license suspension
   - Reputation damage

5. **Financial Impact:**
   - Direct fines: NPR 100,000 - 5,000,000
   - Legal defense costs: NPR 500,000+
   - Compensation payments: Variable
   - Business closure risk

---

## 12. Action Plan Summary

### Immediate (Week 1)
- [ ] Review this document with management
- [ ] Assess security budget
- [ ] Engage security consultant
- [ ] Plan database encryption implementation

### Short-term (Month 1)
- [ ] Implement SQLCipher encryption
- [ ] Fix password hashing
- [ ] Add audit logging
- [ ] Create backup system

### Medium-term (Month 3)
- [ ] RBAC implementation
- [ ] Data export/delete features
- [ ] Security penetration testing
- [ ] Compliance audit

### Long-term (Month 6)
- [ ] Cloud sync with encryption
- [ ] Multi-factor authentication
- [ ] HSM integration
- [ ] Regular security audits

---

## 13. Incident Response

### If Data Breach Suspected

**IMMEDIATE ACTIONS:**

1. **Isolate:**
   - Disconnect affected devices
   - Disable remote access
   - Stop sync operations

2. **Assess:**
   - Determine what data was accessed
   - Identify how breach occurred
   - Document timeline

3. **Notify:**
   - Legal counsel (immediately)
   - Affected patients (within 72 hours)
   - Regulatory authorities (as required)
   - Law enforcement (if criminal)

4. **Contain:**
   - Change all passwords
   - Revoke access credentials
   - Patch vulnerability

5. **Document:**
   - Create incident report
   - Preserve evidence
   - Log all actions taken

**Contact Information:**
- Security Team: [To be assigned]
- Legal Counsel: [To be assigned]
- Cyber Police (Nepal): 1930
- Ministry of Health: 01-4262802

---

## 14. Conclusion

### Current State

Dr. Saathi stores all patient and doctor data in **unencrypted SQLite databases** on the local device. This creates **CRITICAL security and compliance risks**.

### Required Actions

**MUST IMPLEMENT IMMEDIATELY:**
1. Database encryption (SQLCipher)
2. Proper password hashing (bcrypt/Argon2)
3. Audit logging
4. Secure backup system
5. Access controls

### Timeline
- **Minimum:** 1 month for critical fixes
- **Full compliance:** 3-6 months

### Investment Required
- **One-time:** NPR 200,000 - 500,000
- **Annual:** NPR 120,000 - 300,000

### Risk Level
🔴 **CRITICAL** - Current implementation exposes patients to significant privacy and security risks

---

## Appendix A: Database Schema Export

**To export current schema:**
```bash
sqlite3 dr_saathi.db .schema > schema.sql
```

## Appendix B: Data Size Calculator

**Estimate your data storage needs:**

| Entity | Count | Size per Record | Total |
|--------|-------|-----------------|-------|
| Patients | 1,000 | 3 KB | 3 MB |
| Prescriptions | 5,000 | 1.5 KB | 7.5 MB |
| Invoices | 3,000 | 2 KB | 6 MB |
| **Total** | | | **~17 MB** |

## Appendix C: Encryption Performance Impact

**SQLCipher Performance:**
- Write operations: ~10-15% slower
- Read operations: ~5-10% slower
- Database size: ~5-10% larger
- **Trade-off:** Acceptable for critical security

---

**END OF DOCUMENT**

*This document contains sensitive information about data storage and security vulnerabilities. Treat as CONFIDENTIAL.*
