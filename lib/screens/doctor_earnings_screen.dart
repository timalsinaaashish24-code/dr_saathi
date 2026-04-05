/*
 * Dr. Saathi - Doctor Earnings Dashboard
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * Licensed under the MIT License.
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/doctor_payment.dart';
import '../services/doctor_payment_service.dart';

class DoctorEarningsScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;

  const DoctorEarningsScreen({
    Key? key,
    required this.doctorId,
    required this.doctorName,
  }) : super(key: key);

  @override
  _DoctorEarningsScreenState createState() => _DoctorEarningsScreenState();
}

class _DoctorEarningsScreenState extends State<DoctorEarningsScreen>
    with SingleTickerProviderStateMixin {
  final _paymentService = DoctorPaymentService();
  late TabController _tabController;

  Map<String, dynamic>? _stats;
  Map<String, double>? _monthlyEarnings;
  List<DoctorPayment> _allPayments = [];
  List<DoctorPayment> _pendingPayments = [];
  List<DoctorPayment> _completedPayments = [];
  bool _isLoading = true;

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
      final stats = await _paymentService.getDoctorEarningStats(widget.doctorId);
      final monthlyEarnings = await _paymentService.getMonthlyEarnings(
        widget.doctorId,
        DateTime.now(),
      );
      final allPayments = await _paymentService.getPaymentsByDoctor(widget.doctorId);
      
      final pending = allPayments
          .where((p) => p.status == PaymentStatus.pending || p.status == PaymentStatus.processing)
          .toList();
      final completed = allPayments
          .where((p) => p.status == PaymentStatus.completed)
          .toList();

      setState(() {
        _stats = stats;
        _monthlyEarnings = monthlyEarnings;
        _allPayments = allPayments;
        _pendingPayments = pending;
        _completedPayments = completed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading earnings: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.doctorName} - Earnings'),
        backgroundColor: Colors.green[700],
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
                _buildEarningsSummary(),
                _buildMonthlyReport(),
                const SizedBox(height: 8),
                _buildTabBar(),
                Expanded(child: _buildTabContent()),
              ],
            ),
    );
  }

  Widget _buildEarningsSummary() {
    final totalEarned = _stats?['total_earned'] ?? 0.0;
    final completedAmount = _stats?['completed_amount'] ?? 0.0;
    final pendingAmount = _stats?['pending_amount'] ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[700]!, Colors.green[500]!],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Total Earnings',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'NPR ${NumberFormat('#,##0.00').format(totalEarned)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  'NPR ${NumberFormat('#,##0').format(completedAmount)}',
                  Colors.white.withOpacity(0.2),
                  Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  'NPR ${NumberFormat('#,##0').format(pendingAmount)}',
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

  Widget _buildStatCard(String label, String value, Color bgColor, Color textColor) {
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
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyReport() {
    if (_monthlyEarnings == null) return const SizedBox.shrink();

    final count = _monthlyEarnings!['count'] ?? 0;
    final netEarnings = _monthlyEarnings!['net_earnings'] ?? 0.0;
    final commission = _monthlyEarnings!['commission'] ?? 0.0;
    final tax = _monthlyEarnings!['tax_deducted'] ?? 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This Month (${DateFormat('MMMM yyyy').format(DateTime.now())})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Chip(
                label: Text('${count.toInt()} Consultations'),
                backgroundColor: Colors.blue[100],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildReportRow('Net Earnings', netEarnings, Colors.green[700]!),
          _buildReportRow('Platform Commission', commission, Colors.grey[600]!),
          _buildReportRow('Tax Deducted', tax, Colors.grey[600]!),
        ],
      ),
    );
  }

  Widget _buildReportRow(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            'NPR ${NumberFormat('#,##0.00').format(amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
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
        labelColor: Colors.green[700],
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.green[700],
        tabs: [
          Tab(
            icon: Badge(
              label: Text('${_allPayments.length}'),
              child: const Icon(Icons.list),
            ),
            text: 'All',
          ),
          Tab(
            icon: Badge(
              label: Text('${_pendingPayments.length}'),
              child: const Icon(Icons.pending),
            ),
            text: 'Pending',
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
        _buildPaymentList(_allPayments),
        _buildPaymentList(_pendingPayments),
        _buildPaymentList(_completedPayments),
      ],
    );
  }

  Widget _buildPaymentList(List<DoctorPayment> payments) {
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
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(payment.status),
                child: Icon(
                  _getStatusIcon(payment.status),
                  color: Colors.white,
                ),
              ),
              title: Text(
                'NPR ${NumberFormat('#,##0.00').format(payment.netPayable)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total: NPR ${payment.totalAmount.toStringAsFixed(2)}'),
                  Text(
                    'Date: ${DateFormat('dd MMM yyyy').format(payment.paymentDate)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  if (payment.status == PaymentStatus.completed && payment.transactionId != null)
                    Text(
                      'Txn: ${payment.transactionId}',
                      style: const TextStyle(fontSize: 11, color: Colors.green),
                    ),
                ],
              ),
              trailing: Chip(
                label: Text(
                  _getStatusText(payment.status),
                  style: const TextStyle(fontSize: 11),
                ),
                backgroundColor: _getStatusColor(payment.status).withOpacity(0.2),
              ),
              onTap: () => _showPaymentDetails(payment),
            ),
          );
        },
      ),
    );
  }

  void _showPaymentDetails(DoctorPayment payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: ListView(
              controller: scrollController,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Payment Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                
                Center(
                  child: Text(
                    'NPR ${NumberFormat('#,##0.00').format(payment.netPayable)}',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
                Center(
                  child: Chip(
                    label: Text(_getStatusText(payment.status)),
                    backgroundColor: _getStatusColor(payment.status),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                
                _buildDetailSection('Payment Breakdown', [
                  _buildDetailRow('Patient Paid', 'NPR ${payment.totalAmount.toStringAsFixed(2)}'),
                  _buildDetailRow(
                    'Platform Commission (${payment.platformCommissionRate}%)',
                    'NPR ${payment.platformCommission.toStringAsFixed(2)}',
                  ),
                  _buildDetailRow('Your Amount', 'NPR ${payment.doctorAmount.toStringAsFixed(2)}'),
                  _buildDetailRow('Tax Deducted', 'NPR ${payment.taxDeducted.toStringAsFixed(2)}'),
                  const Divider(),
                  _buildDetailRow(
                    'Net Payable',
                    'NPR ${payment.netPayable.toStringAsFixed(2)}',
                    isBold: true,
                  ),
                ]),
                const SizedBox(height: 16),
                
                _buildDetailSection('Bank Details', [
                  _buildDetailRow('Bank', payment.doctorBankName ?? 'N/A'),
                  _buildDetailRow('Account', payment.doctorAccountNumber ?? 'N/A'),
                  _buildDetailRow('Account Name', payment.doctorAccountName ?? 'N/A'),
                ]),
                const SizedBox(height: 16),
                
                _buildDetailSection('Transaction Info', [
                  _buildDetailRow(
                    'Payment Date',
                    DateFormat('dd MMM yyyy, hh:mm a').format(payment.paymentDate),
                  ),
                  if (payment.transactionId != null)
                    _buildDetailRow('Transaction ID', payment.transactionId!),
                  if (payment.completedAt != null)
                    _buildDetailRow(
                      'Completed At',
                      DateFormat('dd MMM yyyy, hh:mm a').format(payment.completedAt!),
                    ),
                  if (payment.failureReason != null)
                    _buildDetailRow('Failure Reason', payment.failureReason!),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
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
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
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

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
    }
  }
}
