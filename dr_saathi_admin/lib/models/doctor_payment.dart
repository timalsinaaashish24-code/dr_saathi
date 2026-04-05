/*
 * Dr. Saathi - Doctor Payment Model
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * Licensed under the MIT License.
 */

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
}

enum PaymentMethod {
  bankTransfer,
  wallet,
  check,
}

class DoctorPayment {
  final String id;
  final String doctorId;
  final String? appointmentId;
  final String? invoiceId;
  final String patientPaymentId; // Reference to patient's payment
  final double totalAmount; // Total paid by patient
  final double platformCommission; // Platform's cut
  final double platformCommissionRate; // Percentage
  final double doctorAmount; // Amount doctor receives
  final double taxDeducted; // TDS or other taxes
  final double netPayable; // Final amount to doctor
  final PaymentStatus status;
  final PaymentMethod paymentMethod;
  final String? doctorBankName;
  final String? doctorAccountNumber;
  final String? doctorAccountName;
  final String? transactionId;
  final String? transactionProof;
  final DateTime paymentDate;
  final DateTime createdAt;
  final DateTime? processedAt;
  final DateTime? completedAt;
  final String? processedBy;
  final String? failureReason;
  final String? remarks;

  DoctorPayment({
    required this.id,
    required this.doctorId,
    this.appointmentId,
    this.invoiceId,
    required this.patientPaymentId,
    required this.totalAmount,
    required this.platformCommission,
    required this.platformCommissionRate,
    required this.doctorAmount,
    required this.taxDeducted,
    required this.netPayable,
    required this.status,
    required this.paymentMethod,
    this.doctorBankName,
    this.doctorAccountNumber,
    this.doctorAccountName,
    this.transactionId,
    this.transactionProof,
    required this.paymentDate,
    required this.createdAt,
    this.processedAt,
    this.completedAt,
    this.processedBy,
    this.failureReason,
    this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'appointmentId': appointmentId,
      'invoiceId': invoiceId,
      'patientPaymentId': patientPaymentId,
      'totalAmount': totalAmount,
      'platformCommission': platformCommission,
      'platformCommissionRate': platformCommissionRate,
      'doctorAmount': doctorAmount,
      'taxDeducted': taxDeducted,
      'netPayable': netPayable,
      'status': status.index,
      'paymentMethod': paymentMethod.index,
      'doctorBankName': doctorBankName,
      'doctorAccountNumber': doctorAccountNumber,
      'doctorAccountName': doctorAccountName,
      'transactionId': transactionId,
      'transactionProof': transactionProof,
      'paymentDate': paymentDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'processedBy': processedBy,
      'failureReason': failureReason,
      'remarks': remarks,
    };
  }

  factory DoctorPayment.fromMap(Map<String, dynamic> map) {
    return DoctorPayment(
      id: map['id'],
      doctorId: map['doctorId'],
      appointmentId: map['appointmentId'],
      invoiceId: map['invoiceId'],
      patientPaymentId: map['patientPaymentId'],
      totalAmount: map['totalAmount'],
      platformCommission: map['platformCommission'],
      platformCommissionRate: map['platformCommissionRate'],
      doctorAmount: map['doctorAmount'],
      taxDeducted: map['taxDeducted'],
      netPayable: map['netPayable'],
      status: PaymentStatus.values[map['status']],
      paymentMethod: PaymentMethod.values[map['paymentMethod']],
      doctorBankName: map['doctorBankName'],
      doctorAccountNumber: map['doctorAccountNumber'],
      doctorAccountName: map['doctorAccountName'],
      transactionId: map['transactionId'],
      transactionProof: map['transactionProof'],
      paymentDate: DateTime.parse(map['paymentDate']),
      createdAt: DateTime.parse(map['createdAt']),
      processedAt: map['processedAt'] != null 
          ? DateTime.parse(map['processedAt']) 
          : null,
      completedAt: map['completedAt'] != null 
          ? DateTime.parse(map['completedAt']) 
          : null,
      processedBy: map['processedBy'],
      failureReason: map['failureReason'],
      remarks: map['remarks'],
    );
  }

  DoctorPayment copyWith({
    String? id,
    String? doctorId,
    String? appointmentId,
    String? invoiceId,
    String? patientPaymentId,
    double? totalAmount,
    double? platformCommission,
    double? platformCommissionRate,
    double? doctorAmount,
    double? taxDeducted,
    double? netPayable,
    PaymentStatus? status,
    PaymentMethod? paymentMethod,
    String? doctorBankName,
    String? doctorAccountNumber,
    String? doctorAccountName,
    String? transactionId,
    String? transactionProof,
    DateTime? paymentDate,
    DateTime? createdAt,
    DateTime? processedAt,
    DateTime? completedAt,
    String? processedBy,
    String? failureReason,
    String? remarks,
  }) {
    return DoctorPayment(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      appointmentId: appointmentId ?? this.appointmentId,
      invoiceId: invoiceId ?? this.invoiceId,
      patientPaymentId: patientPaymentId ?? this.patientPaymentId,
      totalAmount: totalAmount ?? this.totalAmount,
      platformCommission: platformCommission ?? this.platformCommission,
      platformCommissionRate: platformCommissionRate ?? this.platformCommissionRate,
      doctorAmount: doctorAmount ?? this.doctorAmount,
      taxDeducted: taxDeducted ?? this.taxDeducted,
      netPayable: netPayable ?? this.netPayable,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      doctorBankName: doctorBankName ?? this.doctorBankName,
      doctorAccountNumber: doctorAccountNumber ?? this.doctorAccountNumber,
      doctorAccountName: doctorAccountName ?? this.doctorAccountName,
      transactionId: transactionId ?? this.transactionId,
      transactionProof: transactionProof ?? this.transactionProof,
      paymentDate: paymentDate ?? this.paymentDate,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      completedAt: completedAt ?? this.completedAt,
      processedBy: processedBy ?? this.processedBy,
      failureReason: failureReason ?? this.failureReason,
      remarks: remarks ?? this.remarks,
    );
  }
}

// Configuration for platform commission rates
class CommissionConfig {
  final double defaultRate; // Default commission rate (e.g., 30%)
  final double taxRate; // Tax/VAT rate (e.g., 15%)
  final double minCommission; // Minimum commission per transaction
  final double maxCommission; // Maximum commission per transaction

  const CommissionConfig({
    this.defaultRate = 30.0,
    this.taxRate = 15.0,
    this.minCommission = 50.0,
    this.maxCommission = 5000.0,
  });

  // Calculate commission amount
  double calculateCommission(double totalAmount) {
    double commission = totalAmount * (defaultRate / 100);
    if (commission < minCommission) return minCommission;
    if (commission > maxCommission) return maxCommission;
    return commission;
  }

  // Calculate tax deduction
  double calculateTax(double doctorAmount) {
    return doctorAmount * (taxRate / 100);
  }

  // Calculate net payable to doctor
  double calculateNetPayable(double totalAmount) {
    double commission = calculateCommission(totalAmount);
    double doctorAmount = totalAmount - commission;
    double tax = calculateTax(doctorAmount);
    return doctorAmount - tax;
  }
}
