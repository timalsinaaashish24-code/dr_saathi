/*
 * Dr. Saathi - Payment System Demo Home
 * Use this to test all payment screens
 */

import 'package:flutter/material.dart';
import 'doctor_earnings_screen.dart';
import 'admin_process_payments_screen.dart';
import 'submit_bank_transfer_screen.dart';
import 'admin_verify_transfers_screen.dart';

class PaymentDemoHome extends StatelessWidget {
  const PaymentDemoHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment System Demo'),
        backgroundColor: Colors.blue[700],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Test Payment Screens',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildSection('Patient Screens', [
            _buildDemoButton(
              context,
              'Submit Bank Transfer',
              Icons.payments,
              Colors.green,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubmitBankTransferScreen(
                    patientId: 'DEMO_PATIENT',
                    amount: 1000.0,
                    appointmentId: 'APT123',
                  ),
                ),
              ),
            ),
          ]),
          
          const SizedBox(height: 20),
          
          _buildSection('Doctor Screens', [
            _buildDemoButton(
              context,
              'Doctor Earnings Dashboard',
              Icons.account_balance_wallet,
              Colors.green,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DoctorEarningsScreen(
                    doctorId: 'DEMO_DOCTOR',
                    doctorName: 'Dr. Demo Doctor',
                  ),
                ),
              ),
            ),
          ]),
          
          const SizedBox(height: 20),
          
          _buildSection('Admin Screens', [
            _buildDemoButton(
              context,
              'Verify Bank Transfers',
              Icons.verified,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminVerifyTransfersScreen(
                    adminId: 'DEMO_ADMIN',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildDemoButton(
              context,
              'Process Doctor Payments',
              Icons.payment,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminProcessPaymentsScreen(
                    adminId: 'DEMO_ADMIN',
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDemoButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
