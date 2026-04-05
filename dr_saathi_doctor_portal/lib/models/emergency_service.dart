/*
 * Dr. Saathi - Offline-First Patient Registration System
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

class EmergencyService {
  final String id;
  final String name;
  final String type;
  final String phoneNumber;
  final String? alternatePhone;
  final String? whatsappNumber;
  final String? email;
  final String address;
  final String city;
  final String province;
  final double? latitude;
  final double? longitude;
  final List<String> services;
  final bool isAvailable24x7;
  final String? operatingHours;
  final double? rating;
  final String? website;
  final String? description;
  final bool isGovernment;
  final bool isPrivate;
  final List<String> vehicleTypes;
  final String? emergencyCode;

  EmergencyService({
    required this.id,
    required this.name,
    required this.type,
    required this.phoneNumber,
    this.alternatePhone,
    this.whatsappNumber,
    this.email,
    required this.address,
    required this.city,
    required this.province,
    this.latitude,
    this.longitude,
    required this.services,
    this.isAvailable24x7 = true,
    this.operatingHours,
    this.rating,
    this.website,
    this.description,
    this.isGovernment = false,
    this.isPrivate = false,
    required this.vehicleTypes,
    this.emergencyCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'phoneNumber': phoneNumber,
      'alternatePhone': alternatePhone,
      'whatsappNumber': whatsappNumber,
      'email': email,
      'address': address,
      'city': city,
      'province': province,
      'latitude': latitude,
      'longitude': longitude,
      'services': services,
      'isAvailable24x7': isAvailable24x7,
      'operatingHours': operatingHours,
      'rating': rating,
      'website': website,
      'description': description,
      'isGovernment': isGovernment,
      'isPrivate': isPrivate,
      'vehicleTypes': vehicleTypes,
      'emergencyCode': emergencyCode,
    };
  }

  factory EmergencyService.fromJson(Map<String, dynamic> json) {
    return EmergencyService(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      phoneNumber: json['phoneNumber'],
      alternatePhone: json['alternatePhone'],
      whatsappNumber: json['whatsappNumber'],
      email: json['email'],
      address: json['address'],
      city: json['city'],
      province: json['province'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      services: List<String>.from(json['services']),
      isAvailable24x7: json['isAvailable24x7'] ?? true,
      operatingHours: json['operatingHours'],
      rating: json['rating'],
      website: json['website'],
      description: json['description'],
      isGovernment: json['isGovernment'] ?? false,
      isPrivate: json['isPrivate'] ?? false,
      vehicleTypes: List<String>.from(json['vehicleTypes']),
      emergencyCode: json['emergencyCode'],
    );
  }
}

class EmergencyContact {
  final String name;
  final String phoneNumber;
  final String type;
  final String? description;

  EmergencyContact({
    required this.name,
    required this.phoneNumber,
    required this.type,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'type': type,
      'description': description,
    };
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      type: json['type'],
      description: json['description'],
    );
  }
}
