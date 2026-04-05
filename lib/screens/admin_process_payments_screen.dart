/*
 * Dr. Saathi - Admin Doctor Payment Processing Screen
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * Licensed under the MIT License.
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/doctor_payment.dart';
import '../services/doctor_payment_service.dart';
import '../services/payment_orchestrator.dart';

class AdminProcessPaymentsScreen extends StatefulWidget {
  final String adminId;

  const AdminProcessPaymentsScreen({
    Key? key,
    required this.adminId,
  }) : super(key: key);

  @override
  _AdminProcessPaymentsScreenState createState() =>
      _AdminProcessPaymentsScreenState();
}

class _AdminProcessPaymentsScreenState
    extends State<AdminProcessPaymentsScreen>
    with SingleTickerProviderStateMixin {
  final _paymentService = DoctorPaymentService();
  final _orchestrator = PaymentOrchestrator();
  late TabController _tabController;

  List<DoctorPayment> _pendingPayments = [];
  List<DoctorPayment> _processingPayments = [];
  List<DoctorPayment> _completedPayments = [];
  Map<String, dynamic>? _platformStats;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pending = await _paymentService
          .getPaymentsByStatus(PaymentStatus.pending);
      final processing = await _paymentService
          .getPaymentsByStatus(PaymentStatus.processing);
      final completed = await _paymentService
          .getPaymentsByStatus(PaymentStatus.completed);
      final stats = await _paymentService.getPlatformRevenueStats();

      setState(() {
        _pendingPayments = pending;
        _processingPayments = processing;
        _completedPayments = completed;
        _platformStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading payments: $e')),
      );
    }
  }

  Future<void> _processPayment(DoctorPayment payment) async {
    try {
      setState(() {
        _isProcessing = true;
      });

      await _orchestrator.processPendingPayments(
        adminId: widget.adminId,
        limit: 1,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment processed successfully'),
          backgroundColor: Colors.green,
        ),
      );

      await _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processAllPending() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process All Payments'),
        content: Text(
          'Process ${_pendingPayments.length} pending payments?\n\n'
          'Total amount: NPR ${_calculateTotalAmount(_pendingPayments).toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Process All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        setState(() {
          _isProcessing = true;
        });

        final stats = await _orchestrator.bulkProcessAllPending(widget.adminId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Processed: ${stats['success']}/${stats['total']} payments',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }

        await _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  double _calculateTotalAmount(List<DoctorPayment> payments) {
    return payments.fold(0.0, (sum, payment) => sum + payment.netPayable);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Process Doctor Payments'),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildPlatformStats(),
                _buildTabBar(),
                Expanded(child: _buildTabContent()),
              ],
            ),
      floatingActionButton: _pendingPayments.isNotEmpty && !_isProcessing
          ? FloatingActionButton.extended(
              onPressed: _processAllPending,
              icon: const Icon(Icons.payments),
              label: Text('Process All (${_pendingPayments.length})'),
              backgroundColor: Colors.green[600],
            )
          : null,
    );
  }

  Widget _buildPlatformStats() {
    if (_platformStats == null) return const SizedBox.shrink();

    final totalCommission = _platformStats!['total_commission'] ?? 0.0;
    final completedCommission = _platformStats!['completed_commission'] ?? 0.0;
    final totalTax = _platformStats!['total_tax_collected'] ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Platform Revenue',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'NPR ${NumberFormat('#,##0.00').format(completedCommission)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Commission',
                  'NPR ${NumberFormat('#,##0').format(totalCommission)}',
                  Colors.white.withOpacity(0.2),
                  Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Tax Collected',
                  'NPR ${NumberFormat('#,##0').format(totalTax)}',
                  Colors.white.withOpacity(0.2),
                  Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.grey[100],
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.blue[700],
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue[700],
        tabs: [
          Tab(
            icon: Badge(
              label: Text('${_pendingPayments.length}'),
              child: const Icon(Icons.pending_actions),
            ),
            text: 'Pending',
          ),
          Tab(
            icon: Badge(
              label: Text('${_processingPayments.length}'),
              child: const Icon(Icons.sync),
            ),
            text: 'Processing',
          ),
          Tab(
            icon: Badge(
              label: Text('${_completedPayments.length}'),
              child: const Icon(Icons.check_circle),
            ),
            text: 'Completed',
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildPaymentList(_pendingPayments, showActions: true),
        _buildPaymentList(_processingPayments),
        _buildPaymentList(_completedPayments),
      ],
    );
  }

  Widget _buildPaymentList(List<DoctorPayment> payments,
      {bool showActions = false}) {
    if (payments.isEmpty) {
      return const Center(
        child: Text('No payments found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(payment.status),
                child: Icon(
                  _getStatusIcon(payment.status),
                  color: Colors.white,
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Doctor ID: ${payment.doctorId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    'NPR ${NumberFormat('#,##0').format(payment.netPayable)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                'Date: ${DateFormat('dd MMM yyyy').format(payment.paymentDate)}',
                style: const TextStyle(fontSize: 12),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                          'Patient Paid', 'NPR ${payment.totalAmount.toStringAsFixed(2)}'),
                      _buildDetailRow('Platform Commission',
                          'NPR ${payment.platformCommission.toStringAsFixed(2)}'),
                      _buildDetailRow('Doctor Amount',
                          'NPR ${payment.doctorAmount.toStringAsFixed(2)}'),
                      _buildDetailRow(
                          'Tax Deducted', 'NPR ${payment.taxDeducted.toStringAsFixed(2)}'),
                      const Divider(),
                      _buildDetailRow('Net to Doctor',
                          'NPR ${payment.netPayable.toStringAsFixed(2)}',
                          isBold: true),
                      const SizedBox(height: 12),
                      _buildDetailRow('Bank', payment.doctorBankName ?? 'N/A'),
                      _buildDetailRow(
                          'Account', payment.doctorAccountNumber ?? 'N/A'),
                      if (payment.transactionId != null)
                        _buildDetailRow('Txn ID', payment.transactionId!),
                      if (showActions && !_isProcessing) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _processPayment(payment),
                            icon: const Icon(Icons.send),
                            label: const Text('Process Payment'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.processing:
        return Colors.blue;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Icons.hourglass_empty;
      case PaymentStatus.processing:
        return Icons.sync;
      case PaymentStatus.completed:
        return Icons.check_circle;
      case PaymentStatus.failed:
        return Icons.error;
      case PaymentStatus.cancelled:
        return Icons.cancel;
    }
  }
}
