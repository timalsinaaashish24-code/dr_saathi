import 'package:flutter/material.dart';
import '../services/invoice_service.dart';
import '../models/invoice.dart';

class BillingReportsScreen extends StatefulWidget {
  final String? doctorId;

  const BillingReportsScreen({
    super.key,
    this.doctorId,
  });

  @override
  State<BillingReportsScreen> createState() => _BillingReportsScreenState();
}

class _BillingReportsScreenState extends State<BillingReportsScreen> {
  final InvoiceService _invoiceService = InvoiceService();
  
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();
  
  Map<String, dynamic> taxReport = {};
  Map<String, dynamic> invoiceStats = {};
  List<Invoice> recentInvoices = [];
  
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    if (widget.doctorId == null) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      // Load tax report
      final taxData = await _invoiceService.generateTaxReport(
        doctorId: widget.doctorId!,
        startDate: startDate,
        endDate: endDate,
      );
      
      // Load invoice statistics
      final statsData = await _invoiceService.getInvoiceStats(widget.doctorId!);
      
      // Load recent invoices
      final invoices = await _invoiceService.getInvoicesForDoctor(widget.doctorId!);
      
      setState(() {
        taxReport = taxData;
        invoiceStats = statsData;
        recentInvoices = invoices.take(10).toList(); // Show only recent 10
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading reports: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Billing Reports'),
        backgroundColor: Colors.lightBlue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Selector
                  _buildDateRangeSelector(),
                  const SizedBox(height: 24),
                  
                  // Key Statistics Cards
                  _buildStatisticsCards(),
                  const SizedBox(height: 24),
                  
                  // Tax Report
                  _buildTaxReportCard(),
                  const SizedBox(height: 24),
                  
                  // Revenue Chart (placeholder)
                  _buildRevenueChart(),
                  const SizedBox(height: 24),
                  
                  // Recent Invoices
                  _buildRecentInvoicesCard(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _exportReport,
        backgroundColor: Colors.lightBlue[600],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.file_download),
        label: const Text('Export Report'),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
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
            'Report Period',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectDate(true),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    'From: ${_formatDate(startDate)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectDate(false),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    'To: ${_formatDate(endDate)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    final totalInvoices = invoiceStats['total_invoices'] ?? 0;
    final totalRevenue = (invoiceStats['total_revenue'] ?? 0.0).toDouble();
    final totalCollected = (invoiceStats['total_collected'] ?? 0.0).toDouble();
    final pendingInvoices = invoiceStats['pending_invoices'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Invoices',
            totalInvoices.toString(),
            Colors.blue,
            Icons.receipt,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Revenue',
            'Rs ${totalRevenue.toStringAsFixed(0)}',
            Colors.green,
            Icons.monetization_on,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
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
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxReportCard() {
    final totalSubtotal = (taxReport['total_subtotal'] ?? 0.0).toDouble();
    final totalVat = (taxReport['total_vat'] ?? 0.0).toDouble();
    final totalTax = (taxReport['total_tax'] ?? 0.0).toDouble();
    final totalAmount = (taxReport['total_amount'] ?? 0.0).toDouble();

    return Container(
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
          Row(
            children: [
              Icon(Icons.account_balance, color: Colors.indigo[600]),
              const SizedBox(width: 8),
              const Text(
                'Tax Report',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildTaxReportRow('Period:', '${_formatDate(startDate)} - ${_formatDate(endDate)}'),
          _buildTaxReportRow('Subtotal:', 'Rs ${totalSubtotal.toStringAsFixed(2)}'),
          _buildTaxReportRow('VAT Collected:', 'Rs ${totalVat.toStringAsFixed(2)}'),
          _buildTaxReportRow('Additional Tax:', 'Rs ${totalTax.toStringAsFixed(2)}'),
          const Divider(thickness: 1),
          _buildTaxReportRow(
            'Total Amount:', 
            'Rs ${totalAmount.toStringAsFixed(2)}', 
            isBold: true,
            color: Colors.indigo[600],
          ),
          
          const SizedBox(height: 16),
          
          // Tax breakdown chart
          if (totalVat > 0 || totalTax > 0) _buildTaxBreakdownChart(),
        ],
      ),
    );
  }

  Widget _buildTaxReportRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxBreakdownChart() {
    final totalSubtotal = (taxReport['total_subtotal'] ?? 0.0).toDouble();
    final totalVat = (taxReport['total_vat'] ?? 0.0).toDouble();
    final totalTax = (taxReport['total_tax'] ?? 0.0).toDouble();
    final totalAmount = totalSubtotal + totalVat + totalTax;

    if (totalAmount == 0) return const SizedBox.shrink();

    final subtotalPercent = (totalSubtotal / totalAmount) * 100;
    final vatPercent = (totalVat / totalAmount) * 100;
    final taxPercent = (totalTax / totalAmount) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tax Breakdown:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        
        // Simple progress bars for visualization
        _buildProgressRow('Services', subtotalPercent, Colors.blue[300]!),
        _buildProgressRow('VAT', vatPercent, Colors.orange[300]!),
        _buildProgressRow('Additional Tax', taxPercent, Colors.red[300]!),
      ],
    );
  }

  Widget _buildProgressRow(String label, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Container(
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
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.green[600]),
              const SizedBox(width: 8),
              const Text(
                'Revenue Trend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Placeholder for chart - in a real app, you'd use a charting library
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Revenue Chart',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '(Chart integration coming soon)',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentInvoicesCard() {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_long, color: Colors.purple[600]),
                  const SizedBox(width: 8),
                  const Text(
                    'Recent Invoices',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full invoices list
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (recentInvoices.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No invoices found',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentInvoices.take(5).length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final invoice = recentInvoices[index];
                return _buildInvoiceRow(invoice);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(Invoice invoice) {
    final statusColor = _getStatusColor(invoice.status);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.invoiceNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  invoice.patientName,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              'Rs ${invoice.totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              invoice.statusDisplay,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      _loadReports();
    }
  }

  Future<void> _selectDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate : endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
      _loadReports();
    }
  }

  void _exportReport() {
    // TODO: Implement report export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}