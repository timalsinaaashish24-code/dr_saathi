# Dr. Saathi - Payment System Integration Guide

## 🎯 Complete Payment Flow

```
Patient Pays → Verified → Doctor Payment Created → Processed → Doctor Receives
```

## ✅ What's Been Created

### 1. **Bank Transfer System** (Patient → Platform)
- Patient submission screen
- Admin verification screen
- Database & services

### 2. **Doctor Payment System** (Platform → Doctor)
- Payment calculation & tracking
- Automated payment creation
- Database & services

### 3. **UI Screens**
- `doctor_earnings_screen.dart` - Doctor dashboard
- `admin_process_payments_screen.dart` - Admin processing panel
- `submit_bank_transfer_screen.dart` - Patient payment
- `admin_verify_transfers_screen.dart` - Payment verification

## 📋 Integration Checklist

### Step 1: Initialize Database Tables

In your `database_service.dart`:

```dart
import '../services/bank_transfer_service.dart';
import '../services/doctor_payment_service.dart';

// In onCreate method:
await BankTransferService.createTable(db);
await DoctorPaymentService.createTable(db);
```

### Step 2: Connect Patient Payment to Doctor Payment

In `admin_verify_transfers_screen.dart`, uncomment and update lines 112-122:

```dart
// Get doctor details from your appointment/invoice
final appointment = await getAppointmentById(transfer.appointmentId);
final doctor = await getDoctorById(appointment.doctorId);

await _paymentOrchestrator.onPatientPaymentVerified(
  patientTransferId: transfer.id,
  doctorId: doctor.id,
  appointmentId: transfer.appointmentId,
  invoiceId: transfer.invoiceId,
  doctorBankName: doctor.bankName,
  doctorAccountNumber: doctor.accountNumber,
  doctorAccountName: doctor.accountName,
);
```

### Step 3: Add Navigation Links

#### For Doctors:
```dart
// In doctor dashboard
ListTile(
  leading: const Icon(Icons.account_balance_wallet),
  title: const Text('My Earnings'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorEarningsScreen(
          doctorId: currentDoctor.id,
          doctorName: currentDoctor.name,
        ),
      ),
    );
  },
),
```

#### For Admins:
```dart
// In admin dashboard
ListTile(
  leading: const Icon(Icons.payments),
  title: const Text('Process Payments'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminProcessPaymentsScreen(
          adminId: currentAdmin.id,
        ),
      ),
    );
  },
),
```

#### For Patients:
```dart
// In payment options screen
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmitBankTransferScreen(
          patientId: currentPatient.id,
          amount: consultationFee,
          appointmentId: appointment.id,
        ),
      ),
    );
  },
  child: const Text('Pay via Bank Transfer'),
),
```

### Step 4: Configure Commission Rates

Update in your app initialization:

```dart
final commissionConfig = CommissionConfig(
  defaultRate: 30.0,      // 30% platform commission
  taxRate: 15.0,          // 15% tax/VAT
  minCommission: 50.0,    // Min NPR 50
  maxCommission: 5000.0,  // Max NPR 5,000
);
```

### Step 5: Optional - Schedule Automatic Processing

For automated daily payment processing:

```dart
import 'dart:async';

// In your app initialization or background service:
Timer.periodic(Duration(days: 1), (timer) async {
  final orchestrator = PaymentOrchestrator();
  await orchestrator.scheduledPaymentRun('SYSTEM_AUTO');
});
```

## 🔗 Complete Flow Example

### Scenario: Patient pays NPR 1,000 for consultation

#### 1. Patient Submits Payment
```dart
Navigator.push(context, MaterialPageRoute(
  builder: (_) => SubmitBankTransferScreen(
    patientId: 'PAT123',
    amount: 1000.0,
    appointmentId: 'APT456',
  ),
));
```

#### 2. Admin Verifies Payment
- Admin sees pending transfer in verification screen
- Clicks "Verify" button
- System automatically:
  - Updates transfer status to "Verified"
  - Creates doctor payment with:
    - Platform commission: NPR 300 (30%)
    - Doctor amount: NPR 700 (70%)
    - Tax: NPR 105 (15% of 700)
    - Net to doctor: NPR 595

#### 3. Doctor Sees Pending Payment
- Doctor opens earnings dashboard
- Sees pending payment of NPR 595
- Status: "Pending"

#### 4. Admin Processes Payment
- Admin opens payment processing screen
- Clicks "Process Payment" or "Process All"
- System initiates bank transfer to doctor
- Status changes to "Processing" → "Completed"

#### 5. Doctor Receives Money
- Doctor receives NPR 595 in bank account
- Payment shows as "Completed" in dashboard
- Transaction ID visible

## 🎨 UI Navigation Structure

```
Main App
├── Patient Portal
│   ├── Payment Options
│   └── → Submit Bank Transfer Screen
│
├── Doctor Portal
│   ├── Dashboard
│   └── → Doctor Earnings Screen
│       ├── All Payments
│       ├── Pending Payments
│       └── Completed Payments
│
└── Admin Portal
    ├── Dashboard
    ├── → Verify Bank Transfers
    │   ├── Pending (with verify button)
    │   ├── Verified
    │   └── Rejected
    └── → Process Doctor Payments
        ├── Pending (with process button)
        ├── Processing
        └── Completed
```

## 🔍 Testing Checklist

- [ ] Patient can submit bank transfer
- [ ] Admin can see pending transfers
- [ ] Admin verification creates doctor payment
- [ ] Doctor can see earnings dashboard
- [ ] Commission calculated correctly (30% platform, 15% tax)
- [ ] Admin can process doctor payments
- [ ] Payment status updates correctly
- [ ] Transaction IDs recorded
- [ ] Monthly reports show correct data

## 📱 Required Dependencies

Make sure these are in your `pubspec.yaml`:

```yaml
dependencies:
  sqflite: ^2.0.0
  uuid: ^3.0.0
  intl: ^0.18.0
  image_picker: ^0.8.0
  dio: ^5.0.0
```

## 🚨 Important Notes

1. **Doctor Bank Details**: Ensure all doctors have bank details in their profiles
2. **Appointment Linking**: Transfers must be linked to appointments to get doctor ID
3. **Security**: Bank account numbers are stored - ensure database is encrypted
4. **Tax Compliance**: 15% tax is automatically deducted and tracked
5. **Transaction IDs**: Currently mock IDs - integrate with actual bank API

## 🔐 Security Checklist

- [ ] Encrypt database containing bank details
- [ ] Validate all payment amounts
- [ ] Verify user permissions before showing sensitive data
- [ ] Log all payment transactions
- [ ] Implement rate limiting on payment submissions
- [ ] Add 2FA for admin payment processing

## 📊 Reports Available

### For Doctors:
- Total earnings (all time)
- Monthly earnings breakdown
- Pending vs completed payments
- Commission and tax deductions

### For Platform:
- Total platform revenue
- Total tax collected
- Payment processing stats
- Monthly/annual reports

## 🆘 Troubleshooting

### Payment not created after verification
- Check if appointment has doctorId
- Verify doctor has bank details
- Check console for errors
- Ensure database tables exist

### Commission calculation wrong
- Verify CommissionConfig is initialized
- Check defaultRate = 30.0
- Check taxRate = 15.0

### UI screens not loading
- Ensure all dependencies installed
- Run `flutter pub get`
- Check imports in files

## 📞 Need Help?

Review the documentation:
- `BANK_TRANSFER_SYSTEM.md` - Patient payments
- `DOCTOR_PAYMENT_SYSTEM.md` - Doctor payments
- `COMMISSION_STRUCTURE.md` - Commission rates

---

**System Ready!** 🚀

All components are created and documented. Follow the integration steps above to connect everything together.
