/*
 * Dr. Saathi - Bank Transfer Model
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * Licensed under the MIT License.
 */

enum BankTransferStatus {
  pending,
  verified,
  rejected,
  expired,
}

class BankTransfer {
  final String id;
  final String patientId;
  final String? appointmentId;
  final String? invoiceId;
  final double amount;
  final String senderBankName;
  final String senderAccountName;
  final String senderAccountNumber;
  final String receiverBankName;
  final String receiverAccountNumber;
  final String transactionId;
  final String? transactionProofPath;
  final BankTransferStatus status;
  final DateTime transferDate;
  final DateTime createdAt;
  final DateTime? verifiedAt;
  final String? verifiedBy;
  final String? rejectionReason;
  final String? remarks;

  BankTransfer({
    required this.id,
    required this.patientId,
    this.appointmentId,
    this.invoiceId,
    required this.amount,
    required this.senderBankName,
    required this.senderAccountName,
    required this.senderAccountNumber,
    required this.receiverBankName,
    required this.receiverAccountNumber,
    required this.transactionId,
    this.transactionProofPath,
    required this.status,
    required this.transferDate,
    required this.createdAt,
    this.verifiedAt,
    this.verifiedBy,
    this.rejectionReason,
    this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'appointmentId': appointmentId,
      'invoiceId': invoiceId,
      'amount': amount,
      'senderBankName': senderBankName,
      'senderAccountName': senderAccountName,
      'senderAccountNumber': senderAccountNumber,
      'receiverBankName': receiverBankName,
      'receiverAccountNumber': receiverAccountNumber,
      'transactionId': transactionId,
      'transactionProofPath': transactionProofPath,
      'status': status.index,
      'transferDate': transferDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'verifiedBy': verifiedBy,
      'rejectionReason': rejectionReason,
      'remarks': remarks,
    };
  }

  factory BankTransfer.fromMap(Map<String, dynamic> map) {
    return BankTransfer(
      id: map['id'],
      patientId: map['patientId'],
      appointmentId: map['appointmentId'],
      invoiceId: map['invoiceId'],
      amount: map['amount'],
      senderBankName: map['senderBankName'],
      senderAccountName: map['senderAccountName'],
      senderAccountNumber: map['senderAccountNumber'],
      receiverBankName: map['receiverBankName'],
      receiverAccountNumber: map['receiverAccountNumber'],
      transactionId: map['transactionId'],
      transactionProofPath: map['transactionProofPath'],
      status: BankTransferStatus.values[map['status']],
      transferDate: DateTime.parse(map['transferDate']),
      createdAt: DateTime.parse(map['createdAt']),
      verifiedAt: map['verifiedAt'] != null 
          ? DateTime.parse(map['verifiedAt']) 
          : null,
      verifiedBy: map['verifiedBy'],
      rejectionReason: map['rejectionReason'],
      remarks: map['remarks'],
    );
  }

  BankTransfer copyWith({
    String? id,
    String? patientId,
    String? appointmentId,
    String? invoiceId,
    double? amount,
    String? senderBankName,
    String? senderAccountName,
    String? senderAccountNumber,
    String? receiverBankName,
    String? receiverAccountNumber,
    String? transactionId,
    String? transactionProofPath,
    BankTransferStatus? status,
    DateTime? transferDate,
    DateTime? createdAt,
    DateTime? verifiedAt,
    String? verifiedBy,
    String? rejectionReason,
    String? remarks,
  }) {
    return BankTransfer(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      appointmentId: appointmentId ?? this.appointmentId,
      invoiceId: invoiceId ?? this.invoiceId,
      amount: amount ?? this.amount,
      senderBankName: senderBankName ?? this.senderBankName,
      senderAccountName: senderAccountName ?? this.senderAccountName,
      senderAccountNumber: senderAccountNumber ?? this.senderAccountNumber,
      receiverBankName: receiverBankName ?? this.receiverBankName,
      receiverAccountNumber: receiverAccountNumber ?? this.receiverAccountNumber,
      transactionId: transactionId ?? this.transactionId,
      transactionProofPath: transactionProofPath ?? this.transactionProofPath,
      status: status ?? this.status,
      transferDate: transferDate ?? this.transferDate,
      createdAt: createdAt ?? this.createdAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      remarks: remarks ?? this.remarks,
    );
  }
}
