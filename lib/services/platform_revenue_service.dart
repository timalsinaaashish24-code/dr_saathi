/*
 * Dr. Saathi - Platform Revenue & Margin Analysis
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * Licensed under the MIT License.
 */

import '../models/fee_distribution.dart';
import 'fee_distribution_service.dart';

class PlatformRevenueService {
  static final PlatformRevenueService _instance = PlatformRevenueService._internal();
  factory PlatformRevenueService() => _instance;
  PlatformRevenueService._internal();

  final FeeDistributionService _feeService = FeeDistributionService();

  /// YOUR PLATFORM MARGIN BREAKDOWN
  /// This shows exactly where your profit comes from in each transaction
  
  Map<String, dynamic> calculatePlatformMargin({
    required String serviceType,
    required double transactionAmount,
  }) {
    final feeBreakdown = _feeService.getFeePreview(serviceType, transactionAmount);
    
    // YOUR GROSS REVENUE (Platform Fee)
    final platformFee = feeBreakdown['platform'] ?? 0.0;
    
    // YOUR COSTS (deducted from platform fee)
    final processingFee = feeBreakdown['processing'] ?? 0.0;
    final taxAmount = feeBreakdown['tax'] ?? 0.0;
    
    // YOUR NET PROFIT MARGIN
    final netMargin = platformFee - processingFee - taxAmount;
    final marginPercentage = transactionAmount > 0 ? (netMargin / transactionAmount) * 100 : 0.0;
    
    return {
      'serviceType': serviceType,
      'transactionAmount': transactionAmount,
      'platformFee': platformFee,
      'platformFeePercentage': transactionAmount > 0 ? (platformFee / transactionAmount) * 100 : 0.0,
      'costs': {
        'processingFee': processingFee,
        'taxAmount': taxAmount,
        'totalCosts': processingFee + taxAmount,
      },
      'netMargin': netMargin,
      'marginPercentage': marginPercentage,
      'profitability': _getProfitabilityStatus(marginPercentage),
    };
  }

  /// DETAILED MARGIN ANALYSIS FOR ALL SERVICE TYPES
  Map<String, Map<String, dynamic>> getAllServiceMargins(double sampleAmount) {
    final serviceTypes = _feeService.getAvailableServiceTypes();
    final margins = <String, Map<String, dynamic>>{};
    
    for (final serviceType in serviceTypes) {
      margins[serviceType] = calculatePlatformMargin(
        serviceType: serviceType,
        transactionAmount: sampleAmount,
      );
    }
    
    return margins;
  }

  /// YOUR MONTHLY REVENUE PROJECTION
  Map<String, dynamic> calculateMonthlyRevenue({
    required Map<String, int> expectedTransactions, // service_type: count
    required Map<String, double> averageAmounts, // service_type: avg_amount
  }) {
    double totalGrossRevenue = 0.0;
    double totalNetMargin = 0.0;
    double totalCosts = 0.0;
    final serviceBreakdown = <String, Map<String, dynamic>>{};
    
    for (final entry in expectedTransactions.entries) {
      final serviceType = entry.key;
      final transactionCount = entry.value;
      final avgAmount = averageAmounts[serviceType] ?? 0.0;
      
      final margin = calculatePlatformMargin(
        serviceType: serviceType,
        transactionAmount: avgAmount,
      );
      
      final monthlyGross = margin['platformFee'] * transactionCount;
      final monthlyCosts = margin['costs']['totalCosts'] * transactionCount;
      final monthlyNet = margin['netMargin'] * transactionCount;
      
      totalGrossRevenue += monthlyGross;
      totalCosts += monthlyCosts;
      totalNetMargin += monthlyNet;
      
      serviceBreakdown[serviceType] = {
        'transactionCount': transactionCount,
        'averageAmount': avgAmount,
        'grossRevenue': monthlyGross,
        'costs': monthlyCosts,
        'netMargin': monthlyNet,
        'profitMargin': avgAmount > 0 ? (margin['netMargin'] / avgAmount) * 100 : 0.0,
      };
    }
    
    return {
      'totalGrossRevenue': totalGrossRevenue,
      'totalCosts': totalCosts,
      'totalNetMargin': totalNetMargin,
      'overallMarginPercentage': totalGrossRevenue > 0 ? (totalNetMargin / totalGrossRevenue) * 100 : 0.0,
      'serviceBreakdown': serviceBreakdown,
      'profitability': _getProfitabilityStatus(totalGrossRevenue > 0 ? (totalNetMargin / totalGrossRevenue) * 100 : 0.0),
    };
  }

  /// PLATFORM MARGIN BREAKDOWN BY SERVICE TYPE
  String getMarginExplanation(String serviceType) {
    switch (serviceType) {
      case 'consultation':
        return '''
DOCTOR CONSULTATION MARGIN:
• Patient pays: NPR 1000 (example)
• Doctor receives: NPR 700 (70%)
• YOUR PLATFORM FEE: NPR 250 (25%) ← YOUR GROSS REVENUE
• Processing costs: NPR 30 (3%)
• Tax (VAT): NPR 20 (2%)
• YOUR NET PROFIT: NPR 200 (20%) ← YOUR MARGIN

Your profit per NPR 1000 consultation = NPR 200
        ''';
        
      case 'prescription':
        return '''
PRESCRIPTION SERVICE MARGIN:
• Patient pays: NPR 500 (example)
• Doctor receives: NPR 300 (60%)
• YOUR PLATFORM FEE: NPR 150 (30%) ← YOUR GROSS REVENUE
• Pharmacy partner: NPR 40 (8%)
• Tax (VAT): NPR 10 (2%)
• YOUR NET PROFIT: NPR 140 (28%) ← YOUR MARGIN

Your profit per NPR 500 prescription = NPR 140
        ''';
        
      case 'health_card':
        return '''
🆔 DIGITAL HEALTH CARD MARGIN:
• Patient pays: NPR 150 (example)
• YOUR PLATFORM FEE: NPR 142.50 (95%) ← YOUR GROSS REVENUE
• Processing costs: NPR 4.50 (3%)
• Tax (VAT): NPR 3.00 (2%)
• YOUR NET PROFIT: NPR 135 (90%) ← YOUR MARGIN

Your profit per NPR 150 health card = NPR 135
        ''';
        
      case 'follow_up':
        return '''
🔄 FOLLOW-UP CONSULTATION MARGIN:
• Patient pays: NPR 400 (example)
• Doctor receives: NPR 300 (75%)
• YOUR PLATFORM FEE: NPR 80 (20%) ← YOUR GROSS REVENUE
• Processing costs: NPR 12 (3%)
• Tax (VAT): NPR 8 (2%)
• YOUR NET PROFIT: NPR 60 (15%) ← YOUR MARGIN

Your profit per NPR 400 follow-up = NPR 60
        ''';
        
      default:
        return 'Service type not found';
    }
  }

  /// REVENUE OPTIMIZATION SUGGESTIONS
  List<Map<String, dynamic>> getRevenueOptimizationSuggestions() {
    return [
      {
        'title': 'Focus on Health Cards',
        'description': 'Digital Health Cards have the highest margin (90%). Promote these for maximum profit.',
        'impact': 'High',
        'effort': 'Low',
      },
      {
        'title': 'Increase Consultation Volume',
        'description': 'Consultations provide steady NPR 200 profit per transaction. Scale doctor partnerships.',
        'impact': 'High',
        'effort': 'Medium',
      },
      {
        'title': 'Prescription Upselling',
        'description': 'Encourage doctors to use prescription service for additional NPR 140 per prescription.',
        'impact': 'Medium',
        'effort': 'Low',
      },
      {
        'title': 'Follow-up Automation',
        'description': 'Automate follow-up reminders to increase follow-up consultations.',
        'impact': 'Medium',
        'effort': 'Medium',
      },
      {
        'title': 'Premium Service Tiers',
        'description': 'Introduce premium consultation tiers with higher platform fees.',
        'impact': 'High',
        'effort': 'High',
      },
    ];
  }

  /// BREAK-EVEN ANALYSIS
  Map<String, dynamic> calculateBreakEven({
    required double monthlyFixedCosts, // Your operational costs
    required Map<String, double> averageMargins, // Average margin per service
  }) {
    final breakEvenTransactions = <String, int>{};
    double totalAverageMargin = 0.0;
    
    for (final entry in averageMargins.entries) {
      final serviceType = entry.key;
      final margin = entry.value;
      
      if (margin > 0) {
        breakEvenTransactions[serviceType] = (monthlyFixedCosts / margin).ceil();
      }
      
      totalAverageMargin += margin;
    }
    
    final averageMarginAcrossServices = averageMargins.isNotEmpty 
        ? totalAverageMargin / averageMargins.length 
        : 0.0;
    
    return {
      'monthlyFixedCosts': monthlyFixedCosts,
      'breakEvenTransactionsByService': breakEvenTransactions,
      'totalBreakEvenTransactions': averageMarginAcrossServices > 0 
          ? (monthlyFixedCosts / averageMarginAcrossServices).ceil() 
          : 0,
      'averageMarginPerTransaction': averageMarginAcrossServices,
    };
  }

  String _getProfitabilityStatus(double marginPercentage) {
    if (marginPercentage >= 25) return 'Excellent';
    if (marginPercentage >= 15) return 'Good';
    if (marginPercentage >= 10) return 'Fair';
    if (marginPercentage >= 5) return 'Poor';
    return 'Loss Making';
  }

  /// YOUR PROFIT SUMMARY
  Map<String, dynamic> getPlatformProfitSummary({
    required List<FeeDistribution> transactions,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final filteredTransactions = transactions.where((t) =>
        t.createdAt.isAfter(startDate) && t.createdAt.isBefore(endDate)).toList();

    double totalRevenue = 0.0;
    double totalPlatformFee = 0.0;
    double totalCosts = 0.0;
    double totalProfit = 0.0;
    
    final serviceRevenue = <String, double>{};
    final serviceProfit = <String, double>{};

    for (final transaction in filteredTransactions) {
      final platformFee = transaction.platformFee;
      final costs = transaction.processingFee + transaction.taxAmount;
      final profit = platformFee - costs;

      totalRevenue += transaction.totalAmount;
      totalPlatformFee += platformFee;
      totalCosts += costs;
      totalProfit += profit;

      serviceRevenue[transaction.serviceType] = 
          (serviceRevenue[transaction.serviceType] ?? 0.0) + platformFee;
      serviceProfit[transaction.serviceType] = 
          (serviceProfit[transaction.serviceType] ?? 0.0) + profit;
    }

    return {
      'period': '${startDate.toIso8601String().split('T')[0]} to ${endDate.toIso8601String().split('T')[0]}',
      'totalTransactions': filteredTransactions.length,
      'totalRevenue': totalRevenue,
      'yourGrossRevenue': totalPlatformFee,
      'yourCosts': totalCosts,
      'yourNetProfit': totalProfit,
      'profitMargin': totalPlatformFee > 0 ? (totalProfit / totalPlatformFee) * 100 : 0.0,
      'revenueMargin': totalRevenue > 0 ? (totalProfit / totalRevenue) * 100 : 0.0,
      'serviceRevenue': serviceRevenue,
      'serviceProfit': serviceProfit,
    };
  }
}
