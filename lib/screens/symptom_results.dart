import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/symptom.dart';
import '../models/patient.dart';
import '../services/symptom_checker_service.dart';
import 'find_doctors_screen.dart';
import 'prescription_form.dart';
import 'sms_reminder_screen.dart';

class SymptomResultsScreen extends StatefulWidget {
  final SymptomCheck symptomCheck;
  final Patient? patient;

  const SymptomResultsScreen({
    super.key,
    required this.symptomCheck,
    this.patient,
  });

  @override
  State<SymptomResultsScreen> createState() => _SymptomResultsScreenState();
}

class _SymptomResultsScreenState extends State<SymptomResultsScreen> {
  final SymptomCheckerService _symptomService = SymptomCheckerService();

  @override
  Widget build(BuildContext context) {
    final result = widget.symptomCheck.result;
    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Symptom Results')),
        body: const Center(child: Text('No results available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom Analysis Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareResults,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Urgency Level Header
            _buildUrgencyHeader(result),
            
            // Main Recommendation
            _buildRecommendationCard(result),
            
            // Red Flags (if any)
            if (result.redFlags.isNotEmpty) _buildRedFlagsCard(result),
            
            // Possible Conditions
            _buildPossibleConditionsCard(result),
            
            // Self-Care Advice
            _buildSelfCareCard(result),
            
            // Specialist Recommendation
            if (result.specialistRecommendation != null)
              _buildSpecialistCard(result),
            
            // Selected Symptoms Summary
            _buildSymptomSummary(),
            
            // Action Buttons
            _buildActionButtons(result),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgencyHeader(SymptomCheckResult result) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    
    switch (result.urgencyLevel) {
      case 'emergency':
        backgroundColor = Colors.red;
        textColor = Colors.white;
        icon = Icons.emergency;
        break;
      case 'high':
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        icon = Icons.warning;
        break;
      case 'medium':
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        icon = Icons.info;
        break;
      default:
        backgroundColor = Colors.green;
        textColor = Colors.white;
        icon = Icons.check_circle;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 60, color: textColor),
          const SizedBox(height: 16),
          Text(
            _getUrgencyTitle(result.urgencyLevel),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getUrgencyDescription(result.urgencyLevel),
            style: TextStyle(
              fontSize: 16,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(SymptomCheckResult result) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Recommendation',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              result.recommendation,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (result.shouldSeeDoctor) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_hospital, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Medical consultation recommended',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRedFlagsCard(SymptomCheckResult result) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Warning Signs',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...result.redFlags.map((flag) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      flag,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPossibleConditionsCard(SymptomCheckResult result) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Possible Conditions',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...result.possibleConditions.map((condition) => 
              _buildConditionCard(condition)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionCard(PossibleCondition condition) {
    final probabilityPercentage = (condition.probability * 100).round();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    condition.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getProbabilityColor(condition.probability),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$probabilityPercentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              condition.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  condition.category,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (condition.treatmentAdvice != null) ...[
              const SizedBox(height: 8),
              Text(
                'Treatment: ${condition.treatmentAdvice}',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelfCareCard(SymptomCheckResult result) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.self_improvement, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Self-Care Advice',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...result.selfCareAdvice.map((advice) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      advice,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialistCard(SymptomCheckResult result) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_information, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Specialist Recommendation',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Consider consulting a ${result.specialistRecommendation}',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomSummary() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Selected Symptoms',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...widget.symptomCheck.selectedSymptoms.map((symptomId) {
              final symptom = _symptomService.symptoms.firstWhere(
                (s) => s.id == symptomId,
                orElse: () => Symptom(
                  id: symptomId,
                  name: 'Unknown',
                  description: '',
                  category: '',
                  bodyParts: [],
                  severity: 0,
                  associatedConditions: [],
                  keywords: [],
                ),
              );
              final severity = widget.symptomCheck.symptomSeverity[symptomId] ?? 0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(symptom.name),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getSeverityColor(severity),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$severity/10',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(SymptomCheckResult result) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Emergency button
          if (result.urgencyLevel == 'emergency')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _callEmergency,
                icon: const Icon(Icons.call),
                label: const Text('Call Emergency Services'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          
          if (result.urgencyLevel == 'emergency') const SizedBox(height: 16),
          
          // Find doctor button
          if (result.shouldSeeDoctor)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _findDoctor,
                icon: const Icon(Icons.local_hospital),
                label: const Text('Find a Doctor'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Additional actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _setReminder,
                  icon: const Icon(Icons.alarm),
                  label: const Text('Set Reminder'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _createPrescription,
                  icon: const Icon(Icons.medication),
                  label: const Text('Create Prescription'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getUrgencyTitle(String urgencyLevel) {
    switch (urgencyLevel) {
      case 'emergency':
        return 'Emergency';
      case 'high':
        return 'High Priority';
      case 'medium':
        return 'Medium Priority';
      default:
        return 'Low Priority';
    }
  }

  String _getUrgencyDescription(String urgencyLevel) {
    switch (urgencyLevel) {
      case 'emergency':
        return 'Seek immediate medical attention';
      case 'high':
        return 'See a doctor as soon as possible';
      case 'medium':
        return 'Consider seeing a doctor within a few days';
      default:
        return 'Monitor symptoms and seek care if needed';
    }
  }

  Color _getProbabilityColor(double probability) {
    if (probability >= 0.7) return Colors.red;
    if (probability >= 0.5) return Colors.orange;
    if (probability >= 0.3) return Colors.blue;
    return Colors.green;
  }

  Color _getSeverityColor(int severity) {
    if (severity <= 3) return Colors.green;
    if (severity <= 6) return Colors.orange;
    return Colors.red;
  }

  void _shareResults() {
    // Implementation for sharing results
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Results shared successfully')),
    );
  }

  void _callEmergency() async {
    const phoneNumber = 'tel:911'; // Emergency number
    if (await canLaunchUrl(Uri.parse(phoneNumber))) {
      await launchUrl(Uri.parse(phoneNumber));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to make emergency call')),
      );
    }
  }

  void _findDoctor() {
    final result = widget.symptomCheck.result;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FindDoctorsScreen(
          recommendedSpecialty: result?.specialistRecommendation,
        ),
      ),
    );
  }

  void _setReminder() {
    if (widget.patient != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SmsReminderScreen(patient: widget.patient!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient information required for reminders')),
      );
    }
  }

  void _createPrescription() {
    if (widget.patient != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrescriptionFormScreen(patient: widget.patient!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient information required for prescriptions')),
      );
    }
  }
}
