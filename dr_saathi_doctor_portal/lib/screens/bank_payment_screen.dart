import 'package:flutter/material.dart';

class BankPaymentScreen extends StatelessWidget {
  final String? doctorId;
  final String? appointmentId;
  final double amount;
  final String serviceType;
  final String serviceName;
  final Map<String, dynamic>? customerInfo;

  const BankPaymentScreen({
    Key? key,
    this.doctorId,
    this.appointmentId,
    required this.amount,
    required this.serviceType,
    required this.serviceName,
    this.customerInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(serviceName),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance, size: 64, color: Colors.teal),
              const SizedBox(height: 24),
              Text(
                'NPR ${amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Bank payment for $serviceName',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Text(
                'Payment integration coming soon.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
