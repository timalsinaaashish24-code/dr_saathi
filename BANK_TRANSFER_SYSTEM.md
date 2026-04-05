# Dr. Saathi - Bank Transfer Payment System

## Overview
The Bank Transfer Payment System allows patients to pay for medical services directly from their bank accounts to the Dr. Saathi platform's bank accounts, **without any third-party payment gateway fees**.

## Key Benefits
- ✅ **Zero Transaction Fees** - No eSewa/Khalti 2-3% fees
- ✅ **Works with ALL Nepali Banks** - Any bank account can be used
- ✅ **Secure** - No sensitive bank credentials required
- ✅ **Verifiable** - Admin verification with proof of payment
- ✅ **Trackable** - Complete audit trail of all transactions

## How It Works

### For Patients:

1. **View Payment Amount**
   - Patient sees the amount they need to pay

2. **Choose Platform Bank Account**
   - Platform displays its bank accounts (NIBL, Nabil, SCB, etc.)
   - Patient can copy account details easily

3. **Make Bank Transfer**
   - Patient goes to their bank (app/branch/ATM)
   - Transfers exact amount to platform's account
   - Saves transaction receipt/screenshot

4. **Submit Transfer Details**
   - Fill in transfer information:
     - Their bank name
     - Account holder name
     - Account number
     - Transaction ID
     - Transfer date
   - Upload proof of payment (screenshot/receipt)
   - Submit for verification

5. **Wait for Verification**
   - Admin verifies payment within 24 hours
   - Patient receives notification
   - Service is activated

### For Admins:

1. **Review Pending Transfers**
   - View all submitted transfer requests
   - See transfer details and proof

2. **Verify Transfer**
   - Check if amount matches
   - Verify transaction ID in bank statement
   - Confirm receipt of funds
   - Click "Verify" to approve

3. **Reject if Needed**
   - If details don't match or payment not received
   - Provide reason for rejection
   - Patient can resubmit with correct details

## Setup Instructions

### 1. Configure Your Bank Accounts

Edit `lib/config/bank_accounts.dart`:

```dart
static const List<BankAccount> accounts = [
  BankAccount(
    bankName: 'Your Bank Name',
    accountName: 'Your Company Name',
    accountNumber: 'YOUR_ACCOUNT_NUMBER',
    branch: 'Branch Name',
    swiftCode: 'SWIFT_CODE',
    bankCode: 'BANK_CODE',
    isPrimary: true,  // Set one as primary
  ),
  // Add more bank accounts as needed
];
```

### 2. Initialize Database Table

Add to your database initialization in `database_service.dart`:

```dart
import '../services/bank_transfer_service.dart';

// In your database onCreate method:
await BankTransferService.createTable(db);
```

### 3. Add to Navigation

**Patient Side:**
```dart
// In payment options screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SubmitBankTransferScreen(
      patientId: currentPatient.id,
      amount: amountToPay,
      appointmentId: appointment?.id,
      invoiceId: invoice?.id,
    ),
  ),
);
```

**Admin Side:**
```dart
// In admin dashboard
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AdminVerifyTransfersScreen(
      adminId: currentAdmin.id,
    ),
  ),
);
```

## Files Created

### Models
- `lib/models/bank_transfer.dart` - Bank transfer data model

### Services
- `lib/services/bank_transfer_service.dart` - Business logic for transfers

### Configuration
- `lib/config/bank_accounts.dart` - Platform bank account details

### Screens
- `lib/screens/submit_bank_transfer_screen.dart` - Patient submission UI
- `lib/screens/admin_verify_transfers_screen.dart` - Admin verification UI

## Database Schema

```sql
CREATE TABLE bank_transfers (
  id TEXT PRIMARY KEY,
  patientId TEXT NOT NULL,
  appointmentId TEXT,
  invoiceId TEXT,
  amount REAL NOT NULL,
  senderBankName TEXT NOT NULL,
  senderAccountName TEXT NOT NULL,
  senderAccountNumber TEXT NOT NULL,
  receiverBankName TEXT NOT NULL,
  receiverAccountNumber TEXT NOT NULL,
  transactionId TEXT NOT NULL,
  transactionProofPath TEXT,
  status INTEGER NOT NULL,
  transferDate TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  verifiedAt TEXT,
  verifiedBy TEXT,
  rejectionReason TEXT,
  remarks TEXT
);
```

## Transfer Status Flow

```
PENDING → VERIFIED (Admin approves)
   ↓
REJECTED (Admin rejects with reason)
   ↓
EXPIRED (Auto-expire after 7 days if not verified)
```

## Security Considerations

1. **No Sensitive Data Storage**
   - Platform never stores bank passwords or PINs
   - Only transaction details and proof images stored

2. **Admin Verification**
   - All transfers manually verified by admin
   - Prevents fraudulent claims

3. **Audit Trail**
   - Complete history of all transfers
   - Verifier identity tracked

4. **Proof Required**
   - Upload of transaction receipt mandatory
   - Visual verification possible

## Comparison with Payment Gateways

| Feature | Bank Transfer | eSewa/Khalti |
|---------|---------------|--------------|
| Transaction Fee | **0%** | 2-3.5% |
| Bank Coverage | **All Banks** | Wallet only |
| Verification Time | 24 hours | Instant |
| Setup Cost | Free | Free |
| Monthly Fee | None | Possible minimums |
| User Convenience | Manual | Instant |

## Best Practices

### For Patients:
1. Transfer **exact amount** shown
2. Save transaction receipt immediately
3. Upload clear, readable proof image
4. Enter correct transaction ID

### For Admins:
1. Verify within 24 hours
2. Cross-check with bank statement
3. Provide clear rejection reasons if needed
4. Keep communication with patient open

## Future Enhancements

Possible improvements:
- [ ] SMS/Email notifications on status change
- [ ] Auto-verification via bank API (if available)
- [ ] QR code for easy bank details sharing
- [ ] Batch verification for multiple transfers
- [ ] Export transfer reports
- [ ] Integration with accounting software

## Cost Savings Example

**Monthly Scenario:**
- 1000 transactions
- Average transaction: NPR 1,000
- Total volume: NPR 1,000,000

**With Payment Gateway (2.5% fee):**
- Fees: NPR 25,000/month
- Annual cost: NPR 300,000

**With Bank Transfer:**
- Fees: NPR 0
- **Annual savings: NPR 300,000**

## Support

For issues or questions:
- Check patient transfer status in admin panel
- Review rejection reasons for failed transfers
- Ensure bank account details are up-to-date
- Contact platform support for technical issues

---

**Copyright © 2025 Dr. Saathi Healthcare Pvt. Ltd.**
