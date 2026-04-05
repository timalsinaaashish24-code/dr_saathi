# Sample Invoice in Patient Account - Dr. Saathi App

## Overview
This document shows how invoices appear in a patient's account in the Dr. Saathi Flutter application.

## Invoice Display Structure

### 1. Patient Invoice List View
The patient sees their invoices in a clean, organized list with the following features:

#### Filter Tabs
- **All**: Shows all invoices
- **Pending**: Shows unpaid invoices
- **Paid**: Shows completed payments
- **Overdue**: Shows invoices past their due date

#### Invoice Summary Cards
Each invoice is displayed as a card showing:
- Invoice number (e.g., INV241234567)
- Doctor name
- Status badge (Pending/Paid/Overdue)
- Total amount in Rupees
- Due date
- Action buttons (View Details, Mark Paid)

### 2. Sample Invoice Example

```
┌─────────────────────────────────────────────────────────┐
│ Invoice Summary                                         │
├─────────────────────────────────────────────────────────┤
│ Total: Rs 2,850.00  │ Paid: Rs 1,200.00  │ Pending: Rs 1,650.00 │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ INV24102345678                            [OVERDUE] 🔴  │
│ Dr. Rajesh Kumar                                        │
│                                                         │
│ Amount              │ Due Date                          │
│ Rs 1,650.00         │ 5/10/2024                        │
│                     │ 7 days overdue                    │
│                                                         │
│ [👁 View Details]   [💳 Mark Paid]                     │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ INV24102345679                              [PAID] 🟢   │
│ Dr. Priya Sharma                                        │
│                                                         │
│ Amount              │ Due Date                          │
│ Rs 1,200.00         │ 15/10/2024                       │
│                                                         │
│ [👁 View Details]                                      │
└─────────────────────────────────────────────────────────┘
```

### 3. Detailed Invoice View Dialog

When a patient taps "View Details", they see a comprehensive breakdown:

```
┌─────────────────────────────────────────────────────────┐
│ Invoice Details                                    [✖] │
├─────────────────────────────────────────────────────────┤
│ INV24102345678                                          │
│                                                         │
│ Doctor: Dr. Rajesh Kumar                                │
│ Date: 5/9/2024                                          │
│ Due Date: 5/10/2024                                     │
│ Status: Overdue                                         │
│                                                         │
│ ─────────────────────────────────────────────────────── │
│                                                         │
│ Items:                                                  │
│ Consultation Fee          1x      Rs 800.00            │
│ Blood Test - CBC          1x      Rs 450.00            │
│ Prescription Medicine     2x      Rs 125.00            │
│                                                         │
│ ─────────────────────────────────────────────────────── │
│                                                         │
│ Subtotal:                         Rs 1,500.00          │
│ VAT (5.0%):                       Rs 75.00             │
│ Tax (5.0%):                       Rs 75.00             │
│ ═══════════════════════════════════════════════════════ │
│ Total:                            Rs 1,650.00          │
│                                                         │
│ Notes:                                                  │
│ Regular health checkup and follow-up consultation.      │
│ Please bring previous reports for next visit.          │
└─────────────────────────────────────────────────────────┘
```

### 4. Mark as Paid Dialog

When patient taps "Mark Paid":

```
┌─────────────────────────────────────────────────────────┐
│ Mark as Paid                                            │
├─────────────────────────────────────────────────────────┤
│ Invoice: INV24102345678                                 │
│ Amount: Rs 1,650.00                                     │
│                                                         │
│ Payment Method: [Cash ▼]                               │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ Cash                                                │ │
│ │ Bank Transfer                                       │ │
│ │ Online Payment                                      │ │
│ │ Card Payment                                        │ │
│ │ Mobile Payment                                      │ │
│ │ Other                                               │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│ Payment Reference (Optional):                           │
│ ┌─────────────────────────────────────────────────────┐ │
│ │ Transaction ID, Receipt number, etc.                │ │
│ └─────────────────────────────────────────────────────┘ │
│                                                         │
│                              [Cancel] [Mark as Paid]   │
└─────────────────────────────────────────────────────────┘
```

## Key Features

### Visual Design Elements
- **Clean Card-Based Layout**: Each invoice is in a separate card with rounded corners
- **Status Color Coding**: 
  - 🟢 Green for Paid invoices
  - 🟠 Orange for Pending invoices
  - 🔴 Red for Overdue invoices
- **Summary Statistics**: Shows total, paid, and pending amounts at the top
- **Interactive Elements**: Buttons for viewing details and marking payments

### Functional Features
- **Filtering**: Patients can filter invoices by status
- **Detailed Breakdown**: Full itemized view of services and charges
- **Payment Tracking**: Patients can mark invoices as paid with payment method
- **Overdue Alerts**: Clear indication when payments are late
- **Refresh Capability**: Pull-to-refresh or manual refresh button

### Data Structure
Each invoice contains:
- Unique invoice number (auto-generated)
- Patient and doctor information
- Itemized billing with quantities and prices
- Tax calculations (VAT and other taxes)
- Payment terms and due dates
- Status tracking
- Payment method and reference tracking
- Notes for additional information

This comprehensive invoice system provides patients with full transparency into their medical billing while making it easy to track and manage payments.