# Dr. Saathi - Commission Structure

## Current Commission Rates

### Platform Commission: **30%**
### Doctor's Share: **70%** (before tax)
### Tax/VAT: **15%** (deducted from doctor's amount)

---

## Payment Breakdown Examples

### Example 1: NPR 1,000 Consultation

```
Patient Pays:              NPR 1,000.00
                          ─────────────
Platform Commission (30%): NPR   300.00  ← Platform Revenue
Doctor's Amount (70%):     NPR   700.00
  Less: Tax/VAT (15%):     NPR   105.00  ← Tax Payment
                          ─────────────
Doctor Receives (Net):     NPR   595.00  ← Doctor Gets
```

**Breakdown:**
- Platform keeps: **NPR 300** (30%)
- Government tax: **NPR 105** (10.5% of total)
- Doctor receives: **NPR 595** (59.5% of total)

---

### Example 2: NPR 500 Consultation

```
Patient Pays:              NPR   500.00
                          ─────────────
Platform Commission (30%): NPR   150.00
Doctor's Amount (70%):     NPR   350.00
  Less: Tax/VAT (15%):     NPR    52.50
                          ─────────────
Doctor Receives (Net):     NPR   297.50
```

---

### Example 3: NPR 2,000 Consultation

```
Patient Pays:              NPR 2,000.00
                          ─────────────
Platform Commission (30%): NPR   600.00
Doctor's Amount (70%):     NPR 1,400.00
  Less: Tax/VAT (15%):     NPR   210.00
                          ─────────────
Doctor Receives (Net):     NPR 1,190.00
```

---

### Example 4: NPR 5,000 Consultation

```
Patient Pays:              NPR 5,000.00
                          ─────────────
Platform Commission (30%): NPR 1,500.00
Doctor's Amount (70%):     NPR 3,500.00
  Less: Tax/VAT (15%):     NPR   525.00
                          ─────────────
Doctor Receives (Net):     NPR 2,975.00
```

---

### Example 5: NPR 10,000 Consultation

```
Patient Pays:              NPR 10,000.00
                          ─────────────
Platform Commission (30%): NPR  3,000.00
Doctor's Amount (70%):     NPR  7,000.00
  Less: Tax/VAT (15%):     NPR  1,050.00
                          ─────────────
Doctor Receives (Net):     NPR  5,950.00
```

---

## Summary Table

| Patient Pays | Platform (30%) | Doctor Gross (70%) | Tax/VAT (15%) | **Doctor Net** | Doctor %* |
|--------------|----------------|--------------------|---------------|----------------|-----------|
| NPR 500      | NPR 150        | NPR 350            | NPR 52.50     | **NPR 297.50** | 59.5%     |
| NPR 1,000    | NPR 300        | NPR 700            | NPR 105       | **NPR 595**    | 59.5%     |
| NPR 2,000    | NPR 600        | NPR 1,400          | NPR 210       | **NPR 1,190**  | 59.5%     |
| NPR 5,000    | NPR 1,500      | NPR 3,500          | NPR 525       | **NPR 2,975**  | 59.5%     |
| NPR 10,000   | NPR 3,000      | NPR 7,000          | NPR 1,050     | **NPR 5,950**  | 59.5%     |

*Doctor % = Doctor Net as percentage of Patient Payment

---

## Revenue Split

For every NPR 100 paid by patient:

```
┌─────────────────────────────────┐
│  NPR 100 (Patient Payment)      │
└─────────────────────────────────┘
         │
         ├─► NPR 30.00 → Platform (30%)
         │
         ├─► NPR 10.50 → Government Tax (10.5%)
         │
         └─► NPR 59.50 → Doctor (59.5%)
```

---

## Monthly Revenue Example

**Scenario:** 1,000 consultations averaging NPR 1,000 each

```
Total Patient Payments:     NPR 1,000,000
                           ──────────────
Platform Revenue (30%):     NPR   300,000
Tax Collected (10.5%):      NPR   105,000
Doctors' Earnings (59.5%):  NPR   595,000
```

**Platform Annual Revenue:** NPR 3,600,000

---

## Commission Limits

- **Minimum Commission**: NPR 50 per transaction
- **Maximum Commission**: NPR 5,000 per transaction

**Note:** These limits apply only to the platform commission, not to the doctor's share.

---

## Tax Compliance

- **15% Tax/VAT** is deducted from doctor's earnings
- Platform collects and remits tax to government
- Doctors receive monthly statements for tax records
- Annual tax reports provided for filing

---

## Configuration

To change these rates in the system:

```dart
final commissionConfig = CommissionConfig(
  defaultRate: 30.0,      // 30% platform commission
  taxRate: 15.0,          // 15% tax/VAT
  minCommission: 50.0,    // Min NPR 50
  maxCommission: 5000.0,  // Max NPR 5,000
);
```

---

**Updated:** February 2026  
**Copyright © 2025 Dr. Saathi Healthcare Pvt. Ltd.**
