import 'package:flutter/material.dart';
import '../models/doctor.dart';

class AppointmentConfirmationScreen extends StatelessWidget {
  final Doctor doctor;
  final DateTime selectedDate;
  final String selectedTime;

  const AppointmentConfirmationScreen({
    super.key,
    required this.doctor,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Confirmation'),
        backgroundColor: Colors.lightBlue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Icon
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Confirmation Message
            Center(
              child: Text(
                'Appointment Confirmed!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Appointment Details Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appointment Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Doctor Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: doctor.profileImage.isNotEmpty
                              ? NetworkImage(doctor.profileImage)
                              : null,
                          child: doctor.profileImage.isEmpty
                              ? Text(
                                  doctor.name.split(' ').map((n) => n[0]).join('').toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dr. ${doctor.name}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                doctor.specialization,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const Divider(height: 32),
                    
                    // Date and Time
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Date',
                      value: '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.access_time,
                      label: 'Time',
                      value: selectedTime,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.location_on,
                      label: 'Location',
                      value: doctor.address,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.phone,
                      label: 'Contact',
                      value: doctor.phone,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Add to calendar functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to calendar')),
                      );
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Add to Calendar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Share appointment details
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Appointment details shared')),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate back to home
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back to Home'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Important Notes
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Important Notes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Please arrive 15 minutes before your appointment time\n'
                    '• Bring a valid ID and insurance card\n'
                    '• If you need to reschedule, please contact us 24 hours in advance\n'
                    '• You will receive an SMS reminder 1 hour before your appointment',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
