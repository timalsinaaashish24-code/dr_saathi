import 'package:flutter/material.dart';
import 'package:dr_saathi/generated/l10n/app_localizations.dart';
import '../models/patient.dart';
import '../services/database_service.dart';
import 'patient_registration.dart';
import 'sms_reminder_screen.dart';
import 'prescriptions_list.dart';
import 'prescription_form.dart';

class PatientDetails extends StatefulWidget {
  final Patient patient;

  const PatientDetails({super.key, required this.patient});

  @override
  _PatientDetailsState createState() => _PatientDetailsState();
}

class _PatientDetailsState extends State<PatientDetails> {
  final DatabaseService _databaseService = DatabaseService();
  late Patient _patient;

  @override
  void initState() {
    super.initState();
    _patient = widget.patient;
  }

  Future<void> _deletePatient() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmDelete),
        content: Text('Are you sure you want to delete ${_patient.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _databaseService.deletePatient(_patient.id);
        Navigator.of(context).pop(true); // Return true to indicate deletion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Patient deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting patient: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editPatient() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientRegistration(patient: _patient),
      ),
    ).then((updatedPatient) {
      if (updatedPatient != null && updatedPatient is Patient) {
        setState(() {
          _patient = updatedPatient;
        });
      }
    });
  }

  void _sendSmsReminder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SmsReminderScreen(patient: _patient),
      ),
    );
  }

  void _createPrescription() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrescriptionFormScreen(patient: _patient),
      ),
    );
  }

  void _viewPrescriptions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrescriptionsListScreen(patient: _patient),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, {IconData? icon}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content.isEmpty ? 'Not provided' : content,
              style: TextStyle(
                fontSize: 14,
                color: content.isEmpty ? Colors.grey : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _patient.synced ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _patient.synced ? Icons.cloud_done : Icons.cloud_off,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            _patient.synced ? 'Synced' : 'Pending Sync',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_patient.fullName),
        actions: [
          IconButton(
            onPressed: _editPatient,
            icon: const Icon(Icons.edit),
            tooltip: AppLocalizations.of(context)!.edit,
          ),
          IconButton(
            onPressed: () => _sendSmsReminder(),
            icon: const Icon(Icons.message),
            tooltip: AppLocalizations.of(context)!.sendSms,
          ),
          IconButton(
            onPressed: _createPrescription,
            icon: const Icon(Icons.medication),
            tooltip: 'Create Prescription',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editPatient();
                  break;
                case 'prescription':
                  _createPrescription();
                  break;
                case 'view_prescriptions':
                  _viewPrescriptions();
                  break;
                case 'sms':
                  _sendSmsReminder();
                  break;
                case 'delete':
                  _deletePatient();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.edit),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'prescription',
                child: Row(
                  children: [
                    const Icon(Icons.medication),
                    const SizedBox(width: 8),
                    const Text('Create Prescription'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'view_prescriptions',
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long),
                    const SizedBox(width: 8),
                    const Text('View Prescriptions'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'sms',
                child: Row(
                  children: [
                    const Icon(Icons.message),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.sendSms),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.delete),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Avatar and Basic Info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      _patient.firstName.isNotEmpty 
                          ? _patient.firstName[0].toUpperCase() 
                          : 'P',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _patient.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSyncStatusBadge(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Patient Information
            _buildInfoCard(
              AppLocalizations.of(context)!.personalInformation,
              '',
              icon: Icons.person,
            ),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    AppLocalizations.of(context)!.firstName,
                    _patient.firstName,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoCard(
                    AppLocalizations.of(context)!.lastName,
                    _patient.lastName,
                  ),
                ),
              ],
            ),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    AppLocalizations.of(context)!.age,
                    _patient.age.toString(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoCard(
                    AppLocalizations.of(context)!.phoneNumber,
                    _patient.phoneNumber,
                  ),
                ),
              ],
            ),
            
            _buildInfoCard(
              AppLocalizations.of(context)!.address,
              _patient.address,
              icon: Icons.location_on,
            ),
            
            _buildInfoCard(
              AppLocalizations.of(context)!.emergencyContact,
              _patient.emergencyContact,
              icon: Icons.emergency,
            ),
            
            const SizedBox(height: 16),
            
            // Medical Information
            _buildInfoCard(
              AppLocalizations.of(context)!.medicalInformation,
              '',
              icon: Icons.medical_information,
            ),
            
            _buildInfoCard(
              AppLocalizations.of(context)!.medicalHistory,
              _patient.medicalHistory,
            ),
            
            _buildInfoCard(
              AppLocalizations.of(context)!.allergies,
              _patient.allergies,
            ),
            
            const SizedBox(height: 16),
            
            // Timestamps
            _buildInfoCard(
              'System Information',
              '',
              icon: Icons.info,
            ),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Created At',
                    _formatDateTime(_patient.createdAt),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoCard(
                    'Updated At',
                    _formatDateTime(_patient.updatedAt),
                  ),
                ),
              ],
            ),
            
            _buildInfoCard(
              'Patient ID',
              _patient.id,
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _editPatient,
        tooltip: AppLocalizations.of(context)!.edit,
        child: const Icon(Icons.edit),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
