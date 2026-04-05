import 'package:flutter/material.dart';
import '../models/prescription.dart';
import '../models/patient.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import 'prescription_form.dart';
import 'pharmacy_integration_screen.dart';

class PrescriptionDetailsScreen extends StatefulWidget {
  final Prescription? prescription;
  final int? prescriptionId;

  const PrescriptionDetailsScreen({
    super.key, 
    this.prescription,
    this.prescriptionId,
  });

  @override
  State<PrescriptionDetailsScreen> createState() => _PrescriptionDetailsScreenState();
}

class _PrescriptionDetailsScreenState extends State<PrescriptionDetailsScreen> {
  final _databaseService = DatabaseService();
  
  Prescription? _prescription;
  Patient? _patient;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrescriptionDetails();
  }

  Future<void> _loadPrescriptionDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Prescription? prescription;
      
      if (widget.prescription != null) {
        prescription = widget.prescription;
      } else if (widget.prescriptionId != null) {
        prescription = await _databaseService.getPrescriptionById(widget.prescriptionId!);
      }
      
      if (prescription != null) {
        final patient = await _databaseService.getPatientById(prescription.patientId);
        setState(() {
          _prescription = prescription;
          _patient = patient;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading prescription: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _editPrescription() async {
    if (_prescription == null || _patient == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrescriptionFormScreen(
          patient: _patient!,
          existingPrescription: _prescription!,
        ),
      ),
    );

    if (result == true) {
      _loadPrescriptionDetails();
    }
  }

  Future<void> _printPrescription() async {
    if (_prescription == null || _patient == null) return;

    try {
      await PdfService.printPrescription(_prescription!, _patient!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error printing prescription: $e')),
      );
    }
  }

  Future<void> _sharePrescription() async {
    if (_prescription == null || _patient == null) return;

    try {
      await PdfService.sharePrescription(_prescription!, _patient!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing prescription: $e')),
      );
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    if (_prescription == null) return;

    try {
      await _databaseService.updatePrescriptionStatus(_prescription!.id!, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to ${newStatus.toUpperCase()}')),
      );
      _loadPrescriptionDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  Future<void> _sendToPharmacy() async {
    if (_prescription == null || _patient == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PharmacyIntegrationScreen(
          prescriptionId: _prescription!.id.toString(),
          patientId: _patient!.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_prescription != null 
            ? 'Prescription #${_prescription!.id}' 
            : 'Prescription Details'),
        actions: [
          if (_prescription != null && _patient != null) ...[
            IconButton(
              icon: const Icon(Icons.local_pharmacy),
              onPressed: _sendToPharmacy,
              tooltip: 'Send to Pharmacy',
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editPrescription,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: _printPrescription,
              tooltip: 'Print',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _sharePrescription,
              tooltip: 'Share',
            ),
            PopupMenuButton<String>(
              onSelected: _updateStatus,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'active',
                  child: Text('Mark as Active'),
                ),
                const PopupMenuItem(
                  value: 'completed',
                  child: Text('Mark as Completed'),
                ),
                const PopupMenuItem(
                  value: 'cancelled',
                  child: Text('Mark as Cancelled'),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _prescription == null || _patient == null
              ? const Center(child: Text('Prescription not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Patient Information Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Patient Information',
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                  _buildStatusChip(_prescription!.statusDisplay),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow('Name', '${_patient!.firstName} ${_patient!.lastName}'),
                              _buildInfoRow('Age', '${_patient!.age} years'),
                              _buildInfoRow('Phone', _patient!.phoneNumber),
                              _buildInfoRow('Address', _patient!.address!),
                              if (_patient!.allergies.isNotEmpty == true)
                                _buildInfoRow('Allergies', _patient!.allergies, 
                                    isImportant: true),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Prescription Details Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Prescription Details',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow('Prescription ID', '#${_prescription!.id}'),
                              _buildInfoRow('Date', 
                                  _prescription!.prescriptionDate.toString().split(' ')[0]),
                              _buildInfoRow('Doctor', _prescription!.doctorName),
                              _buildInfoRow('Doctor ID', _prescription!.doctorId),
                              _buildInfoRow('Diagnosis', _prescription!.diagnosis),
                              if (_prescription!.followUpDate != null)
                                _buildInfoRow('Follow-up Date', 
                                    _prescription!.followUpDate.toString().split(' ')[0]),
                              if (_prescription!.notes.isNotEmpty)
                                _buildInfoRow('Notes', _prescription!.notes),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Medications Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Medications (${_prescription!.medications.length})',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 16),
                              ..._prescription!.medications.asMap().entries.map((entry) {
                                final index = entry.key;
                                final medication = entry.value;
                                return _buildMedicationCard(index + 1, medication);
                              }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Action Buttons
                      Column(
                        children: [
                          // Send to Pharmacy Button - Primary action
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.local_pharmacy),
                              label: const Text('Send to Pharmacy in Nepal'),
                              onPressed: _sendToPharmacy,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Secondary actions
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.print),
                                  label: const Text('Print'),
                                  onPressed: _printPrescription,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[600],
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.share),
                                  label: const Text('Share'),
                                  onPressed: _sharePrescription,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[600],
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isImportant = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isImportant ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(int index, Medication medication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Medication $index',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Chip(
                  label: Text(medication.form.toUpperCase()),
                  backgroundColor: Colors.blue.shade100,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMedicationInfoRow('Name', medication.name),
            _buildMedicationInfoRow('Dosage', medication.dosage),
            _buildMedicationInfoRow('Frequency', medication.frequency),
            _buildMedicationInfoRow('Duration', medication.duration),
            _buildMedicationInfoRow('Quantity', medication.quantity.toString()),
            if (medication.genericName?.isNotEmpty == true)
              _buildMedicationInfoRow('Generic Name', medication.genericName!),
            if (medication.instructions.isNotEmpty)
              _buildMedicationInfoRow('Instructions', medication.instructions),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'active':
        color = Colors.green;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }
}
