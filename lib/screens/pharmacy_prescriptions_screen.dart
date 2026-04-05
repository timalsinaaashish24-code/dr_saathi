import 'package:flutter/material.dart';
import '../models/prescription.dart';
import '../services/digital_prescription_service.dart';
import '../generated/l10n/app_localizations.dart';

class PharmacyPrescriptionsScreen extends StatefulWidget {
  final String pharmacyId;
  final String pharmacyName;

  const PharmacyPrescriptionsScreen({
    super.key,
    required this.pharmacyId,
    required this.pharmacyName,
  });

  @override
  State<PharmacyPrescriptionsScreen> createState() => _PharmacyPrescriptionsScreenState();
}

class _PharmacyPrescriptionsScreenState extends State<PharmacyPrescriptionsScreen> {
  final _digitalPrescriptionService = DigitalPrescriptionService();

  List<Prescription> _prescriptions = [];
  bool _isLoading = false;
  String _filter = 'received'; // received, dispensed, all

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prescriptions = await _digitalPrescriptionService.getPrescriptionsByPharmacy(widget.pharmacyId);
      setState(() {
        _prescriptions = prescriptions;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load prescriptions: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Prescription> get _filteredPrescriptions {
    switch (_filter) {
      case 'received':
        return _prescriptions.where((p) => p.status == PrescriptionStatus.received).toList();
      case 'dispensed':
        return _prescriptions.where((p) => p.status == PrescriptionStatus.dispensed).toList();
      default:
        return _prescriptions;
    }
  }

  void _showPrescriptionDetails(Prescription prescription) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PharmacyPrescriptionDetailSheet(
        prescription: prescription,
        pharmacyId: widget.pharmacyId,
        onMarkDispensed: _markPrescriptionDispensed,
      ),
    );
  }

  Future<void> _markPrescriptionDispensed(Prescription prescription) async {
    try {
      final success = await _digitalPrescriptionService.markPrescriptionDispensed(
        prescription.id!,
        widget.pharmacyId,
      );

      if (success) {
        _showSuccessSnackBar('Prescription marked as dispensed');
        _loadPrescriptions(); // Refresh the list
        Navigator.of(context).pop(); // Close the bottom sheet
      } else {
        _showErrorSnackBar('Failed to mark prescription as dispensed');
      }
    } catch (e) {
      _showErrorSnackBar('Error updating prescription: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Color _getStatusColor(PrescriptionStatus status) {
    switch (status) {
      case PrescriptionStatus.received:
        return Colors.orange;
      case PrescriptionStatus.dispensed:
        return Colors.green;
      case PrescriptionStatus.completed:
        return Colors.green.shade700;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(PrescriptionStatus status) {
    switch (status) {
      case PrescriptionStatus.received:
        return Icons.pending_actions;
      case PrescriptionStatus.dispensed:
        return Icons.medication;
      case PrescriptionStatus.completed:
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pharmacy Prescriptions'),
            Text(widget.pharmacyName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadPrescriptions,
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'received', label: Text('New')),
                      ButtonSegment(value: 'dispensed', label: Text('Dispensed')),
                      ButtonSegment(value: 'all', label: Text('All')),
                    ],
                    selected: {_filter},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _filter = newSelection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Stats cards
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            '${_prescriptions.where((p) => p.status == PrescriptionStatus.received).length}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Pending',
                            style: TextStyle(color: Colors.orange.shade700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            '${_prescriptions.where((p) => p.status == PrescriptionStatus.dispensed).length}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Dispensed',
                            style: TextStyle(color: Colors.green.shade700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Prescriptions list
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredPrescriptions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_pharmacy_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No prescriptions found',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              _filter == 'received'
                                  ? 'No new prescriptions to process'
                                  : 'No $_filter prescriptions found',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPrescriptions,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _filteredPrescriptions.length,
                          itemBuilder: (context, index) {
                            final prescription = _filteredPrescriptions[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 16),
                              child: InkWell(
                                onTap: () => _showPrescriptionDetails(prescription),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  prescription.patientName,
                                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  'Prescribed by: Dr. ${prescription.doctorName}',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                SizedBox(height: 2),
                                                Text(
                                                  prescription.diagnosis,
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(prescription.status).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      _getStatusIcon(prescription.status),
                                                      size: 16,
                                                      color: _getStatusColor(prescription.status),
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      prescription.statusDisplay,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: _getStatusColor(prescription.status),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (prescription.isUrgent) ...[
                                                SizedBox(height: 4),
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red.shade100,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    'URGENT',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.red.shade700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                                          SizedBox(width: 4),
                                          Text(
                                            'Prescribed: ${prescription.prescriptionDate.day}/${prescription.prescriptionDate.month}/${prescription.prescriptionDate.year}',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Icon(Icons.medication, size: 16, color: Colors.grey.shade600),
                                          SizedBox(width: 4),
                                          Text(
                                            '${prescription.medications.length} medicine(s)',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (prescription.patientPhone != null) ...[
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.phone, size: 16, color: Colors.blue.shade600),
                                            SizedBox(width: 4),
                                            Text(
                                              prescription.patientPhone!,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.blue.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class PharmacyPrescriptionDetailSheet extends StatefulWidget {
  final Prescription prescription;
  final String pharmacyId;
  final Function(Prescription) onMarkDispensed;

  const PharmacyPrescriptionDetailSheet({
    super.key,
    required this.prescription,
    required this.pharmacyId,
    required this.onMarkDispensed,
  });

  @override
  State<PharmacyPrescriptionDetailSheet> createState() => _PharmacyPrescriptionDetailSheetState();
}

class _PharmacyPrescriptionDetailSheetState extends State<PharmacyPrescriptionDetailSheet> {
  bool _showDispenseConfirmation = false;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Prescription Details',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(Icons.close),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      // Patient Information
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patient Information',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text('Name: ${widget.prescription.patientName}'),
                              if (widget.prescription.patientPhone != null)
                                Text('Phone: ${widget.prescription.patientPhone}'),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Doctor Information
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Prescribing Doctor',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text('Dr. ${widget.prescription.doctorName}'),
                              if (widget.prescription.doctorLicenseNumber != null)
                                Text('License: ${widget.prescription.doctorLicenseNumber}'),
                              Text(
                                'Date: ${widget.prescription.prescriptionDate.day}/${widget.prescription.prescriptionDate.month}/${widget.prescription.prescriptionDate.year}',
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Medical Information
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Medical Information',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text('Diagnosis: ${widget.prescription.diagnosis}'),
                              if (widget.prescription.symptoms != null)
                                Text('Symptoms: ${widget.prescription.symptoms}'),
                              if (widget.prescription.notes.isNotEmpty)
                                Text('Notes: ${widget.prescription.notes}'),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Medications
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Medications to Dispense',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              ...widget.prescription.medications.asMap().entries.map((entry) {
                                final index = entry.key;
                                final medication = entry.value;
                                return Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey.shade50,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue.shade700,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              medication.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text('Dosage: ${medication.dosage}'),
                                      Text('Form: ${medication.form.toUpperCase()}'),
                                      Text('Frequency: ${medication.frequency}'),
                                      Text('Duration: ${medication.duration}'),
                                      Text(
                                        'Quantity: ${medication.quantity}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                      if (medication.instructions.isNotEmpty) ...[
                                        SizedBox(height: 4),
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.shade50,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: Colors.amber.shade200),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                size: 16,
                                                color: Colors.amber.shade700,
                                              ),
                                              SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  'Instructions: ${medication.instructions}',
                                                  style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.amber.shade700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Digital Signature
                      if (widget.prescription.digitalSignature != null)
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Digital Verification',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.verified, color: Colors.green, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Prescription verified',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Signature: ${widget.prescription.digitalSignature!.substring(0, 20)}...',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      SizedBox(height: 24),

                      // Action Buttons
                      if (widget.prescription.status == PrescriptionStatus.received)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _showDispenseConfirmation = !_showDispenseConfirmation;
                              });
                            },
                            icon: Icon(Icons.medication),
                            label: Text(_showDispenseConfirmation ? 'Cancel' : 'Mark as Dispensed'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _showDispenseConfirmation ? Colors.grey : Colors.green,
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),

                      if (_showDispenseConfirmation) ...[
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.check_circle_outline, color: Colors.green.shade700),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Confirm that all medications have been dispensed to the patient',
                                      style: TextStyle(color: Colors.green.shade700),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    widget.onMarkDispensed(widget.prescription);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: Text(
                                    'Confirm Dispensed',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
