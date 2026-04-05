import 'package:flutter/material.dart';
import '../models/prescription.dart';
import '../services/digital_prescription_service.dart';
import '../services/pharmacy_service.dart';
import '../models/pharmacy.dart';
import '../generated/l10n/app_localizations.dart';

class PatientPrescriptionsScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PatientPrescriptionsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<PatientPrescriptionsScreen> createState() => _PatientPrescriptionsScreenState();
}

class _PatientPrescriptionsScreenState extends State<PatientPrescriptionsScreen> {
  final _digitalPrescriptionService = DigitalPrescriptionService();
  final _pharmacyService = PharmacyService();

  List<Prescription> _prescriptions = [];
  List<Pharmacy> _pharmacies = [];
  bool _isLoading = false;
  bool _isLoadingPharmacies = false;
  String _filter = 'all'; // all, active, completed

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
    _loadPharmacies();
  }

  Future<void> _loadPrescriptions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prescriptions = await _digitalPrescriptionService.getPrescriptionsByPatient(widget.patientId);
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

  Future<void> _loadPharmacies() async {
    setState(() {
      _isLoadingPharmacies = true;
    });

    try {
      final pharmacies = await _pharmacyService.getAllPharmacies();
      setState(() {
        _pharmacies = pharmacies;
      });
    } catch (e) {
      print('Failed to load pharmacies: $e');
    } finally {
      setState(() {
        _isLoadingPharmacies = false;
      });
    }
  }

  List<Prescription> get _filteredPrescriptions {
    switch (_filter) {
      case 'active':
        return _prescriptions.where((p) => 
          p.status == PrescriptionStatus.sent || 
          p.status == PrescriptionStatus.received
        ).toList();
      case 'completed':
        return _prescriptions.where((p) => 
          p.status == PrescriptionStatus.dispensed || 
          p.status == PrescriptionStatus.completed
        ).toList();
      default:
        return _prescriptions;
    }
  }

  void _showPrescriptionDetails(Prescription prescription) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PrescriptionDetailSheet(
        prescription: prescription,
        pharmacies: _pharmacies,
        onSendToPharmacy: _sendPrescriptionToPharmacy,
      ),
    );
  }

  Future<void> _sendPrescriptionToPharmacy(Prescription prescription, Pharmacy pharmacy) async {
    try {
      final success = await _digitalPrescriptionService.sendPrescriptionToPharmacy(
        prescription.id!,
        pharmacy.id,
        pharmacy.name,
      );

      if (success) {
        _showSuccessSnackBar('Prescription sent to ${pharmacy.name}');
        _loadPrescriptions(); // Refresh the list
        Navigator.of(context).pop(); // Close the bottom sheet
      } else {
        _showErrorSnackBar('Failed to send prescription to pharmacy');
      }
    } catch (e) {
      _showErrorSnackBar('Error sending prescription: $e');
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
      case PrescriptionStatus.draft:
        return Colors.grey;
      case PrescriptionStatus.sent:
        return Colors.blue;
      case PrescriptionStatus.received:
        return Colors.orange;
      case PrescriptionStatus.dispensed:
        return Colors.green;
      case PrescriptionStatus.completed:
        return Colors.green.shade700;
      case PrescriptionStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(PrescriptionStatus status) {
    switch (status) {
      case PrescriptionStatus.draft:
        return Icons.edit_note;
      case PrescriptionStatus.sent:
        return Icons.send;
      case PrescriptionStatus.received:
        return Icons.local_pharmacy;
      case PrescriptionStatus.dispensed:
        return Icons.medication;
      case PrescriptionStatus.completed:
        return Icons.check_circle;
      case PrescriptionStatus.cancelled:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Prescriptions'),
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
                      ButtonSegment(value: 'all', label: Text('All')),
                      ButtonSegment(value: 'active', label: Text('Active')),
                      ButtonSegment(value: 'completed', label: Text('Completed')),
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
                              Icons.medication_outlined,
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
                              _filter == 'all' 
                                ? 'You haven\'t received any prescriptions yet'
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
                                                  'Dr. ${prescription.doctorName}',
                                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  prescription.diagnosis,
                                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: Colors.grey.shade600,
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
                                              SizedBox(height: 4),
                                              if (prescription.isUrgent)
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
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                                          SizedBox(width: 4),
                                          Text(
                                            '${prescription.prescriptionDate.day}/${prescription.prescriptionDate.month}/${prescription.prescriptionDate.year}',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Icon(Icons.medication, size: 16, color: Colors.grey.shade600),
                                          SizedBox(width: 4),
                                          Text(
                                            '${prescription.medications.length} medication(s)',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (prescription.pharmacyName != null) ...[
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.local_pharmacy, size: 16, color: Colors.blue.shade600),
                                            SizedBox(width: 4),
                                            Text(
                                              'Sent to: ${prescription.pharmacyName}',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.blue.shade600,
                                                fontWeight: FontWeight.w500,
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

class PrescriptionDetailSheet extends StatefulWidget {
  final Prescription prescription;
  final List<Pharmacy> pharmacies;
  final Function(Prescription, Pharmacy) onSendToPharmacy;

  const PrescriptionDetailSheet({
    super.key,
    required this.prescription,
    required this.pharmacies,
    required this.onSendToPharmacy,
  });

  @override
  State<PrescriptionDetailSheet> createState() => _PrescriptionDetailSheetState();
}

class _PrescriptionDetailSheetState extends State<PrescriptionDetailSheet> {
  bool _showPharmacySelection = false;
  Pharmacy? _selectedPharmacy;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
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

                      // Doctor Information
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Doctor Information',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text('Dr. ${widget.prescription.doctorName}'),
                              if (widget.prescription.doctorLicenseNumber != null)
                                Text('License: ${widget.prescription.doctorLicenseNumber}'),
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
                              SizedBox(height: 8),
                              Text(
                                'Date: ${widget.prescription.prescriptionDate.day}/${widget.prescription.prescriptionDate.month}/${widget.prescription.prescriptionDate.year}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
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
                                'Medications',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              ...widget.prescription.medications.map((medication) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        medication.name,
                                        style: TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      Text('${medication.dosage} ${medication.form}'),
                                      Text('Frequency: ${medication.frequency}'),
                                      Text('Duration: ${medication.duration}'),
                                      Text('Quantity: ${medication.quantity}'),
                                      if (medication.instructions.isNotEmpty)
                                        Text(
                                          'Instructions: ${medication.instructions}',
                                          style: TextStyle(fontStyle: FontStyle.italic),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),

                      // Pharmacy Selection
                      if (_showPharmacySelection) ...[
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Pharmacy',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16),
                                ...widget.pharmacies.take(5).map((pharmacy) {
                                  return RadioListTile<Pharmacy>(
                                    value: pharmacy,
                                    groupValue: _selectedPharmacy,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPharmacy = value;
                                      });
                                    },
                                    title: Text(pharmacy.name),
                                    subtitle: Text(pharmacy.address),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],

                      // Action Buttons
                      if (widget.prescription.status == PrescriptionStatus.sent && widget.prescription.pharmacyId == null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _showPharmacySelection = !_showPharmacySelection;
                              });
                            },
                            icon: Icon(Icons.local_pharmacy),
                            label: Text(_showPharmacySelection ? 'Cancel' : 'Send to Pharmacy'),
                          ),
                        ),

                      if (_showPharmacySelection && _selectedPharmacy != null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              widget.onSendToPharmacy(widget.prescription, _selectedPharmacy!);
                            },
                            child: Text('Send to ${_selectedPharmacy!.name}'),
                          ),
                        ),

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
