/*
 * Dr. Saathi - Fee Distribution Model
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * Licensed under the MIT License.
 */

class FeeDistribution {
  final String id;
  final String transactionId;
  final String serviceType; // 'consultation', 'prescription', 'health_card', etc.
  final double totalAmount;
  final Map<String, FeeBreakdown> breakdown;
  final String currency;
  final DateTime createdAt;
  final FeeDistributionStatus status;
  final String? doctorId;
  final String? patientId;
  final Map<String, dynamic> metadata;

  FeeDistribution({
    required this.id,
    required this.transactionId,
    required this.serviceType,
    required this.totalAmount,
    required this.breakdown,
    this.currency = 'NPR',
    required this.createdAt,
    this.status = FeeDistributionStatus.pending,
    this.doctorId,
    this.patientId,
    this.metadata = const {},
  });

  factory FeeDistribution.fromJson(Map<String, dynamic> json) {
    return FeeDistribution(
      id: json['id'],
      transactionId: json['transactionId'],
      serviceType: json['serviceType'],
      totalAmount: json['totalAmount'].toDouble(),
      breakdown: (json['breakdown'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, FeeBreakdown.fromJson(value)),
      ),
      currency: json['currency'] ?? 'NPR',
      createdAt: DateTime.parse(json['createdAt']),
      status: FeeDistributionStatus.values.byName(json['status']),
      doctorId: json['doctorId'],
      patientId: json['patientId'],
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'serviceType': serviceType,
      'totalAmount': totalAmount,
      'breakdown': breakdown.map((key, value) => MapEntry(key, value.toJson())),
      'currency': currency,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'doctorId': doctorId,
      'patientId': patientId,
      'metadata': metadata,
    };
  }

  double get platformFee => breakdown['platform']?.amount ?? 0.0;
  double get doctorFee => breakdown['doctor']?.amount ?? 0.0;
  double get processingFee => breakdown['processing']?.amount ?? 0.0;
  double get taxAmount => breakdown['tax']?.amount ?? 0.0;
}

class FeeBreakdown {
  final String stakeholder; // 'platform', 'doctor', 'processing', 'tax', etc.
  final double amount;
  final double percentage;
  final String description;
  final PayoutStatus payoutStatus;
  final DateTime? payoutDate;
  final String? payoutReference;

  FeeBreakdown({
    required this.stakeholder,
    required this.amount,
    required this.percentage,
    required this.description,
    this.payoutStatus = PayoutStatus.pending,
    this.payoutDate,
    this.payoutReference,
  });

  factory FeeBreakdown.fromJson(Map<String, dynamic> json) {
    return FeeBreakdown(
      stakeholder: json['stakeholder'],
      amount: json['amount'].toDouble(),
      percentage: json['percentage'].toDouble(),
      description: json['description'],
      payoutStatus: PayoutStatus.values.byName(json['payoutStatus']),
      payoutDate: json['payoutDate'] != null ? DateTime.parse(json['payoutDate']) : null,
      payoutReference: json['payoutReference'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stakeholder': stakeholder,
      'amount': amount,
      'percentage': percentage,
      'description': description,
      'payoutStatus': payoutStatus.name,
      'payoutDate': payoutDate?.toIso8601String(),
      'payoutReference': payoutReference,
    };
  }
}

enum FeeDistributionStatus {
  pending,
  confirmed,
  distributed,
  failed,
  refunded,
}

enum PayoutStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
}

class FeeDistributionConfig {
  final String serviceType;
  final Map<String, FeeRule> rules;
  final double minimumAmount;
  final double maximumAmount;
  final bool isActive;

  FeeDistributionConfig({
    required this.serviceType,
    required this.rules,
    this.minimumAmount = 0.0,
    this.maximumAmount = double.infinity,
    this.isActive = true,
  });

  factory FeeDistributionConfig.fromJson(Map<String, dynamic> json) {
    return FeeDistributionConfig(
      serviceType: json['serviceType'],
      rules: (json['rules'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, FeeRule.fromJson(value)),
      ),
      minimumAmount: json['minimumAmount']?.toDouble() ?? 0.0,
      maximumAmount: json['maximumAmount']?.toDouble() ?? double.infinity,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceType': serviceType,
      'rules': rules.map((key, value) => MapEntry(key, value.toJson())),
      'minimumAmount': minimumAmount,
      'maximumAmount': maximumAmount,
      'isActive': isActive,
    };
  }
}

class FeeRule {
  final String stakeholder;
  final double percentage;
  final double? fixedAmount;
  final FeeCalculationType calculationType;
  final String description;
  final Map<String, dynamic> conditions;

  FeeRule({
    required this.stakeholder,
    required this.percentage,
    this.fixedAmount,
    this.calculationType = FeeCalculationType.percentage,
    required this.description,
    this.conditions = const {},
  });

  factory FeeRule.fromJson(Map<String, dynamic> json) {
    return FeeRule(
      stakeholder: json['stakeholder'],
      percentage: json['percentage'].toDouble(),
      fixedAmount: json['fixedAmount']?.toDouble(),
      calculationType: FeeCalculationType.values.byName(json['calculationType']),
      description: json['description'],
      conditions: json['conditions'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stakeholder': stakeholder,
      'percentage': percentage,
      'fixedAmount': fixedAmount,
      'calculationType': calculationType.name,
      'description': description,
      'conditions': conditions,
    };
  }
}

enum FeeCalculationType {
  percentage,
  fixed,
  hybrid, // combination of percentage and fixed
}

class DoctorPayout {
  final String id;
  final String doctorId;
  final List<String> transactionIds;
  final double totalAmount;
  final double platformFee;
  final double netAmount;
  final PayoutStatus status;
  final DateTime createdAt;
  final DateTime? scheduledPayoutDate;
  final DateTime? actualPayoutDate;
  final String? payoutMethod; // 'bank_transfer', 'mobile_money', etc.
  final Map<String, dynamic> payoutDetails;
  final String? notes;

  DoctorPayout({
    required this.id,
    required this.doctorId,
    required this.transactionIds,
    required this.totalAmount,
    required this.platformFee,
    required this.netAmount,
    this.status = PayoutStatus.pending,
    required this.createdAt,
    this.scheduledPayoutDate,
    this.actualPayoutDate,
    this.payoutMethod,
    this.payoutDetails = const {},
    this.notes,
  });

  factory DoctorPayout.fromJson(Map<String, dynamic> json) {
    return DoctorPayout(
      id: json['id'],
      doctorId: json['doctorId'],
      transactionIds: List<String>.from(json['transactionIds']),
      totalAmount: json['totalAmount'].toDouble(),
      platformFee: json['platformFee'].toDouble(),
      netAmount: json['netAmount'].toDouble(),
      status: PayoutStatus.values.byName(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      scheduledPayoutDate: json['scheduledPayoutDate'] != null 
          ? DateTime.parse(json['scheduledPayoutDate']) : null,
      actualPayoutDate: json['actualPayoutDate'] != null 
          ? DateTime.parse(json['actualPayoutDate']) : null,
      payoutMethod: json['payoutMethod'],
      payoutDetails: json['payoutDetails'] ?? {},
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'transactionIds': transactionIds,
      'totalAmount': totalAmount,
      'platformFee': platformFee,
      'netAmount': netAmount,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'scheduledPayoutDate': scheduledPayoutDate?.toIso8601String(),
      'actualPayoutDate': actualPayoutDate?.toIso8601String(),
      'payoutMethod': payoutMethod,
      'payoutDetails': payoutDetails,
      'notes': notes,
    };
  }
}
