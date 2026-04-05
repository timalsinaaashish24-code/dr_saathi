/*
 * Dr. Saathi - Admin Bank Transfer Verification Screen
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * Licensed under the MIT License.
 */

import 'package:flutter/material.dart';
import 'dart:io';
import '../models/bank_transfer.dart';
import '../services/bank_transfer_service.dart';
import '../services/payment_orchestrator.dart';

class AdminVerifyTransfersScreen extends StatefulWidget {
  final String adminId;

  const AdminVerifyTransfersScreen({
    Key? key,
    required this.adminId,
  }) : super(key: key);

  @override
  _AdminVerifyTransfersScreenState createState() =>
      _AdminVerifyTransfersScreenState();
}

class _AdminVerifyTransfersScreenState
    extends State<AdminVerifyTransfersScreen> with SingleTickerProviderStateMixin {
  final _bankTransferService = BankTransferService();
  final _paymentOrchestrator = PaymentOrchestrator();
  late TabController _tabController;
  
  List<BankTransfer> _pendingTransfers = [];
  List<BankTransfer> _verifiedTransfers = [];
  List<BankTransfer> _rejectedTransfers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTransfers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTransfers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pending = await _bankTransferService.getPendingTransfers();
      final verified = await _bankTransferService
          .getTransfersByStatus(BankTransferStatus.verified);
      final rejected = await _bankTransferService
          .getTransfersByStatus(BankTransferStatus.rejected);

      setState(() {
        _pendingTransfers = pending;
        _verifiedTransfers = verified;
        _rejectedTransfers = rejected;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading transfers: $e')),
      );
    }
  }

  Future<void> _verifyTransfer(BankTransfer transfer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Transfer'),
        content: Text(
          'Confirm verification of transfer #${transfer.transactionId}?\n\n'
          'Amount: NPR ${transfer.amount.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Verify'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _bankTransferService.verifyTransfer(
          transfer.id,
          widget.adminId,
        );
        
        // TODO: Get doctor details from appointment/invoice
        // For now, this is a placeholder - you'll need to fetch actual doctor details
        // from your appointment or invoice linked to this transfer
        /*
        await _paymentOrchestrator.onPatientPaymentVerified(
          patientTransferId: transfer.id,
          doctorId: 'DOCTOR_ID', // Get from appointment
          appointmentId: transfer.appointmentId,
          invoiceId: transfer.invoiceId,
          doctorBankName: 'Doctor Bank',
          doctorAccountNumber: '1234567890',
          doctorAccountName: 'Dr. Name',
        );
        */
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transfer verified successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadTransfers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verifying transfer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectTransfer(BankTransfer transfer) async {
    final TextEditingController reasonController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Transfer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Reject transfer #${transfer.transactionId}?\n'
              'Amount: NPR ${transfer.amount.toStringAsFixed(2)}\n',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter rejection reason'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirm == true && reasonController.text.isNotEmpty) {
      try {
        await _bankTransferService.rejectTransfer(
          transfer.id,
          reasonController.text,
          widget.adminId,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transfer rejected'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadTransfers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rejecting transfer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    reasonController.dispose();
  }

  void _viewTransferDetails(BankTransfer transfer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return TransferDetailsView(
            transfer: transfer,
            scrollController: scrollController,
            onVerify: () {
              Navigator.pop(context);
              _verifyTransfer(transfer);
            },
            onReject: () {
              Navigator.pop(context);
              _rejectTransfer(transfer);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Bank Transfers'),
        backgroundColor: Colors.blue[700],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Badge(
                label: Text('${_pendingTransfers.length}'),
                child: const Icon(Icons.pending),
              ),
              text: 'Pending',
            ),
            Tab(
              icon: Badge(
                label: Text('${_verifiedTransfers.length}'),
                child: const Icon(Icons.check_circle),
              ),
              text: 'Verified',
            ),
            Tab(
              icon: Badge(
                label: Text('${_rejectedTransfers.length}'),
                child: const Icon(Icons.cancel),
              ),
              text: 'Rejected',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTransferList(_pendingTransfers, showActions: true),
                _buildTransferList(_verifiedTransfers),
                _buildTransferList(_rejectedTransfers),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadTransfers,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildTransferList(
    List<BankTransfer> transfers, {
    bool showActions = false,
  }) {
    if (transfers.isEmpty) {
      return const Center(
        child: Text('No transfers found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransfers,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: transfers.length,
        itemBuilder: (context, index) {
          final transfer = transfers[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(transfer.status),
                child: Icon(
                  _getStatusIcon(transfer.status),
                  color: Colors.white,
                ),
              ),
              title: Text(
                'NPR ${transfer.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('From: ${transfer.senderBankName}'),
                  Text('Txn: ${transfer.transactionId}'),
                  Text(
                    'Date: ${_formatDate(transfer.transferDate)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showActions) ...[
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => _verifyTransfer(transfer),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _rejectTransfer(transfer),
                    ),
                  ],
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () => _viewTransferDetails(transfer),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(BankTransferStatus status) {
    switch (status) {
      case BankTransferStatus.pending:
        return Colors.orange;
      case BankTransferStatus.verified:
        return Colors.green;
      case BankTransferStatus.rejected:
        return Colors.red;
      case BankTransferStatus.expired:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(BankTransferStatus status) {
    switch (status) {
      case BankTransferStatus.pending:
        return Icons.hourglass_empty;
      case BankTransferStatus.verified:
        return Icons.check_circle;
      case BankTransferStatus.rejected:
        return Icons.cancel;
      case BankTransferStatus.expired:
        return Icons.timer_off;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class TransferDetailsView extends StatelessWidget {
  final BankTransfer transfer;
  final ScrollController scrollController;
  final VoidCallback? onVerify;
  final VoidCallback? onReject;

  const TransferDetailsView({
    Key? key,
    required this.transfer,
    required this.scrollController,
    this.onVerify,
    this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        controller: scrollController,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transfer Details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          
          // Amount
          Center(
            child: Text(
              'NPR ${transfer.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sender Details
          _buildSectionTitle('Sender Details'),
          _buildDetailRow('Bank', transfer.senderBankName),
          _buildDetailRow('Account Holder', transfer.senderAccountName),
          _buildDetailRow('Account Number', transfer.senderAccountNumber),
          const SizedBox(height: 16),

          // Receiver Details
          _buildSectionTitle('Receiver Details'),
          _buildDetailRow('Bank', transfer.receiverBankName),
          _buildDetailRow('Account Number', transfer.receiverAccountNumber),
          const SizedBox(height: 16),

          // Transaction Details
          _buildSectionTitle('Transaction Details'),
          _buildDetailRow('Transaction ID', transfer.transactionId),
          _buildDetailRow('Transfer Date', _formatDate(transfer.transferDate)),
          _buildDetailRow('Submitted On', _formatDate(transfer.createdAt)),
          if (transfer.remarks != null)
            _buildDetailRow('Remarks', transfer.remarks!),
          const SizedBox(height: 16),

          // Payment Proof
          if (transfer.transactionProofPath != null) ...[
            _buildSectionTitle('Payment Proof'),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(transfer.transactionProofPath!),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Verification Details
          if (transfer.verifiedAt != null) ...[
            _buildSectionTitle('Verification Details'),
            _buildDetailRow('Status', _getStatusText(transfer.status)),
            _buildDetailRow('Verified On', _formatDate(transfer.verifiedAt!)),
            if (transfer.verifiedBy != null)
              _buildDetailRow('Verified By', transfer.verifiedBy!),
            if (transfer.rejectionReason != null)
              _buildDetailRow('Rejection Reason', transfer.rejectionReason!),
          ],

          const SizedBox(height: 24),

          // Action Buttons (only for pending transfers)
          if (transfer.status == BankTransferStatus.pending &&
              onVerify != null &&
              onReject != null) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onVerify,
                    icon: const Icon(Icons.check),
                    label: const Text('Verify'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getStatusText(BankTransferStatus status) {
    switch (status) {
      case BankTransferStatus.pending:
        return 'Pending';
      case BankTransferStatus.verified:
        return 'Verified';
      case BankTransferStatus.rejected:
        return 'Rejected';
      case BankTransferStatus.expired:
        return 'Expired';
    }
  }
}
