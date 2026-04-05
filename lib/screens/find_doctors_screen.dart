/*
 * Dr. Saathi - Find Doctors Screen
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * Licensed under the MIT License.
 */

import 'package:flutter/material.dart';
import 'package:dr_saathi/screens/bank_payment_screen.dart';

class FindDoctorsScreen extends StatefulWidget {
  final String? recommendedSpecialty;

  const FindDoctorsScreen({super.key, this.recommendedSpecialty});

  @override
  State<FindDoctorsScreen> createState() => _FindDoctorsScreenState();
}

class _FindDoctorsScreenState extends State<FindDoctorsScreen> {
  late String _selectedSpecialty;
  String _selectedConsultationType = 'In-Person';

  static const Map<String, String> _specialistToSpecialty = {
    'Cardiologist': 'Cardiology',
    'Pulmonologist': 'Pulmonology',
    'Neurologist': 'Neurology',
    'Rheumatologist': 'Rheumatology',
    'Endocrinologist': 'Endocrinology',
    'Psychiatrist': 'Psychiatry',
    'Dermatologist': 'Dermatology',
    'Pediatrician': 'Pediatrics',
    'Orthopedic': 'Orthopedics',
    'Gynecologist': 'Gynecology',
    'Ophthalmologist': 'Ophthalmology',
  };
  
  final List<String> _specialties = [
    'All',
    'General Medicine',
    'Cardiology',
    'Dermatology',
    'Pediatrics',
    'Orthopedics',
    'Neurology',
    'Gynecology',
    'Ophthalmology',
    'ENT',
    'Dentistry',
    'Pulmonology',
    'Psychiatry',
    'Rheumatology',
    'Endocrinology',
  ];

  @override
  void initState() {
    super.initState();
    final mapped = widget.recommendedSpecialty != null
        ? _specialistToSpecialty[widget.recommendedSpecialty] ?? 'All'
        : 'All';
    _selectedSpecialty = _specialties.contains(mapped) ? mapped : 'All';
  }
  
  final List<String> _consultationTypes = [
    'In-Person',
    'Video Call',
    'Phone Call',
    'Chat',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Doctors'),
        backgroundColor: Colors.lightBlue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Find & Consult Doctors',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Book appointments and pay for consultations with qualified healthcare professionals',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),

            // Recommendation banner from symptom analysis
            if (widget.recommendedSpecialty != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.recommend, color: Colors.teal.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Based on your symptoms, we recommend seeing a ${widget.recommendedSpecialty}. Showing matching doctors below.',
                        style: TextStyle(
                          color: Colors.teal.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
            
            // Filters
            _buildFiltersSection(),
            
            const SizedBox(height: 24),
            
            // Available Doctors
            _buildDoctorsSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFiltersSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filters',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Specialty Filter
            Text(
              'Specialty',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSpecialty,
                  isExpanded: true,
                  items: _specialties.map((specialty) {
                    return DropdownMenuItem(
                      value: specialty,
                      child: Text(specialty),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSpecialty = value!;
                    });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Consultation Type Filter
            Text(
              'Consultation Type',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedConsultationType,
                  isExpanded: true,
                  items: _consultationTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Icon(
                            _getConsultationIcon(type),
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(type),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedConsultationType = value!;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDoctorsSection() {
    final filteredDoctors = _getFilteredDoctors();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available Doctors',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${filteredDoctors.length} doctors',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        ...filteredDoctors.map((doctor) => _buildDoctorCard(doctor)),
      ],
    );
  }
  
  Widget _buildDoctorCard(Doctor doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.lightBlue[100],
                    child: Text(
                      doctor.name.split(' ').map((n) => n[0]).take(2).join(),
                      style: TextStyle(
                        color: Colors.lightBlue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor.specialty,
                          style: TextStyle(
                            color: Colors.lightBlue[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${doctor.rating} (${doctor.reviews} reviews)',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: doctor.isAvailable ? Colors.green[100] : Colors.red[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          doctor.isAvailable ? 'Available' : 'Busy',
                          style: TextStyle(
                            color: doctor.isAvailable ? Colors.green[700] : Colors.red[700],
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'NPR ${doctor.consultationFee.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.lightBlue[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Doctor Details
              Text(
                doctor.qualifications,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    doctor.hospital,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showDoctorDetails(doctor);
                      },
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: const Text('View Profile'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.lightBlue[600],
                        side: BorderSide(color: Colors.lightBlue[600]!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: doctor.isAvailable ? () {
                        _bookConsultation(doctor);
                      } : null,
                      icon: const Icon(Icons.payment, size: 16),
                      label: const Text('Book & Pay'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getConsultationIcon(String type) {
    switch (type) {
      case 'In-Person':
        return Icons.local_hospital;
      case 'Video Call':
        return Icons.video_call;
      case 'Phone Call':
        return Icons.phone;
      case 'Chat':
        return Icons.chat;
      default:
        return Icons.medical_services;
    }
  }
  
  List<Doctor> _getFilteredDoctors() {
    List<Doctor> doctors = _getAllDoctors();
    
    if (_selectedSpecialty != 'All') {
      doctors = doctors.where((doctor) => doctor.specialty == _selectedSpecialty).toList();
    }
    
    return doctors;
  }
  
  List<Doctor> _getAllDoctors() {
    return [
      Doctor(
        id: 'DR001',
        name: 'Dr. Ramesh Sharma',
        specialty: 'General Medicine',
        qualifications: 'MBBS, MD - General Medicine',
        hospital: 'Kathmandu Medical College',
        consultationFee: 500.0,
        rating: 4.8,
        reviews: 156,
        isAvailable: true,
        experience: '15 years',
        nextAvailable: 'Today 2:00 PM',
      ),
      Doctor(
        id: 'DR002',
        name: 'Dr. Sita Patel',
        specialty: 'Cardiology',
        qualifications: 'MBBS, MD - Cardiology, DM - Interventional Cardiology',
        hospital: 'Tribhuvan University Teaching Hospital',
        consultationFee: 1200.0,
        rating: 4.9,
        reviews: 234,
        isAvailable: true,
        experience: '20 years',
        nextAvailable: 'Today 4:30 PM',
      ),
      Doctor(
        id: 'DR003',
        name: 'Dr. Amit Thapa',
        specialty: 'Pediatrics',
        qualifications: 'MBBS, MD - Pediatrics',
        hospital: 'Kanti Children Hospital',
        consultationFee: 600.0,
        rating: 4.7,
        reviews: 89,
        isAvailable: false,
        experience: '12 years',
        nextAvailable: 'Tomorrow 10:00 AM',
      ),
      Doctor(
        id: 'DR004',
        name: 'Dr. Priya Shrestha',
        specialty: 'Dermatology',
        qualifications: 'MBBS, MD - Dermatology',
        hospital: 'Nepal Medical College',
        consultationFee: 800.0,
        rating: 4.6,
        reviews: 67,
        isAvailable: true,
        experience: '10 years',
        nextAvailable: 'Today 6:00 PM',
      ),
      Doctor(
        id: 'DR005',
        name: 'Dr. Bishal Maharjan',
        specialty: 'Orthopedics',
        qualifications: 'MBBS, MS - Orthopedics',
        hospital: 'Teaching Hospital',
        consultationFee: 1000.0,
        rating: 4.8,
        reviews: 145,
        isAvailable: true,
        experience: '18 years',
        nextAvailable: 'Today 3:15 PM',
      ),
      Doctor(
        id: 'DR006',
        name: 'Dr. Sunita Gurung',
        specialty: 'Neurology',
        qualifications: 'MBBS, MD - Neurology, DM - Neurology',
        hospital: 'Bir Hospital',
        consultationFee: 1500.0,
        rating: 4.9,
        reviews: 112,
        isAvailable: true,
        experience: '22 years',
        nextAvailable: 'Today 5:00 PM',
      ),
      Doctor(
        id: 'DR007',
        name: 'Dr. Nabin Acharya',
        specialty: 'Pulmonology',
        qualifications: 'MBBS, MD - Pulmonology',
        hospital: 'Chest Disease Hospital, Kathmandu',
        consultationFee: 900.0,
        rating: 4.7,
        reviews: 78,
        isAvailable: true,
        experience: '14 years',
        nextAvailable: 'Tomorrow 9:00 AM',
      ),
      Doctor(
        id: 'DR008',
        name: 'Dr. Meena Pradhan',
        specialty: 'Psychiatry',
        qualifications: 'MBBS, MD - Psychiatry',
        hospital: 'Mental Hospital, Lagankhel',
        consultationFee: 700.0,
        rating: 4.8,
        reviews: 95,
        isAvailable: false,
        experience: '16 years',
        nextAvailable: 'Tomorrow 11:00 AM',
      ),
      Doctor(
        id: 'DR009',
        name: 'Dr. Roshan KC',
        specialty: 'Rheumatology',
        qualifications: 'MBBS, MD - Internal Medicine, DM - Rheumatology',
        hospital: 'Patan Hospital',
        consultationFee: 1100.0,
        rating: 4.6,
        reviews: 54,
        isAvailable: true,
        experience: '11 years',
        nextAvailable: 'Today 3:00 PM',
      ),
      Doctor(
        id: 'DR010',
        name: 'Dr. Anjali Rai',
        specialty: 'Endocrinology',
        qualifications: 'MBBS, MD - Internal Medicine, DM - Endocrinology',
        hospital: 'HAMS Hospital',
        consultationFee: 1300.0,
        rating: 4.9,
        reviews: 88,
        isAvailable: true,
        experience: '17 years',
        nextAvailable: 'Today 4:00 PM',
      ),
    ];
  }
  
  void _showDoctorDetails(Doctor doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DoctorDetailsSheet(doctor: doctor),
    );
  }
  
  void _bookConsultation(Doctor doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BankPaymentScreen(
          doctorId: doctor.id,
          appointmentId: 'APT-${DateTime.now().millisecondsSinceEpoch}',
          amount: doctor.consultationFee,
          serviceType: 'consultation',
          serviceName: '${doctor.specialty} Consultation with ${doctor.name}',
          customerInfo: {
            'name': 'John Doe',
            'email': 'john.doe@example.com',
            'phone': '+977-9841234567',
            'patientId': 'PAT001',
          },
        ),
      ),
    );
  }
}

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String qualifications;
  final String hospital;
  final double consultationFee;
  final double rating;
  final int reviews;
  final bool isAvailable;
  final String experience;
  final String nextAvailable;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.qualifications,
    required this.hospital,
    required this.consultationFee,
    required this.rating,
    required this.reviews,
    required this.isAvailable,
    required this.experience,
    required this.nextAvailable,
  });
}

class DoctorDetailsSheet extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailsSheet({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Doctor Header
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.lightBlue[100],
                child: Text(
                  doctor.name.split(' ').map((n) => n[0]).take(2).join(),
                  style: TextStyle(
                    color: Colors.lightBlue[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialty,
                      style: TextStyle(
                        color: Colors.lightBlue[600],
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${doctor.rating} (${doctor.reviews} reviews)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Details
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection('Qualifications', doctor.qualifications),
                  _buildDetailSection('Hospital', doctor.hospital),
                  _buildDetailSection('Experience', doctor.experience),
                  _buildDetailSection('Next Available', doctor.nextAvailable),
                  _buildDetailSection('Consultation Fee', 'NPR ${doctor.consultationFee.toStringAsFixed(0)}'),
                ],
              ),
            ),
          ),
          
          // Book Button
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: doctor.isAvailable ? () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BankPaymentScreen(
                      doctorId: doctor.id,
                      appointmentId: 'APT-${DateTime.now().millisecondsSinceEpoch}',
                      amount: doctor.consultationFee,
                      serviceType: 'consultation',
                      serviceName: '${doctor.specialty} Consultation with ${doctor.name}',
                      customerInfo: {
                        'name': 'John Doe',
                        'email': 'john.doe@example.com',
                        'phone': '+977-9841234567',
                        'patientId': 'PAT001',
                      },
                    ),
                  ),
                );
              } : null,
              icon: const Icon(Icons.payment, size: 18),
              label: Text(
                doctor.isAvailable 
                    ? 'Book Consultation - NPR ${doctor.consultationFee.toStringAsFixed(0)}'
                    : 'Currently Unavailable',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
