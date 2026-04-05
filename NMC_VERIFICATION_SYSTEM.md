# NMC Verification System

## Overview
The Dr. Saathi platform now includes a Nepal Medical Council (NMC) registration verification system to ensure only legitimate, registered doctors can create accounts in the Doctor Portal app.

## How It Works

### 1. **Database Storage**
- All verified NMC registration numbers are stored in a dedicated database table: `nmc_verified_doctors`
- This table is shared between the Doctor Portal and Admin apps
- Each record includes:
  - NMC registration number (unique)
  - Doctor's name
  - Specialization
  - Registration date
  - Expiry date
  - Status (active/expired/suspended)
  - Data source
  - Update timestamps

### 2. **Doctor Registration Flow**
When a doctor attempts to register in the Doctor Portal:
1. They enter their NMC registration number in the signup form
2. The system automatically verifies the number against the NMC database
3. If the number is valid and active → registration proceeds
4. If the number is invalid or inactive → registration is blocked with an error message

### 3. **Admin Management**
Administrators can manage the NMC registry through the Admin app:
- **View Statistics**: Total, active, expired, and suspended registrations
- **Search**: Find doctors by NMC number or name
- **Add Individual Records**: Manually add single NMC records
- **Bulk Import**: Import multiple records at once using pipe-delimited format
- **Update Status**: Change registration status (active/expired/suspended)
- **View History**: See all updates and imports

## Admin Access

### Location
Admin App → User Management → **NMC Registry Management**

### Features

#### Adding Individual Records
1. Click "Add Record" button
2. Fill in the form:
   - NMC Number (required) - e.g., NMC12345
   - Doctor Name (required)
   - Specialization (optional)
   - Registration Date (optional)
   - Expiry Date (optional)
3. Click "Add" to save

#### Bulk Import
1. Click "Bulk Import" button
2. Paste records in the following format (one per line):
   ```
   NMC_NUMBER|DOCTOR_NAME|SPECIALIZATION|REG_DATE|EXPIRY_DATE
   ```
   Example:
   ```
   NMC12345|Dr. Ram Sharma|Cardiology|2020-01-15|2030-01-15
   NMC23456|Dr. Sita Thapa|Pediatrics|2019-06-20|2029-06-20
   ```
3. Click "Import" to process

#### Updating Status
1. Expand any record card
2. Click "Update Status"
3. Select new status: Active, Expired, or Suspended
4. Changes take effect immediately

#### Searching
- Use the search bar at the top
- Search by NMC number or doctor name
- Results update in real-time

## Yearly Updates

### Current Implementation
The system is designed for yearly updates of the NMC registry. Currently includes:
- Automatic expiry detection based on expiry dates
- Update logging to track all changes
- Bulk import functionality for annual refreshes

### Recommended Update Process
1. **Obtain Official NMC Registry** (yearly)
   - Contact Nepal Medical Council
   - Request current list of registered doctors
   - Preferred format: CSV or Excel

2. **Prepare Import File**
   - Convert to pipe-delimited format
   - Include: NMC number, name, specialization, registration date, expiry date
   - Example format shown above

3. **Bulk Import via Admin App**
   - Use the Bulk Import feature
   - System will update existing records and add new ones
   - All changes are logged

4. **Review & Verify**
   - Check statistics after import
   - Review update logs
   - Test a few sample numbers

### Automated Expiry Check
The system can automatically mark expired registrations:
- Checks expiry_date field against current date
- Updates status from "active" to "expired"
- Can be run manually or scheduled

## Sample Data

For testing purposes, 5 sample NMC records are automatically loaded:
- NMC12345 - Dr. Ram Prasad Sharma (General Medicine)
- NMC23456 - Dr. Sita Kumari Thapa (Pediatrics)
- NMC34567 - Dr. Bikram Bahadur Rana (Cardiology)
- NMC45678 - Dr. Anita Gurung (Gynecology)
- NMC56789 - Dr. Krishna Shrestha (Orthopedics)

**IMPORTANT**: Remove sample data before production deployment by:
1. Opening Admin app
2. Going to NMC Registry Management
3. Manually deleting sample records OR clearing the database

## Security Considerations

1. **Database Access**: Both Doctor Portal and Admin apps access the same `doctors.db` database
2. **Validation**: Only active NMC numbers allow registration
3. **Admin Control**: Only admin users can modify the NMC registry
4. **Audit Trail**: All updates are logged in `nmc_update_logs` table

## Technical Details

### Database Tables

#### nmc_verified_doctors
```sql
CREATE TABLE nmc_verified_doctors (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nmc_number TEXT UNIQUE NOT NULL,
  doctor_name TEXT NOT NULL,
  specialization TEXT,
  registration_date TEXT,
  expiry_date TEXT,
  status TEXT NOT NULL,
  verified_at TEXT NOT NULL,
  last_updated TEXT NOT NULL,
  data_source TEXT,
  additional_info TEXT
)
```

#### nmc_update_logs
```sql
CREATE TABLE nmc_update_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  update_date TEXT NOT NULL,
  total_records_added INTEGER,
  total_records_updated INTEGER,
  update_source TEXT,
  status TEXT NOT NULL,
  notes TEXT,
  created_at TEXT NOT NULL
)
```

### Services

#### Doctor Portal
- **File**: `lib/services/nmc_verification_service.dart`
- **Purpose**: Verify NMC numbers during registration
- **Initialization**: Automatically initialized in `main.dart`

#### Admin App
- **File**: `lib/services/nmc_admin_service.dart`
- **Purpose**: Manage NMC registry (add, update, delete records)
- **Screen**: `lib/screens/nmc_registry_management.dart`

### Status Values
- `active`: Valid, current registration
- `expired`: Registration past expiry date
- `suspended`: Temporarily suspended by NMC
- `revoked`: Permanently revoked (if needed)

## Troubleshooting

### Doctor Can't Register
1. Verify NMC number is in the system (check Admin app)
2. Check status is "active"
3. Ensure NMC number format matches exactly (uppercase)

### Bulk Import Fails
1. Check format: use pipe (|) as delimiter
2. Ensure at least NMC number and name are provided
3. Remove empty lines
4. Check for special characters

### Database Issues
1. Both apps use the same database file: `doctors.db`
2. Located in app's databases directory
3. Can be cleared and rebuilt if needed (will lose all data)

## Future Enhancements

Potential improvements for future versions:
1. API integration with Nepal Medical Council
2. Automatic yearly synchronization
3. Email notifications for expiring registrations
4. QR code verification
5. Mobile number verification
6. Photo verification
7. Export functionality for reports

## Support

For issues or questions regarding the NMC verification system:
1. Check this documentation
2. Review sample data and test the flow
3. Verify admin access to NMC Registry Management
4. Check database connectivity between apps

## Compliance

This system is designed to:
- Prevent unauthorized doctor registrations
- Maintain up-to-date doctor credentials
- Provide audit trails for regulatory compliance
- Protect patient safety by verifying doctor legitimacy
