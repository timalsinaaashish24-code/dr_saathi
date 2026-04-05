# Dr. Saathi - Automated Doctor Payment System

## Overview
The Automated Doctor Payment System ensures doctors receive their earnings directly in their bank accounts after patient payments are verified. The platform handles commission deduction, tax calculation, and automatic fund transfers.

## 💰 How Money Flows

```
Patient Payment (NPR 1,000)
         ↓
   [Verification]
         ↓
┌─────────────────────────┐
│ Automatic Calculation   │
├─────────────────────────┤
│ Platform Commission: 15%│ → NPR 150 (Platform)
│ Doctor Amount: 85%      │ → NPR 850
│ Tax Deduction (TDS): 1% │ → NPR 8.50
│ Net to Doctor:          │ → NPR 841.50
└─────────────────────────┘
         ↓
   [Auto Transfer]
         ↓
   Doctor's Bank Account
```

## Key Features

✅ **Automatic Payment Creation** - Triggered when patient payment verified  
✅ **Transparent Commission** - Clear breakdown of all deductions  
✅ **Tax Compliance** - Automatic TDS calculation  
✅ **Direct Bank Transfer** - Money goes straight to doctor's account  
✅ **Real-time Tracking** - Doctors see all earnings and payments  
✅ **Audit Trail** - Complete payment history for all parties

## Commission Structure

### Default Configuration:
- **Platform Commission**: 15% of total amount
- **TDS (Tax)**: 1% of doctor's amount
- **Minimum Commission**: NPR 50
- **Maximum Commission**: NPR 5,000

### Example Calculations:

| Patient Pays | Commission (15%) | Doctor Gross (85%) | Tax (1%) | Doctor Net |
|--------------|------------------|--------------------|----------|------------|
| NPR 500      | NPR 50*          | NPR 450            | NPR 4.50 | NPR 445.50 |
| NPR 1,000    | NPR 150          | NPR 850            | NPR 8.50 | NPR 841.50 |
| NPR 5,000    | NPR 750          | NPR 4,250          | NPR 42.50| NPR 4,207.50|
| NPR 10,000   | NPR 1,500        | NPR 8,500          | NPR 85   | NPR 8,415  |

*Minimum commission applies

## System Workflow

### 1. Patient Pays
- Patient makes payment via eSewa/Khalti/Bank Transfer
- Payment recorded in system

### 2. Admin Verifies (for bank transfers)
- Admin checks and verifies payment
- Payment status changes to "Verified"

### 3. Automatic Trigger
```dart
// When payment is verified, this automatically runs:
await paymentOrchestrator.onPatientPaymentVerified(
  patientTransferId: transferId,
  doctorId: appointmentDoctorId,
  doctorBankName: doctor.bankName,
  doctorAccountNumber: doctor.accountNumber,
  doctorAccountName: doctor.accountName,
);
```

### 4. Doctor Payment Created
- System calculates commission and taxes
- Creates pending payment for doctor
- Doctor sees "Pending" status

### 5. Payment Processing
- Admin/System processes pending payments
- Initiates bank transfer to doctor
- Can be manual or automated (daily/weekly)

### 6. Payment Completed
- Bank confirms transfer
- Status updated to "Completed"
- Doctor receives notification

## Setup Instructions

### 1. Configure Commission Rates

In your app initialization:

```dart
final commissionConfig = CommissionConfig(
  defaultRate: 15.0,      // 15% platform commission
  taxRate: 1.0,           // 1% TDS
  minCommission: 50.0,    // Minimum NPR 50
  maxCommission: 5000.0,  // Maximum NPR 5,000
);

final paymentOrchestrator = PaymentOrchestrator(
  commissionConfig: commissionConfig,
);
```

### 2. Initialize Database

Add to `database_service.dart`:

```dart
import '../services/doctor_payment_service.dart';

// In onCreate method:
await DoctorPaymentService.createTable(db);
```

### 3. Integrate with Payment Verification

When verifying patient bank transfer:

```dart
// After verifying patient payment
await paymentOrchestrator.onPatientPaymentVerified(
  patientTransferId: transfer.id,
  doctorId: doctor.id,
  appointmentId: appointment.id,
  invoiceId: invoice.id,
  doctorBankName: doctor.bankName,
  doctorAccountNumber: doctor.accountNumber,
  doctorAccountName: doctor.accountName,
);
```

### 4. Schedule Automatic Payment Processing

Set up daily/weekly automated runs:

```dart
// Run daily at midnight
Timer.periodic(Duration(days: 1), (timer) async {
  await paymentOrchestrator.scheduledPaymentRun('SYSTEM');
});
```

Or manual processing via admin panel.

## Files Created

### Models
- `lib/models/doctor_payment.dart` - Payment data model and commission config

### Services
- `lib/services/doctor_payment_service.dart` - Payment management
- `lib/services/payment_orchestrator.dart` - Automation and workflows

## Database Schema

```sql
CREATE TABLE doctor_payments (
  id TEXT PRIMARY KEY,
  doctorId TEXT NOT NULL,
  appointmentId TEXT,
  invoiceId TEXT,
  patientPaymentId TEXT NOT NULL,
  totalAmount REAL NOT NULL,
  platformCommission REAL NOT NULL,
  platformCommissionRate REAL NOT NULL,
  doctorAmount REAL NOT NULL,
  taxDeducted REAL NOT NULL,
  netPayable REAL NOT NULL,
  status INTEGER NOT NULL,
  paymentMethod INTEGER NOT NULL,
  doctorBankName TEXT,
  doctorAccountNumber TEXT,
  doctorAccountName TEXT,
  transactionId TEXT,
  transactionProof TEXT,
  paymentDate TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  processedAt TEXT,
  completedAt TEXT,
  processedBy TEXT,
  failureReason TEXT,
  remarks TEXT
);
```

## Payment Status Flow

```
PENDING → PROCESSING → COMPLETED
   ↓
FAILED (with reason)
   ↓
CANCELLED (if needed)
```

## API Examples

### Create Doctor Payment
```dart
final payment = await doctorPaymentService.createDoctorPayment(
  doctorId: 'DOC123',
  patientPaymentId: 'PAY456',
  totalAmount: 1000.0,
  doctorBankName: 'Nepal Investment Bank',
  doctorAccountNumber: '1234567890',
  doctorAccountName: 'Dr. John Doe',
);
```

### Get Doctor Earnings
```dart
final stats = await doctorPaymentService.getDoctorEarningStats('DOC123');
print('Total Earned: NPR ${stats['total_earned']}');
print('Pending: NPR ${stats['pending_amount']}');
print('Completed: NPR ${stats['completed_amount']}');
```

### Process Pending Payments
```dart
await paymentOrchestrator.processPendingPayments(
  adminId: 'ADMIN001',
  limit: 10, // Process 10 at a time
);
```

### Get Monthly Earnings Report
```dart
final earnings = await doctorPaymentService.getMonthlyEarnings(
  'DOC123',
  DateTime(2025, 2), // February 2025
);
```

## Security & Compliance

### 1. Data Security
- Doctor bank details encrypted in database
- Secure payment processing
- Audit logs for all transactions

### 2. Tax Compliance
- Automatic TDS calculation
- Records maintained for tax filing
- Monthly/annual reports available

### 3. Financial Tracking
- Complete transaction history
- Reconciliation support
- Export capabilities for accounting

## Doctor Benefits

1. **Automatic Payments** - No manual payment requests needed
2. **Transparent Deductions** - See exactly what's deducted and why
3. **Fast Processing** - Get paid within 24-48 hours of patient payment
4. **Bank Transfer** - Direct to account, no checks or cash handling
5. **Earning Reports** - Track monthly income easily

## Platform Benefits

1. **Automated Process** - No manual payment calculations
2. **Consistent Commission** - Fair and transparent rates
3. **Tax Compliance** - Automatic TDS calculation
4. **Audit Trail** - Complete payment history
5. **Scalable** - Handle thousands of transactions

## Troubleshooting

### Payment Stuck in Pending
- Check if doctor's bank details are correct
- Verify internet banking is set up
- Run manual processing

### Payment Failed
- Check failure reason in payment details
- Verify bank account is active
- Retry with correct information

### Commission Calculation Issues
- Verify commission config is loaded
- Check for minimum/maximum commission limits
- Review tax rate settings

## Future Enhancements

- [ ] Multiple commission tiers (by specialty/experience)
- [ ] Bonus/incentive structure
- [ ] Instant payment options (24/7)
- [ ] International doctor payments
- [ ] Cryptocurrency payment option
- [ ] Automatic tax filing integration

## Support

For payment-related issues:
- Doctors: Check payment history in doctor dashboard
- Platform: Review payment logs in admin panel
- Technical: Contact development team

---

**Copyright © 2025 Dr. Saathi Healthcare Pvt. Ltd.**

## Example Monthly Report

```
Dr. Saathi - Doctor Earnings Report
Month: February 2025
Doctor: Dr. Ram Kumar Sharma (DOC123)

Consultations: 45
Total Patient Payments: NPR 45,000.00

Breakdown:
├─ Platform Commission (15%): NPR 6,750.00
├─ Doctor Gross (85%): NPR 38,250.00
├─ TDS (1%): NPR 382.50
└─ Net Earnings: NPR 37,867.50

Payment Status:
├─ Completed: NPR 35,000.00 (42 payments)
├─ Pending: NPR 2,867.50 (3 payments)
└─ Failed: NPR 0.00 (0 payments)

Bank Transfers:
├─ 15 Feb 2025: NPR 15,000.00 (TXN123456)
├─ 22 Feb 2025: NPR 12,000.00 (TXN123457)
└─ 28 Feb 2025: NPR 8,000.00 (TXN123458)
```
