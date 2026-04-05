/*
 * Dr. Saathi - Fee Distribution Service
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * Licensed under the MIT License.
 */

import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/fee_distribution.dart';

class FeeDistributionService {
  static final FeeDistributionService _instance = FeeDistributionService._internal();
  factory FeeDistributionService() => _instance;
  FeeDistributionService._internal();

  // Default fee distribution configurations for different service types
  final Map<String, FeeDistributionConfig> _defaultConfigs = {
    'consultation': FeeDistributionConfig(
      serviceType: 'consultation',
      rules: {
        'doctor': FeeRule(
          stakeholder: 'doctor',
          percentage: 70.0,
          description: 'Doctor consultation fee',
        ),
        'platform': FeeRule(
          stakeholder: 'platform',
          percentage: 25.0,
          description: 'Platform service fee',
        ),
        'processing': FeeRule(
          stakeholder: 'processing',
          percentage: 3.0,
          description: 'Payment processing fee',
        ),
        'tax': FeeRule(
          stakeholder: 'tax',
          percentage: 2.0,
          description: 'Service tax (VAT)',
        ),
      },
      minimumAmount: 100.0,
      maximumAmount: 5000.0,
    ),
    'prescription': FeeDistributionConfig(
      serviceType: 'prescription',
      rules: {
        'doctor': FeeRule(
          stakeholder: 'doctor',
          percentage: 60.0,
          description: 'Doctor prescription fee',
        ),
        'platform': FeeRule(
          stakeholder: 'platform',
          percentage: 30.0,
          description: 'Platform service fee',
        ),
        'pharmacy': FeeRule(
          stakeholder: 'pharmacy',
          percentage: 8.0,
          description: 'Pharmacy referral fee',
        ),
        'tax': FeeRule(
          stakeholder: 'tax',
          percentage: 2.0,
          description: 'Service tax (VAT)',
        ),
      },
      minimumAmount: 50.0,
      maximumAmount: 2000.0,
    ),
    'health_card': FeeDistributionConfig(
      serviceType: 'health_card',
      rules: {
        'platform': FeeRule(
          stakeholder: 'platform',
          percentage: 95.0,
          description: 'Digital health card service',
        ),
        'processing': FeeRule(
          stakeholder: 'processing',
          percentage: 3.0,
          description: 'Payment processing fee',
        ),
        'tax': FeeRule(
          stakeholder: 'tax',
          percentage: 2.0,
          description: 'Service tax (VAT)',
        ),
      },
      minimumAmount: 100.0,
      maximumAmount: 500.0,
    ),
    'follow_up': FeeDistributionConfig(
      serviceType: 'follow_up',
      rules: {
        'doctor': FeeRule(
          stakeholder: 'doctor',
          percentage: 75.0,
          description: 'Doctor follow-up consultation',
        ),
        'platform': FeeRule(
          stakeholder: 'platform',
          percentage: 20.0,
          description: 'Platform service fee',
        ),
        'processing': FeeRule(
          stakeholder: 'processing',
          percentage: 3.0,
          description: 'Payment processing fee',
        ),
        'tax': FeeRule(
          stakeholder: 'tax',
          percentage: 2.0,
          description: 'Service tax (VAT)',
        ),
      },
      minimumAmount: 50.0,
      maximumAmount: 2000.0,
    ),
  };

  /// Calculate fee distribution for a given transaction
  FeeDistribution calculateFeeDistribution({
    required String transactionId,
    required String serviceType,
    required double totalAmount,
    String? doctorId,
    String? patientId,
    Map<String, dynamic> metadata = const {},
  }) {
    final config = _defaultConfigs[serviceType];
    if (config == null) {
      throw ArgumentError('No fee distribution config found for service type: $serviceType');
    }

    if (totalAmount < config.minimumAmount || totalAmount > config.maximumAmount) {
      throw ArgumentError('Amount $totalAmount is outside valid range for $serviceType');
    }

    final breakdown = <String, FeeBreakdown>{};
    double remainingAmount = totalAmount;

    // Calculate fees based on rules
    for (final entry in config.rules.entries) {
      final rule = entry.value;
      double amount;

      switch (rule.calculationType) {
        case FeeCalculationType.percentage:
          amount = (totalAmount * rule.percentage) / 100;
          break;
        case FeeCalculationType.fixed:
          amount = rule.fixedAmount ?? 0.0;
          break;
        case FeeCalculationType.hybrid:
          final percentageAmount = (totalAmount * rule.percentage) / 100;
          final fixedAmount = rule.fixedAmount ?? 0.0;
          amount = percentageAmount + fixedAmount;
          break;
      }

      breakdown[entry.key] = FeeBreakdown(
        stakeholder: rule.stakeholder,
        amount: amount,
        percentage: rule.percentage,
        description: rule.description,
      );

      remainingAmount -= amount;
    }

    // Ensure we don't have negative remaining amount due to rounding
    if (remainingAmount < -0.01) {
      throw StateError('Fee calculation error: total fees exceed transaction amount');
    }

    return FeeDistribution(
      id: const Uuid().v4(),
      transactionId: transactionId,
      serviceType: serviceType,
      totalAmount: totalAmount,
      breakdown: breakdown,
      createdAt: DateTime.now(),
      doctorId: doctorId,
      patientId: patientId,
      metadata: metadata,
    );
  }

  /// Get fee preview for a service type and amount
  Map<String, double> getFeePreview(String serviceType, double amount) {
    final config = _defaultConfigs[serviceType];
    if (config == null) {
      return {};
    }

    final preview = <String, double>{};
    for (final entry in config.rules.entries) {
      final rule = entry.value;
      double feeAmount;

      switch (rule.calculationType) {
        case FeeCalculationType.percentage:
          feeAmount = (amount * rule.percentage) / 100;
          break;
        case FeeCalculationType.fixed:
          feeAmount = rule.fixedAmount ?? 0.0;
          break;
        case FeeCalculationType.hybrid:
          final percentageAmount = (amount * rule.percentage) / 100;
          final fixedAmount = rule.fixedAmount ?? 0.0;
          feeAmount = percentageAmount + fixedAmount;
          break;
      }

      preview[entry.key] = feeAmount;
    }

    return preview;
  }

  /// Calculate doctor payout for multiple transactions
  DoctorPayout calculateDoctorPayout({
    required String doctorId,
    required List<FeeDistribution> transactions,
    DateTime? scheduledPayoutDate,
    String? payoutMethod,
    Map<String, dynamic> payoutDetails = const {},
  }) {
    double totalAmount = 0.0;
    double totalPlatformFee = 0.0;
    final transactionIds = <String>[];

    for (final transaction in transactions) {
      if (transaction.doctorId != doctorId) {
        continue; // Skip transactions not for this doctor
      }

      totalAmount += transaction.doctorFee;
      totalPlatformFee += transaction.platformFee;
      transactionIds.add(transaction.transactionId);
    }

    final netAmount = totalAmount; // Doctor fee is already net of platform fee

    return DoctorPayout(
      id: const Uuid().v4(),
      doctorId: doctorId,
      transactionIds: transactionIds,
      totalAmount: totalAmount,
      platformFee: totalPlatformFee,
      netAmount: netAmount,
      createdAt: DateTime.now(),
      scheduledPayoutDate: scheduledPayoutDate,
      payoutMethod: payoutMethod,
      payoutDetails: payoutDetails,
    );
  }

  /// Get fee breakdown explanation for UI display
  List<Map<String, dynamic>> getFeeBreakdownExplanation(String serviceType, double amount) {
    final config = _defaultConfigs[serviceType];
    if (config == null) {
      return [];
    }

    final explanation = <Map<String, dynamic>>[];
    
    for (final entry in config.rules.entries) {
      final rule = entry.value;
      double feeAmount;

      switch (rule.calculationType) {
        case FeeCalculationType.percentage:
          feeAmount = (amount * rule.percentage) / 100;
          break;
        case FeeCalculationType.fixed:
          feeAmount = rule.fixedAmount ?? 0.0;
          break;
        case FeeCalculationType.hybrid:
          final percentageAmount = (amount * rule.percentage) / 100;
          final fixedAmount = rule.fixedAmount ?? 0.0;
          feeAmount = percentageAmount + fixedAmount;
          break;
      }

      explanation.add({
        'stakeholder': rule.stakeholder,
        'name': _getStakeholderDisplayName(rule.stakeholder),
        'amount': feeAmount,
        'percentage': rule.percentage,
        'description': rule.description,
        'type': rule.calculationType.name,
      });
    }

    return explanation;
  }

  String _getStakeholderDisplayName(String stakeholder) {
    switch (stakeholder) {
      case 'doctor':
        return 'Doctor';
      case 'platform':
        return 'Dr. Saathi Platform';
      case 'processing':
        return 'Payment Processing';
      case 'tax':
        return 'Tax (VAT)';
      case 'pharmacy':
        return 'Pharmacy Partner';
      default:
        return stakeholder.toUpperCase();
    }
  }

  /// Update fee distribution configuration
  void updateFeeConfig(String serviceType, FeeDistributionConfig config) {
    _defaultConfigs[serviceType] = config;
  }

  /// Get current fee configuration
  FeeDistributionConfig? getFeeConfig(String serviceType) {
    return _defaultConfigs[serviceType];
  }

  /// Get all available service types
  List<String> getAvailableServiceTypes() {
    return _defaultConfigs.keys.toList();
  }

  /// Calculate platform revenue for a period
  Map<String, dynamic> calculatePlatformRevenue({
    required List<FeeDistribution> transactions,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final filteredTransactions = transactions.where((t) =>
        t.createdAt.isAfter(startDate) && t.createdAt.isBefore(endDate)).toList();

    double totalRevenue = 0.0;
    double totalPlatformFee = 0.0;
    double totalTax = 0.0;
    double totalProcessingFee = 0.0;
    final serviceBreakdown = <String, double>{};

    for (final transaction in filteredTransactions) {
      totalRevenue += transaction.totalAmount;
      totalPlatformFee += transaction.platformFee;
      totalTax += transaction.taxAmount;
      totalProcessingFee += transaction.processingFee;

      serviceBreakdown[transaction.serviceType] =
          (serviceBreakdown[transaction.serviceType] ?? 0.0) + transaction.platformFee;
    }

    return {
      'totalRevenue': totalRevenue,
      'platformFee': totalPlatformFee,
      'taxAmount': totalTax,
      'processingFee': totalProcessingFee,
      'netPlatformRevenue': totalPlatformFee - totalProcessingFee - totalTax,
      'transactionCount': filteredTransactions.length,
      'serviceBreakdown': serviceBreakdown,
      'averageTransactionValue': filteredTransactions.isNotEmpty 
          ? totalRevenue / filteredTransactions.length : 0.0,
    };
  }

  /// Validate fee distribution configuration
  bool validateFeeConfig(FeeDistributionConfig config) {
    double totalPercentage = 0.0;
    
    for (final rule in config.rules.values) {
      if (rule.percentage < 0 || rule.percentage > 100) {
        return false;
      }
      totalPercentage += rule.percentage;
    }

    // Allow small tolerance for rounding errors
    return (totalPercentage - 100.0).abs() < 0.01;
  }
}
