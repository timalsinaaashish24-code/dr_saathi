import 'package:flutter/material.dart';
import '../models/consultation.dart';
import '../models/billing_item.dart';
import '../services/auto_billing_service.dart';
import 'patient_invoice_view.dart';

class CompleteConsultationScreen extends StatefulWidget {
  final Consultation consultation;

  const CompleteConsultationScreen({
    Key? key,
    required this.consultation,
  }) : super(key: key);

  @override
  State<CompleteConsultationScreen> createState() => _CompleteConsultationScreenState();
}

class _CompleteConsultationScreenState extends State<CompleteConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _prescriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final AutoBillingService _billingService = AutoBillingService();
  
  List<BillingItem> additionalCharges = [];
  bool _isProcessing = false;

  @override
  void dispose() {
    _diagnosisController.dispose();
    _prescriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _completeConsultation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Complete consultation and generate bill automatically
      final billId = await _billingService.completeConsultationAndGenerateBill(
        consultationId: widget.consultation.id,
        diagnosis: _diagnosisController.text.trim(),
        prescription: _prescriptionController.text.trim(),
        additionalNotes: _notesController.text.trim(),
        additionalCharges: additionalCharges.isNotEmpty ? additionalCharges : null,
      );

      if (billId != null && mounted) {
        // Show success dialog
        _showSuccessDialog(billId);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate bill. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
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
          _isProcessing = false;
        });
      }
    }
  }

  void _showSuccessDialog(String billId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 32),
            const SizedBox(width: 12),
            const Text('Consultation Completed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The consultation has been completed successfully.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.receipt_long, size: 20, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Bill Generated',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Bill ID: ${billId.substring(0, 20)}...'),
                  const SizedBox(height: 4),
                  Text(
                    'Amount: NPR ${widget.consultation.consultationFee.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '✓ Bill has been sent to patient via SMS\n'
              '✓ Email notification sent\n'
              '✓ Push notification delivered',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close completion screen
            },
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Navigate to bill view
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientInvoiceView(patientId: billId),
                ),
              );
            },
            icon: const Icon(Icons.visibility),
            label: const Text('View Bill'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _addAdditionalCharge() {
    showDialog(
      context: context,
      builder: (context) {
        final descController = TextEditingController();
        final priceController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Add Additional Charge'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g., Lab tests, Medicines',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (NPR)',
                  border: OutlineInputBorder(),
                  prefixText: 'NPR ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (descController.text.isNotEmpty && priceController.text.isNotEmpty) {
                  final price = double.tryParse(priceController.text);
                  if (price != null) {
                    setState(() {
                      additionalCharges.add(
                        BillingItem.create(
                          description: descController.text,
                          type: BillingItemType.other,
                          quantity: 1,
                          unitPrice: price,
                          category: 'Additional',
                        ),
                      );
                    });
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Consultation'),
        backgroundColor: Colors.lightBlue[600],
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Info Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Patient Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),
                      _buildInfoRow('Patient', widget.consultation.patientName),
                      const SizedBox(height: 8),
                      _buildInfoRow('Doctor', widget.consultation.doctorName),
                      const SizedBox(height: 8),
                      _buildInfoRow('Date', widget.consultation.consultationDate.toString().split(' ')[0]),
                      const SizedBox(height: 8),
                      _buildInfoRow('Type', widget.consultation.consultationType.toUpperCase()),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Consultation Fee',
                        'NPR ${widget.consultation.consultationFee.toStringAsFixed(2)}',
                        valueColor: Colors.green[700],
                        valueBold: true,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // Diagnosis
              const Text(
                'Diagnosis',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _diagnosisController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter patient diagnosis...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter diagnosis';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Prescription
              const Text(
                'Prescription',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _prescriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Enter prescription details...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter prescription';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Additional Notes
              const Text(
                'Additional Notes (Optional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Any additional notes or instructions...',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              // Additional Charges Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Additional Charges',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addAdditionalCharge,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Charge'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (additionalCharges.isNotEmpty)
                Card(
                  child: Column(
                    children: additionalCharges.map((item) {
                      return ListTile(
                        leading: const Icon(Icons.attach_money, color: Colors.green),
                        title: Text(item.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'NPR ${item.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () {
                                setState(() {
                                  additionalCharges.remove(item);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'No additional charges',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Total Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Consultation Fee', widget.consultation.consultationFee),
                    if (additionalCharges.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                        'Additional Charges',
                        additionalCharges.fold(0.0, (sum, item) => sum + item.total),
                      ),
                    ],
                    const Divider(height: 24),
                    _buildSummaryRow(
                      'Subtotal',
                      widget.consultation.consultationFee +
                          additionalCharges.fold(0.0, (sum, item) => sum + item.total),
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'VAT (13%)',
                      (widget.consultation.consultationFee +
                              additionalCharges.fold(0.0, (sum, item) => sum + item.total)) *
                          0.13,
                    ),
                    const Divider(height: 24),
                    _buildSummaryRow(
                      'Total Amount',
                      (widget.consultation.consultationFee +
                              additionalCharges.fold(0.0, (sum, item) => sum + item.total)) *
                          1.13,
                      bold: true,
                      large: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Complete Consultation Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _completeConsultation,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check_circle, size: 24),
                  label: Text(
                    _isProcessing ? 'Processing...' : 'Complete & Generate Bill',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Info Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bill will be automatically generated and sent to the patient via SMS, email, and push notification immediately after completion.',
                        style: TextStyle(fontSize: 12, color: Colors.amber[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor, bool valueBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool bold = false, bool large = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: large ? 16 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          'NPR ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: large ? 18 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            color: bold ? Colors.green[700] : null,
          ),
        ),
      ],
    );
  }
}
