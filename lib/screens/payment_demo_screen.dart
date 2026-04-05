/*
 * Dr. Saathi - Payment Integration Demo
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * Licensed under the MIT License.
 */

import 'package:flutter/material.dart';
import 'package:dr_saathi/screens/payment_screen.dart';

class PaymentDemoScreen extends StatelessWidget {
  const PaymentDemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link and Pay'),
        backgroundColor: Colors.lightBlue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Dr. Saathi Payment Options',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Experience our integrated payment system with multiple gateway options',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Info card for other payment features
            Card(
              color: Colors.lightBlue[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.lightBlue[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Other payment features:',
                            style: TextStyle(
                              color: Colors.lightBlue[800],
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 28),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• Doctor consultations: "Find Doctors" (Home tab)',
                                style: TextStyle(
                                  color: Colors.lightBlue[700],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '• Prescription & pharmacy: "Prescriptions" (Profile tab)',
                                style: TextStyle(
                                  color: Colors.lightBlue[700],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Payment Gateway Information
            _buildPaymentGatewayInfo(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentSection(
    BuildContext context, {
    required String title,
    required String description,
    required List<PaymentScenario> scenarios,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ...scenarios.map((scenario) => _buildScenarioCard(context, scenario)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildScenarioCard(BuildContext context, PaymentScenario scenario) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.lightBlue[100],
            child: Text(
              'NPR',
              style: TextStyle(
                color: Colors.lightBlue[800],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          title: Text(
            scenario.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(scenario.description),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'NPR ${scenario.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue[600],
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
          onTap: () => _launchPayment(context, scenario),
        ),
      ),
    );
  }
  
  Widget _buildPaymentGatewayInfo(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Supported Payment Methods',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // eSewa
            _buildGatewayInfo(
              name: 'eSewa',
              description: 'Nepal\'s most popular digital wallet',
              features: ['Instant payments', 'No transaction fees', 'Secure encryption'],
              color: Colors.green,
              logoPath: 'assets/images/payment_logos/esewa_logo.png',
              isRecommended: true,
            ),
            
            const SizedBox(height: 12),
            
            // Khalti
            _buildGatewayInfo(
              name: 'Khalti',
              description: 'Mobile-first payment solution',
              features: ['Mobile optimized', 'Bank integration', 'Quick transfers'],
              color: Colors.purple,
              logoPath: 'assets/images/payment_logos/khalti_logo.png',
            ),
            
            const SizedBox(height: 12),
            
            // IME Pay
            _buildGatewayInfo(
              name: 'IME Pay',
              description: 'Bank-backed payment system',
              features: ['Direct bank transfers', 'International remittance', 'High security'],
              color: Colors.blue,
              logoPath: 'assets/images/payment_logos/ime_pay_logo.png',
              isComingSoon: true,
            ),
            
            const SizedBox(height: 12),
            
            // ConnectIPS
            _buildGatewayInfo(
              name: 'ConnectIPS',
              description: 'Internet banking solution',
              features: ['All major banks', 'Real-time processing', 'No wallet needed'],
              color: Colors.orange,
              logoPath: 'assets/images/payment_logos/connectips_logo.png',
              isComingSoon: true,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGatewayInfo({
    required String name,
    required String description,
    required List<String> features,
    required Color color,
    required String logoPath,
    bool isRecommended = false,
    bool isComingSoon = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.05),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                logoPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to icon if image fails to load
                  return Icon(
                    _getPaymentIcon(name.toLowerCase()),
                    color: color,
                    size: 20,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (isRecommended) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'RECOMMENDED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    if (isComingSoon) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'COMING SOON',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: features.map((feature) => Text(
                    '• $feature',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 11,
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getPaymentIcon(String name) {
    switch (name) {
      case 'esewa':
        return Icons.account_balance_wallet;
      case 'khalti':
        return Icons.phone_android;
      case 'ime pay':
        return Icons.account_balance;
      case 'connectips':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }
  
  void _launchPayment(BuildContext context, PaymentScenario scenario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          doctorId: scenario.doctorId,
          appointmentId: scenario.appointmentId,
          amount: scenario.amount,
          serviceType: scenario.serviceType,
          serviceName: scenario.serviceName,
          customerInfo: {
            'name': 'John Doe',
            'email': 'john.doe@example.com',
            'phone': '+977-9841234567',
            'patientId': 'PAT001',
          },
        ),
      ),
    );
  }
}

class PaymentScenario {
  final String title;
  final String description;
  final double amount;
  final String serviceType;
  final String serviceName;
  final String? doctorId;
  final String? appointmentId;
  
  const PaymentScenario({
    required this.title,
    required this.description,
    required this.amount,
    required this.serviceType,
    required this.serviceName,
    this.doctorId,
    this.appointmentId,
  });
}
