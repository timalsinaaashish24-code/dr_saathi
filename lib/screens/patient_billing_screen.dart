import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../models/billing_item.dart';
import '../services/invoice_service.dart';
import '../services/database_service.dart';

class PatientBillingScreen extends StatefulWidget {
  final String? patientId;
  final String? patientName;

  const PatientBillingScreen({
    super.key,
    this.patientId,
    this.patientName,
  });

  @override
  State<PatientBillingScreen> createState() => _PatientBillingScreenState();
}

class _PatientBillingScreenState extends State<PatientBillingScreen> {
  final InvoiceService _invoiceService = InvoiceService();
  final DatabaseService _dbService = DatabaseService();
  
  String? selectedPatientId;
  String? selectedPatientName;
  List<BillingItem> billingItems = [];
  List<Map<String, dynamic>> patients = [];
  
  final _notesController = TextEditingController();
  double vatRate = 13.0; // Nepal VAT rate
  double taxRate = 1.5;  // Additional tax rate
  int paymentTermDays = 30;
  
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedPatientId = widget.patientId;
    selectedPatientName = widget.patientName;
    _loadPatients();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    try {
      final result = await (await _dbService.database).query(
        'patients',
        columns: ['id', 'first_name', 'last_name', 'phone_number'],
        orderBy: 'first_name ASC',
      );
      
      setState(() {
        patients = result;
      });
    } catch (e) {
      print('Error loading patients: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Create Invoice'),
        backgroundColor: Colors.lightBlue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDraft,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient Selection
                  _buildPatientSelection(),
                  const SizedBox(height: 24),
                  
                  // Billing Items
                  _buildBillingItemsSection(),
                  const SizedBox(height: 24),
                  
                  // Tax Settings
                  _buildTaxSettings(),
                  const SizedBox(height: 24),
                  
                  // Notes
                  _buildNotesSection(),
                  const SizedBox(height: 24),
                  
                  // Invoice Summary
                  if (billingItems.isNotEmpty) _buildInvoiceSummary(),
                ],
              ),
            ),
          ),
          
          // Bottom Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildPatientSelection() {
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
            'Select Patient',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedPatientId,
            decoration: const InputDecoration(
              labelText: 'Patient',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: patients.map((patient) {
              final fullName = '${patient['first_name']} ${patient['last_name']}';
              return DropdownMenuItem<String>(
                value: patient['id'],
                child: Text(fullName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedPatientId = value;
                final selectedPatient = patients.firstWhere(
                  (p) => p['id'] == value,
                  orElse: () => {},
                );
                if (selectedPatient.isNotEmpty) {
                  selectedPatientName = '${selectedPatient['first_name']} ${selectedPatient['last_name']}';
                }
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a patient';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBillingItemsSection() {
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
              const Text(
                'Billing Items',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddBillingItemDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (billingItems.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Column(
                children: [
                  Icon(Icons.receipt_long, color: Colors.grey[400], size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'No billing items added yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap "Add Item" to add services or procedures',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: billingItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = billingItems[index];
                return _buildBillingItemCard(item, index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBillingItemCard(BillingItem item, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.typeDisplay,
                        style: TextStyle(
                          color: Colors.lightBlue[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Qty: ${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs ${item.unitPrice.toStringAsFixed(2)} × ${item.quantity.toStringAsFixed(1)} = Rs ${item.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red[400]),
            onPressed: () => _removeBillingItem(index),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxSettings() {
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
            'Tax Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: vatRate.toString(),
                  decoration: const InputDecoration(
                    labelText: 'VAT Rate (%)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final rate = double.tryParse(value) ?? vatRate;
                    setState(() {
                      vatRate = rate;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: taxRate.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Additional Tax (%)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final rate = double.tryParse(value) ?? taxRate;
                    setState(() {
                      taxRate = rate;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: paymentTermDays.toString(),
            decoration: const InputDecoration(
              labelText: 'Payment Terms (Days)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final days = int.tryParse(value) ?? paymentTermDays;
              setState(() {
                paymentTermDays = days;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
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
            'Notes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              hintText: 'Add any additional notes or instructions...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceSummary() {
    final subtotal = billingItems.fold<double>(
      0.0,
      (sum, item) => sum + item.totalAmount,
    );
    final vatAmount = subtotal * (vatRate / 100);
    final taxAmount = subtotal * (taxRate / 100);
    final totalAmount = subtotal + vatAmount + taxAmount;

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
            'Invoice Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Subtotal:', 'Rs ${subtotal.toStringAsFixed(2)}'),
          _buildSummaryRow('VAT (${vatRate.toStringAsFixed(1)}%):', 'Rs ${vatAmount.toStringAsFixed(2)}'),
          _buildSummaryRow('Additional Tax (${taxRate.toStringAsFixed(1)}%):', 'Rs ${taxAmount.toStringAsFixed(2)}'),
          const Divider(thickness: 2),
          _buildSummaryRow('Total Amount:', 'Rs ${totalAmount.toStringAsFixed(2)}', isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
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
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.lightBlue[700] : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _previewInvoice,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.lightBlue[600]!),
              ),
              child: Text(
                'Preview',
                style: TextStyle(color: Colors.lightBlue[600]),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _canGenerateInvoice() ? _generateAndSendInvoice : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Send Invoice'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canGenerateInvoice() {
    return selectedPatientId != null && billingItems.isNotEmpty && !isLoading;
  }

  void _showAddBillingItemDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddBillingItemDialog(
        onItemAdded: (item) {
          setState(() {
            billingItems.add(item);
          });
        },
      ),
    );
  }

  void _removeBillingItem(int index) {
    setState(() {
      billingItems.removeAt(index);
    });
  }

  void _previewInvoice() {
    if (!_canGenerateInvoice()) return;

    // TODO: Show invoice preview dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice preview feature coming soon!')),
    );
  }

  Future<void> _saveDraft() async {
    // TODO: Save invoice as draft
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice saved as draft!')),
    );
  }

  Future<void> _generateAndSendInvoice() async {
    if (!_canGenerateInvoice()) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Generate invoice
      final invoice = await _invoiceService.generateInvoice(
        patientId: selectedPatientId!,
        patientName: selectedPatientName!,
        doctorId: 'doctor123', // TODO: Get from auth service
        doctorName: 'Dr. Sample', // TODO: Get from auth service
        items: billingItems,
        vatRate: vatRate,
        taxRate: taxRate,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        paymentTermDays: paymentTermDays,
      );

      // Send to patient
      final sent = await _invoiceService.sendInvoiceToPatient(
        invoice: invoice,
        sendSms: true,
      );

      if (sent) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invoice ${invoice.invoiceNumber} sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, invoice);
        }
      } else {
        throw Exception('Failed to send invoice');
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

class _AddBillingItemDialog extends StatefulWidget {
  final Function(BillingItem) onItemAdded;

  const _AddBillingItemDialog({required this.onItemAdded});

  @override
  State<_AddBillingItemDialog> createState() => _AddBillingItemDialogState();
}

class _AddBillingItemDialogState extends State<_AddBillingItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _unitPriceController = TextEditingController();
  
  BillingItemType selectedType = BillingItemType.consultation;
  String? selectedCategory;
  
  final List<String> categories = [
    'Medical Services',
    'Laboratory',
    'Imaging',
    'Procedures',
    'Documentation',
    'Other',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Billing Item'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick add from common items
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Add:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: BillingItem.getCommonBillingItems().take(4).map((item) {
                          return ActionChip(
                            label: Text(
                              item.description,
                              style: const TextStyle(fontSize: 12),
                            ),
                            onPressed: () {
                              _descriptionController.text = item.description;
                              _quantityController.text = item.quantity.toString();
                              _unitPriceController.text = item.unitPrice.toString();
                              setState(() {
                                selectedType = item.type;
                                selectedCategory = item.category;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<BillingItemType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: BillingItemType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(BillingItem.create(
                        description: '',
                        type: type,
                        quantity: 1,
                        unitPrice: 0,
                      ).typeDisplay),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Invalid quantity';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _unitPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Unit Price (Rs) *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null || double.parse(value) < 0) {
                            return 'Invalid price';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue[600],
            foregroundColor: Colors.white,
          ),
          child: const Text('Add Item'),
        ),
      ],
    );
  }

  void _addItem() {
    if (_formKey.currentState!.validate()) {
      final item = BillingItem.create(
        description: _descriptionController.text,
        type: selectedType,
        quantity: double.parse(_quantityController.text),
        unitPrice: double.parse(_unitPriceController.text),
        category: selectedCategory,
      );
      
      widget.onItemAdded(item);
      Navigator.pop(context);
    }
  }
}