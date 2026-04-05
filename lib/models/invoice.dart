import 'billing_item.dart';

class Invoice {
  final String id;
  final String invoiceNumber;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final List<BillingItem> items;
  final double subtotal;
  final double vatRate;
  final double vatAmount;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;
  final InvoiceStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? paymentMethod;
  final String? paymentReference;

  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.invoiceDate,
    required this.dueDate,
    required this.items,
    required this.subtotal,
    required this.vatRate,
    required this.vatAmount,
    required this.taxRate,
    required this.taxAmount,
    required this.totalAmount,
    required this.status,
    this.notes,
    required this.createdAt,
    this.paidAt,
    this.paymentMethod,
    this.paymentReference,
  });

  // Calculate invoice totals from items
  factory Invoice.create({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required List<BillingItem> items,
    required double vatRate,
    required double taxRate,
    String? notes,
    int paymentTermDays = 30,
  }) {
    final now = DateTime.now();
    final dueDate = now.add(Duration(days: paymentTermDays));
    final invoiceNumber = _generateInvoiceNumber();
    
    // Calculate subtotal
    final subtotal = items.fold<double>(
      0.0,
      (sum, item) => sum + item.totalAmount,
    );
    
    // Calculate VAT and Tax
    final vatAmount = subtotal * (vatRate / 100);
    final taxAmount = subtotal * (taxRate / 100);
    final totalAmount = subtotal + vatAmount + taxAmount;

    return Invoice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      invoiceNumber: invoiceNumber,
      patientId: patientId,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
      invoiceDate: now,
      dueDate: dueDate,
      items: items,
      subtotal: subtotal,
      vatRate: vatRate,
      vatAmount: vatAmount,
      taxRate: taxRate,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      status: InvoiceStatus.pending,
      notes: notes,
      createdAt: now,
    );
  }

  static String _generateInvoiceNumber() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final timestamp = now.millisecondsSinceEpoch.toString().substring(8);
    return 'INV$year$month$timestamp';
  }

  // Copy with method for updates
  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
    DateTime? invoiceDate,
    DateTime? dueDate,
    List<BillingItem>? items,
    double? subtotal,
    double? vatRate,
    double? vatAmount,
    double? taxRate,
    double? taxAmount,
    double? totalAmount,
    InvoiceStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? paidAt,
    String? paymentMethod,
    String? paymentReference,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      vatRate: vatRate ?? this.vatRate,
      vatAmount: vatAmount ?? this.vatAmount,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'patient_id': patientId,
      'patient_name': patientName,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'invoice_date': invoiceDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'vat_rate': vatRate,
      'vat_amount': vatAmount,
      'tax_rate': taxRate,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'status': status.toString().split('.').last,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'payment_method': paymentMethod,
      'payment_reference': paymentReference,
    };
  }

  // Create from JSON
  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      invoiceNumber: json['invoice_number'],
      patientId: json['patient_id'],
      patientName: json['patient_name'],
      doctorId: json['doctor_id'],
      doctorName: json['doctor_name'],
      invoiceDate: DateTime.parse(json['invoice_date']),
      dueDate: DateTime.parse(json['due_date']),
      items: (json['items'] as List<dynamic>)
          .map((item) => BillingItem.fromJson(item))
          .toList(),
      subtotal: json['subtotal'].toDouble(),
      vatRate: json['vat_rate'].toDouble(),
      vatAmount: json['vat_amount'].toDouble(),
      taxRate: json['tax_rate'].toDouble(),
      taxAmount: json['tax_amount'].toDouble(),
      totalAmount: json['total_amount'].toDouble(),
      status: InvoiceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      paymentMethod: json['payment_method'],
      paymentReference: json['payment_reference'],
    );
  }

  // Check if invoice is overdue
  bool get isOverdue {
    return status == InvoiceStatus.pending && DateTime.now().isAfter(dueDate);
  }

  // Get days until due or overdue
  int get daysUntilDue {
    return dueDate.difference(DateTime.now()).inDays;
  }

  // Get formatted status display
  String get statusDisplay {
    switch (status) {
      case InvoiceStatus.pending:
        return isOverdue ? 'Overdue' : 'Pending';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
      case InvoiceStatus.draft:
        return 'Draft';
    }
  }

  @override
  String toString() {
    return 'Invoice(number: $invoiceNumber, patient: $patientName, total: Rs $totalAmount, status: $statusDisplay)';
  }
}

enum InvoiceStatus {
  draft,
  pending,
  paid,
  cancelled,
}