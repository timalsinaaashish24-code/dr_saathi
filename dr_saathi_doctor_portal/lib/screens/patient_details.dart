import 'package:flutter/material.dart';
import '../models/patient.dart';

class PatientDetails extends StatelessWidget {
  final Patient patient;

  const PatientDetails({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(patient.fullName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Age', '${patient.age} years'),
                    _buildInfoRow('Phone', patient.phoneNumber),
                    if (patient.email.isNotEmpty)
                      _buildInfoRow('Email', patient.email),
                    if (patient.address.isNotEmpty)
                      _buildInfoRow('Address', patient.address),
                    if (patient.emergencyContact.isNotEmpty)
                      _buildInfoRow('Emergency Contact', patient.emergencyContact),
                    if (patient.medicalHistory.isNotEmpty)
                      _buildInfoRow('Medical History', patient.medicalHistory),
                    if (patient.allergies.isNotEmpty)
                      _buildInfoRow('Allergies', patient.allergies),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
