import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../services/invoice_service.dart';

class PatientInvoiceView extends StatefulWidget {
  final String? patientId;

  const PatientInvoiceView({
    super.key,
    this.patientId,
  });

  @override
  State<PatientInvoiceView> createState() => _PatientInvoiceViewState();
}

class _PatientInvoiceViewState extends State<PatientInvoiceView> {
  final InvoiceService _invoiceService = InvoiceService();
  List<Invoice> invoices = [];
  bool isLoading = true;
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    if (widget.patientId == null) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      final result = await _invoiceService.getInvoicesForPatient(widget.patientId!);
      setState(() {
        invoices = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading invoices: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Invoice> get filteredInvoices {
    switch (selectedFilter) {
      case 'Pending':
        return invoices.where((i) => i.status == InvoiceStatus.pending).toList();
      case 'Paid':
        return invoices.where((i) => i.status == InvoiceStatus.paid).toList();
      case 'Overdue':
        return invoices.where((i) => i.isOverdue).toList();
      default:
        return invoices;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Invoices'),
        backgroundColor: Colors.lightBlue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInvoices,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterTabs(),
          
          // Invoice Stats
          if (!isLoading && invoices.isNotEmpty) _buildStatsOverview(),
          
          // Invoices List
          Expanded(
            child: _buildInvoicesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = ['All', 'Pending', 'Paid', 'Overdue'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    selectedFilter = filter;
                  });
                },
                backgroundColor: Colors.grey[200],
                selectedColor: Colors.lightBlue[100],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.lightBlue[800] : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    final totalAmount = invoices.fold<double>(
      0.0, 
      (sum, invoice) => sum + invoice.totalAmount
    );
    final paidAmount = invoices
        .where((i) => i.status == InvoiceStatus.paid)
        .fold<double>(0.0, (sum, invoice) => sum + invoice.totalAmount);
    final pendingAmount = invoices
        .where((i) => i.status == InvoiceStatus.pending)
        .fold<double>(0.0, (sum, invoice) => sum + invoice.totalAmount);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Invoice Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  'Rs ${totalAmount.toStringAsFixed(2)}',
                  Colors.grey[600]!,
                  Icons.receipt,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Paid',
                  'Rs ${paidAmount.toStringAsFixed(2)}',
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  'Rs ${pendingAmount.toStringAsFixed(2)}',
                  Colors.orange,
                  Icons.access_time,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No invoices found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your medical bills and invoices will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    final filteredList = filteredInvoices;
    
    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No $selectedFilter invoices',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final invoice = filteredList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildInvoiceCard(invoice),
        );
      },
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    final statusColor = _getStatusColor(invoice.status);
    final isOverdue = invoice.isOverdue;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOverdue 
          ? const BorderSide(color: Colors.red, width: 1)
          : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _showInvoiceDetails(invoice),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.invoiceNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        invoice.doctorName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isOverdue ? 'Overdue' : invoice.statusDisplay,
                          style: TextStyle(
                            color: isOverdue ? Colors.red : statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isOverdue) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${invoice.daysUntilDue.abs()} days overdue',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Amount and Date Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Rs ${invoice.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue[700],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Due Date',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _formatDate(invoice.dueDate),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isOverdue ? Colors.red : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showInvoiceDetails(invoice),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: BorderSide(color: Colors.lightBlue[600]!),
                      ),
                    ),
                  ),
                  if (invoice.status == InvoiceStatus.pending) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _markAsPaid(invoice),
                        icon: const Icon(Icons.payment, size: 16),
                        label: const Text('Mark Paid'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.pending:
        return Colors.orange;
      case InvoiceStatus.cancelled:
        return Colors.red;
      case InvoiceStatus.draft:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showInvoiceDetails(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => _InvoiceDetailDialog(invoice: invoice),
    );
  }

  void _markAsPaid(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => _MarkAsPaidDialog(
        invoice: invoice,
        onPaid: () {
          _loadInvoices(); // Refresh the list
        },
      ),
    );
  }
}

class _InvoiceDetailDialog extends StatelessWidget {
  final Invoice invoice;

  const _InvoiceDetailDialog({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  invoice.invoiceNumber,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Invoice Info
            _buildDetailRow('Doctor:', invoice.doctorName),
            _buildDetailRow('Date:', _formatDate(invoice.invoiceDate)),
            _buildDetailRow('Due Date:', _formatDate(invoice.dueDate)),
            _buildDetailRow('Status:', invoice.statusDisplay),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Billing Items
            const Text(
              'Items:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: invoice.items.length,
                itemBuilder: (context, index) {
                  final item = invoice.items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(item.description),
                        ),
                        Expanded(
                          child: Text(
                            '${item.quantity.toStringAsFixed(1)}x',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Rs ${item.totalAmount.toStringAsFixed(2)}',
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Totals
            _buildDetailRow('Subtotal:', 'Rs ${invoice.subtotal.toStringAsFixed(2)}'),
            _buildDetailRow('VAT (${invoice.vatRate.toStringAsFixed(1)}%):', 'Rs ${invoice.vatAmount.toStringAsFixed(2)}'),
            _buildDetailRow('Tax (${invoice.taxRate.toStringAsFixed(1)}%):', 'Rs ${invoice.taxAmount.toStringAsFixed(2)}'),
            const Divider(thickness: 2),
            _buildDetailRow('Total:', 'Rs ${invoice.totalAmount.toStringAsFixed(2)}', isBold: true),

            if (invoice.notes != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(invoice.notes!),
            ],
          ],
        ),
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
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _MarkAsPaidDialog extends StatefulWidget {
  final Invoice invoice;
  final VoidCallback onPaid;

  const _MarkAsPaidDialog({
    required this.invoice,
    required this.onPaid,
  });

  @override
  State<_MarkAsPaidDialog> createState() => _MarkAsPaidDialogState();
}

class _MarkAsPaidDialogState extends State<_MarkAsPaidDialog> {
  final InvoiceService _invoiceService = InvoiceService();
  final _referenceController = TextEditingController();
  String selectedPaymentMethod = 'Cash';
  bool isLoading = false;

  final List<String> paymentMethods = [
    'Cash',
    'Bank Transfer',
    'Online Payment',
    'Card Payment',
    'Mobile Payment',
    'Other',
  ];

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mark as Paid'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Invoice: ${widget.invoice.invoiceNumber}'),
          Text('Amount: Rs ${widget.invoice.totalAmount.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: selectedPaymentMethod,
            decoration: const InputDecoration(
              labelText: 'Payment Method',
              border: OutlineInputBorder(),
            ),
            items: paymentMethods.map((method) {
              return DropdownMenuItem(
                value: method,
                child: Text(method),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedPaymentMethod = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _referenceController,
            decoration: const InputDecoration(
              labelText: 'Payment Reference (Optional)',
              hintText: 'Transaction ID, Receipt number, etc.',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _markAsPaid,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Mark as Paid'),
        ),
      ],
    );
  }

  Future<void> _markAsPaid() async {
    setState(() {
      isLoading = true;
    });

    try {
      final success = await _invoiceService.markInvoiceAsPaid(
        invoiceId: widget.invoice.id,
        paymentMethod: selectedPaymentMethod,
        paymentReference: _referenceController.text.isNotEmpty
            ? _referenceController.text
            : null,
      );

      if (success) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invoice marked as paid successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onPaid();
        }
      } else {
        throw Exception('Failed to mark invoice as paid');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}