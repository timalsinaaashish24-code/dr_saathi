/*
 * Dr. Saathi - Emergency Services
 * 
 * This service provides access to emergency service information within Nepal.
 * It retrieves a fixed set of known ambulance services and can be extended
 * to connect with real-time services or APIs providing emergency assistance.
 */

import 'dart:async';
import 'package:dr_saathi/models/emergency_service.dart';

class EmergencyServiceRepository {
  final List<EmergencyService> _services = [
    EmergencyService(
      id: '1',
      name: 'Nepal Ambulance Service',
      type: 'Ambulance',
      phoneNumber: '+977-1-410-1234',
      address: 'Kathmandu, Nepal',
      city: 'Kathmandu',
      province: 'Bagmati',
      latitude: 27.7000,
      longitude: 85.3333,
      services: ['Basic life support', 'Advanced life support'],
      isAvailable24x7: true,
      rating: 4.5,
      vehicleTypes: ['Van', '4x4'],
      isGovernment: false,
      isPrivate: true,
    ),
    EmergencyService(
      id: '2',
      name: 'Red Cross Ambulance',
      type: 'Ambulance',
      phoneNumber: '+977-1-425-5555',
      address: 'Patan, Lalitpur',
      city: 'Lalitpur',
      province: 'Bagmati',
      latitude: 27.6662,
      longitude: 85.3149,
      services: ['Basic life support'],
      isAvailable24x7: true,
      rating: 4.0,
      vehicleTypes: ['Van'],
      isGovernment: true,
      isPrivate: false,
    ),
    EmergencyService(
      id: '3',
      name: 'MediCare Emergency',
      type: 'Ambulance',
      phoneNumber: '+977-9802-123456',
      address: 'Pokhara, Nepal',
      city: 'Pokhara',
      province: 'Gandaki',
      latitude: 28.2096,
      longitude: 83.9856,
      services: ['Basic life support', 'Advanced trauma care'],
      isAvailable24x7: true,
      rating: 4.7,
      vehicleTypes: ['4x4'],
      isGovernment: false,
      isPrivate: true,
    ),
  ];

  Future<List<EmergencyService>> getServices() async {
    // Simulating network delay
    await Future.delayed(Duration(seconds: 2));
    return _services;
  }
}
