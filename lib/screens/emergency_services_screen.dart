/*
 * Dr. Saathi - Emergency Services Screen
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * 
 * This software is licensed under the MIT License.
 * See the LICENSE file in the root directory for full license text.
 * 
 * HEALTHCARE DISCLAIMER:
 * This software is designed for healthcare management purposes.
 * Users are responsible for ensuring compliance with all applicable
 * healthcare regulations. This software should not be used as a
 * substitute for professional medical advice, diagnosis, or treatment.
 */

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/emergency_service.dart';
import '../services/location_service.dart';
import '../services/content_localization_service.dart' as ContentLocalization;
import '../generated/l10n/app_localizations.dart';

class EmergencyServicesScreen extends StatefulWidget {
  const EmergencyServicesScreen({super.key});

  @override
  State<EmergencyServicesScreen> createState() => _EmergencyServicesScreenState();
}

class _EmergencyServicesScreenState extends State<EmergencyServicesScreen> {
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  String _selectedFilter = 'All';

  // Get localized emergency services based on current language
  List<EmergencyService> _getEmergencyServices() {
    return ContentLocalization.ContentLocalizationService.getLocalizedEmergencyServices(context);
  }

  // Legacy static list (keeping for reference but not used)
  final List<EmergencyService> _nepalEmergencyServices = [
    // National Emergency Numbers
    EmergencyService(
      id: 'gov_100',
      name: 'Nepal Police Emergency',
      type: 'Police',
      phoneNumber: '100',
      address: 'Nationwide',
      city: 'All Cities',
      province: 'All Provinces',
      services: ['Police Emergency', 'Crime Reporting', 'Emergency Response'],
      isAvailable24x7: true,
      isGovernment: true,
      vehicleTypes: ['Police Vehicle'],
      emergencyCode: '100',
      description: 'Nepal Police emergency hotline for all types of emergencies',
    ),
    EmergencyService(
      id: 'gov_102',
      name: 'Nepal Medical Emergency',
      type: 'Medical Emergency',
      phoneNumber: '102',
      address: 'Nationwide',
      city: 'All Cities',
      province: 'All Provinces',
      services: ['Medical Emergency', 'Ambulance Service', 'Emergency Medical Care'],
      isAvailable24x7: true,
      isGovernment: true,
      vehicleTypes: ['Ambulance'],
      emergencyCode: '102',
      description: 'National medical emergency and ambulance service',
    ),
    EmergencyService(
      id: 'gov_103',
      name: 'Nepal Fire Service',
      type: 'Fire Service',
      phoneNumber: '103',
      address: 'Nationwide',
      city: 'All Cities',
      province: 'All Provinces',
      services: ['Fire Emergency', 'Rescue Operations', 'Disaster Response'],
      isAvailable24x7: true,
      isGovernment: true,
      vehicleTypes: ['Fire Truck', 'Rescue Vehicle'],
      emergencyCode: '103',
      description: 'Nepal Fire Service for fire emergencies and rescue operations',
    ),

    // Kathmandu Valley Ambulance Services
    EmergencyService(
      id: 'ktm_001',
      name: 'Bir Hospital Ambulance',
      type: 'Ambulance',
      phoneNumber: '+977-1-422-1119',
      alternatePhone: '+977-1-422-3807',
      address: 'Mahaboudha, Kathmandu',
      city: 'Kathmandu',
      province: 'Bagmati',
      latitude: 27.7019,
      longitude: 85.3137,
      services: ['Basic Life Support', 'Advanced Life Support', 'Emergency Transport'],
      isAvailable24x7: true,
      isGovernment: true,
      vehicleTypes: ['Basic Ambulance', 'Advanced Ambulance'],
      description: 'Government hospital ambulance service',
      rating: 4.2,
    ),
    EmergencyService(
      id: 'ktm_002',
      name: 'TU Teaching Hospital Ambulance',
      type: 'Ambulance',
      phoneNumber: '+977-1-441-2505',
      alternatePhone: '+977-1-441-4142',
      address: 'Maharajgunj, Kathmandu',
      city: 'Kathmandu',
      province: 'Bagmati',
      latitude: 27.7394,
      longitude: 85.3336,
      services: ['Advanced Life Support', 'Trauma Care', 'ICU Transport'],
      isAvailable24x7: true,
      isGovernment: true,
      vehicleTypes: ['ICU Ambulance', 'Advanced Ambulance'],
      description: 'Teaching hospital specialized ambulance service',
      rating: 4.5,
    ),
    EmergencyService(
      id: 'ktm_003',
      name: 'Nepal Red Cross Ambulance',
      type: 'Ambulance',
      phoneNumber: '+977-1-427-0650',
      alternatePhone: '+977-1-427-0867',
      address: 'Kalimati, Kathmandu',
      city: 'Kathmandu',
      province: 'Bagmati',
      latitude: 27.6966,
      longitude: 85.2938,
      services: ['Basic Life Support', 'Emergency Transport', 'Disaster Response'],
      isAvailable24x7: true,
      isGovernment: false,
      isPrivate: false,
      vehicleTypes: ['Basic Ambulance', 'Emergency Van'],
      description: 'Red Cross ambulance service',
      rating: 4.0,
    ),
    EmergencyService(
      id: 'ktm_004',
      name: 'Norvic Hospital Ambulance',
      type: 'Ambulance',
      phoneNumber: '+977-1-425-8554',
      alternatePhone: '+977-1-425-8555',
      address: 'Thapathali, Kathmandu',
      city: 'Kathmandu',
      province: 'Bagmati',
      latitude: 27.6942,
      longitude: 85.3222,
      services: ['Advanced Life Support', 'ICU Transport', 'Cardiac Emergency'],
      isAvailable24x7: true,
      isPrivate: true,
      vehicleTypes: ['ICU Ambulance', 'Cardiac Ambulance'],
      description: 'Private hospital specialized ambulance',
      rating: 4.6,
    ),
    EmergencyService(
      id: 'ktm_005',
      name: 'Grande Hospital Ambulance',
      type: 'Ambulance',
      phoneNumber: '+977-1-510-0190',
      address: 'Dhapasi, Kathmandu',
      city: 'Kathmandu',
      province: 'Bagmati',
      latitude: 27.7500,
      longitude: 85.3500,
      services: ['Advanced Life Support', 'Emergency Surgery Transport'],
      isAvailable24x7: true,
      isPrivate: true,
      vehicleTypes: ['Advanced Ambulance'],
      description: 'Private hospital ambulance service',
      rating: 4.4,
    ),

    // Lalitpur/Patan Ambulance Services
    EmergencyService(
      id: 'ltp_001',
      name: 'Patan Hospital Ambulance',
      type: 'Ambulance',
      phoneNumber: '+977-1-552-2266',
      alternatePhone: '+977-1-552-1048',
      address: 'Lagankhel, Lalitpur',
      city: 'Lalitpur',
      province: 'Bagmati',
      latitude: 27.6662,
      longitude: 85.3149,
      services: ['Advanced Life Support', 'Trauma Care', 'Pediatric Emergency'],
      isAvailable24x7: true,
      isGovernment: true,
      vehicleTypes: ['Advanced Ambulance', 'Pediatric Ambulance'],
      description: 'Patan Academy of Health Sciences ambulance',
      rating: 4.3,
    ),
    EmergencyService(
      id: 'ltp_002',
      name: 'Alka Hospital Ambulance',
      type: 'Ambulance',
      phoneNumber: '+977-1-553-3266',
      address: 'Jawalakhel, Lalitpur',
      city: 'Lalitpur',
      province: 'Bagmati',
      latitude: 27.6736,
      longitude: 85.3088,
      services: ['Basic Life Support', 'Emergency Transport'],
      isAvailable24x7: true,
      isPrivate: true,
      vehicleTypes: ['Basic Ambulance'],
      description: 'Private hospital ambulance service',
      rating: 4.1,
    ),

    // Bhaktapur Ambulance Services
    EmergencyService(
      id: 'bkt_001',
      name: 'Bhaktapur Hospital Ambulance',
      type: 'Ambulance',
      phoneNumber: '+977-1-661-0798',
      address: 'Bhaktapur Municipality',
      city: 'Bhaktapur',
      province: 'Bagmati',
      latitude: 27.6710,
      longitude: 85.4298,
      services: ['Basic Life Support', 'Emergency Transport'],
      isAvailable24x7: true,
      isGovernment: true,
      vehicleTypes: ['Basic Ambulance'],
      description: 'District hospital ambulance service',
      rating: 3.9,
    ),

    // Pokhara Ambulance Services
    EmergencyService(
      id: 'pkr_001',
      name: 'Pokhara Academy Ambulance',
      type: 'Ambulance',
      phoneNumber: '+977-61-504040',
      alternatePhone: '+977-61-504041',
      address: 'Dhungepatan, Pokhara',
      city: 'Pokhara',
      province: 'Gandaki',
      latitude: 28.2096,
      longitude: 83.9856,
      services: ['Advanced Life Support', 'Trauma Care'],
      isAvailable24x7: true,
      isGovernment: true,
      vehicleTypes: ['Advanced Ambulance'],
      description: 'Pokhara Academy of Health Sciences ambulance',
      rating: 4.2,
    ),
    EmergencyService(
      id: 'pkr_002',
      name: 'Manipal Hospital Pokhara',
      type: 'Ambulance',
      phoneNumber: '+977-61-526416',
      address: 'Phulbari, Pokhara',
      city: 'Pokhara',
      province: 'Gandaki',
      latitude: 28.2380,
      longitude: 83.9956,
      services: ['Advanced Life Support', 'ICU Transport'],
      isAvailable24x7: true,
      isPrivate: true,
      vehicleTypes: ['ICU Ambulance'],
      description: 'Private hospital ambulance with ICU facilities',
      rating: 4.5,
    ),

    // Chitwan Ambulance Services
    EmergencyService(
      id: 'ctw_001',
      name: 'Bharatpur Hospital Ambulance',
      type: 'Ambulance',
      phoneNumber: '+977-56-521333',
      address: 'Bharatpur, Chitwan',
      city: 'Bharatpur',
      province: 'Bagmati',
      latitude: 27.6893,
      longitude: 84.4348,
      services: ['Basic Life Support', 'Emergency Transport'],
      isAvailable24x7: true,
      isGovernment: true,
      vehicleTypes: ['Basic Ambulance'],
      description: 'Regional hospital ambulance service',
      rating: 4.0,
    ),

    // Biratnagar Ambulance Services
    EmergencyService(
      id: 'btn_001',
      name: 'Biratnagar Hospital Ambulance',
      type: 'Ambulance',
      phoneNumber: '+977-21-525416',
      address: 'Biratnagar, Morang',
      city: 'Biratnagar',
      province: 'Province 1',
      latitude: 26.4525,
      longitude: 87.2718,
      services: ['Basic Life Support', 'Emergency Transport'],
      isAvailable24x7: true,
      isGovernment: true,
      vehicleTypes: ['Basic Ambulance'],
      description: 'Eastern region hospital ambulance',
      rating: 3.8,
    ),

    // Nepalgunj Ambulance Services
    EmergencyService(
      id: 'npg_001',
      name: 'Nepalgunj Medical College',
      type: 'Ambulance',
      phoneNumber: '+977-81-525333',
      address: 'Kohalpur, Nepalgunj',
      city: 'Nepalgunj',
      province: 'Lumbini',
      latitude: 28.0504,
      longitude: 81.6172,
      services: ['Advanced Life Support', 'Trauma Care'],
      isAvailable24x7: true,
      isPrivate: true,
      vehicleTypes: ['Advanced Ambulance'],
      description: 'Medical college ambulance service',
      rating: 4.1,
    ),

    // Dharan Ambulance Services
    EmergencyService(
      id: 'drn_001',
      name: 'BP Koirala Institute Ambulance',
      type: 'Ambulance',
      phoneNumber: '+977-25-525555',
      address: 'Dharan, Sunsari',
      city: 'Dharan',
      province: 'Province 1',
      latitude: 26.8147,
      longitude: 87.2795,
      services: ['Advanced Life Support', 'Medical Emergency'],
      isAvailable24x7: true,
      isGovernment: true,
      vehicleTypes: ['Advanced Ambulance'],
      description: 'Medical institute ambulance service',
      rating: 4.3,
    ),

    // Private Ambulance Services
    EmergencyService(
      id: 'pvt_001',
      name: 'Life Care Ambulance',
      type: 'Ambulance',
      phoneNumber: '+977-98-01234567',
      whatsappNumber: '+977-98-01234567',
      address: 'Multiple Locations',
      city: 'Kathmandu Valley',
      province: 'Bagmati',
      services: ['Basic Life Support', 'Advanced Life Support', 'ICU Transport'],
      isAvailable24x7: true,
      isPrivate: true,
      vehicleTypes: ['Basic Ambulance', 'Advanced Ambulance', 'ICU Ambulance'],
      description: 'Private ambulance service covering multiple areas',
      rating: 4.4,
    ),
    EmergencyService(
      id: 'pvt_002',
      name: 'Emergency Plus Ambulance',
      type: 'Ambulance',
      phoneNumber: '+977-98-12345678',
      whatsappNumber: '+977-98-12345678',
      address: 'Nationwide Service',
      city: 'Multiple Cities',
      province: 'All Provinces',
      services: ['Emergency Transport', 'Medical Escort', 'Inter-city Transport'],
      isAvailable24x7: true,
      isPrivate: true,
      vehicleTypes: ['Basic Ambulance', 'Advanced Ambulance'],
      description: 'Nationwide private ambulance network',
      rating: 4.2,
    ),
  ];

  // Emergency Contacts
  final List<EmergencyContact> _emergencyContacts = [
    EmergencyContact(
      name: 'Nepal Police',
      phoneNumber: '100',
      type: 'Police Emergency',
      description: 'For crime, accidents, and general emergencies',
    ),
    EmergencyContact(
      name: 'Medical Emergency',
      phoneNumber: '102',
      type: 'Medical Emergency',
      description: 'For medical emergencies and ambulance',
    ),
    EmergencyContact(
      name: 'Fire Service',
      phoneNumber: '103',
      type: 'Fire Emergency',
      description: 'For fire emergencies and rescue operations',
    ),
    EmergencyContact(
      name: 'Tourist Helpline',
      phoneNumber: '1144',
      type: 'Tourist Emergency',
      description: 'For tourist-related emergencies',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    // Set the default filter to 'All' - this will be updated to the localized version in the build method
    _selectedFilter = 'All';
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      Position position = await _locationService.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      print('Error getting location: $e');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.couldNotLaunchPhone)),
      );
    }
  }

  Future<void> _sendWhatsApp(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: phoneNumber.replaceAll('+', '').replaceAll('-', ''),
      queryParameters: {'text': AppLocalizations.of(context)!.whatsappMessage},
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.couldNotLaunchWhatsApp)),
      );
    }
  }

  List<EmergencyService> _getFilteredServices() {
    final services = _getEmergencyServices();
    if (_selectedFilter == 'All' || _selectedFilter == AppLocalizations.of(context)!.filterAll) {
      return services;
    }
    return services
        .where((service) => service.type == _selectedFilter)
        .toList();
  }

  double? _calculateDistance(EmergencyService service) {
    if (_currentPosition == null || service.latitude == null || service.longitude == null) {
      return null;
    }
    return _locationService.calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      service.latitude!,
      service.longitude!,
    );
  }

  String _formatDistance(double? distance) {
    if (distance == null) return '';
    if (distance < 1000) {
      return '${distance.round()}${AppLocalizations.of(context)!.metersAway}';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}${AppLocalizations.of(context)!.kilometersAway}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.emergencyServicesTitle),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Column(
        children: [
          // Emergency Alert Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              border: Border(
                bottom: BorderSide(color: Colors.red[200]!),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red[600], size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.emergencyAlert,
                        style: TextStyle(
                          color: Colors.red[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _makePhoneCall('102'),
                        icon: const Icon(Icons.phone),
                        label: Text(AppLocalizations.of(context)!.call102),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _makePhoneCall('100'),
                        icon: const Icon(Icons.local_police),
                        label: Text(AppLocalizations.of(context)!.call100),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Tabs
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                AppLocalizations.of(context)!.filterAll,
                AppLocalizations.of(context)!.filterAmbulance,
                AppLocalizations.of(context)!.filterPolice,
                AppLocalizations.of(context)!.filterFireService,
                AppLocalizations.of(context)!.filterMedicalEmergency
              ].map((filter) {
                bool isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: Colors.red[100],
                    checkmarkColor: Colors.red[600],
                  ),
                );
              }).toList(),
            ),
          ),

          // Location Status
          if (_isLoadingLocation)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(AppLocalizations.of(context)!.gettingLocation),
                ],
              ),
            ),

          // Services List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _getFilteredServices().length,
              itemBuilder: (context, index) {
                final service = _getFilteredServices()[index];
                final distance = _calculateDistance(service);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: service.type == 'Ambulance' 
                                    ? Colors.red[100]
                                    : service.type == 'Police'
                                    ? Colors.blue[100]
                                    : service.type == 'Fire Service'
                                    ? Colors.orange[100]
                                    : Colors.green[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                service.type == 'Ambulance' 
                                    ? Icons.local_hospital
                                    : service.type == 'Police'
                                    ? Icons.local_police
                                    : service.type == 'Fire Service'
                                    ? Icons.local_fire_department
                                    : Icons.medical_services,
                                color: service.type == 'Ambulance' 
                                    ? Colors.red[600]
                                    : service.type == 'Police'
                                    ? Colors.blue[600]
                                    : service.type == 'Fire Service'
                                    ? Colors.orange[600]
                                    : Colors.green[600],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        service.type,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (service.isAvailable24x7) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green[100],
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            AppLocalizations.of(context)!.available247,
                                            style: TextStyle(
                                              color: Colors.green[800],
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (service.rating != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber[700],
                                      size: 14,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      service.rating!.toString(),
                                      style: TextStyle(
                                        color: Colors.amber[700],
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Location and Distance
                        Row(
                          children: [
                            Icon(Icons.location_on, 
                                 color: Colors.grey[600], size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${service.address}, ${service.city}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (distance != null)
                              Text(
                                _formatDistance(distance),
                                style: TextStyle(
                                  color: Colors.blue[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),

                        if (service.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            service.description!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),

                        // Services Offered
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: service.services.map((serviceItem) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Text(
                                serviceItem,
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 16),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _makePhoneCall(service.phoneNumber),
                                icon: const Icon(Icons.phone, size: 18),
                                label: Text(AppLocalizations.of(context)!.callButton),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[600],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                            if (service.whatsappNumber != null) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _sendWhatsApp(service.whatsappNumber!),
                                  icon: const Icon(Icons.chat, size: 18),
                                  label: Text(AppLocalizations.of(context)!.whatsappButton),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[700],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                            if (service.alternatePhone != null) ...[
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () => _makePhoneCall(service.alternatePhone!),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  minimumSize: Size(50, 36),
                                ),
                                child: Text(AppLocalizations.of(context)!.alternateButton, style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
