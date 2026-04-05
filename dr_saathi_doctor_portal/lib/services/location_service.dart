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

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentLocation;
  String? _currentAddress;

  /// Get current location position
  Position? get currentLocation => _currentLocation;

  /// Get current address string
  String? get currentAddress => _currentAddress;

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request location permissions
  Future<LocationPermission> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please enable them in settings.');
    }
    
    return permission;
  }

  /// Get current position with high accuracy
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable location services.');
    }

    LocationPermission permission = await requestLocationPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions denied');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );

    _currentLocation = position;
    await _updateAddressFromPosition(position);
    
    return position;
  }

  /// Get last known position
  Future<Position?> getLastKnownPosition() async {
    return await Geolocator.getLastKnownPosition();
  }

  /// Listen to position stream for real-time updates
  Stream<Position> getPositionStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Convert position to address
  Future<String> getAddressFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return _formatAddress(place);
      }
    } catch (e) {
      print('Error getting address from position: $e');
    }
    return 'Unknown location';
  }

  /// Convert coordinates to address
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return _formatAddress(place);
      }
    } catch (e) {
      print('Error getting address from coordinates: $e');
    }
    return 'Unknown location';
  }

  /// Get coordinates from address string
  Future<List<Location>> getCoordinatesFromAddress(String address) async {
    try {
      return await locationFromAddress(address);
    } catch (e) {
      print('Error getting coordinates from address: $e');
      return [];
    }
  }

  /// Calculate distance between two positions in meters
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Calculate bearing between two positions
  double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Find nearby healthcare facilities (mock implementation)
  Future<List<HealthcareFacility>> findNearbyFacilities({
    Position? position,
    double radiusInMeters = 5000, // 5km default
    String? facilityType,
  }) async {
    Position currentPos = position ?? await getCurrentPosition();
    
    // Mock data - in real implementation, this would call a healthcare facilities API
    List<HealthcareFacility> mockFacilities = [
      HealthcareFacility(
        id: '1',
        name: 'City General Hospital',
        type: 'Hospital',
        latitude: currentPos.latitude + 0.01,
        longitude: currentPos.longitude + 0.01,
        address: '123 Main St, City Center',
        phone: '+1-555-0123',
        rating: 4.5,
      ),
      HealthcareFacility(
        id: '2',
        name: 'Community Health Clinic',
        type: 'Clinic',
        latitude: currentPos.latitude - 0.005,
        longitude: currentPos.longitude + 0.005,
        address: '456 Oak Ave, Downtown',
        phone: '+1-555-0456',
        rating: 4.2,
      ),
      HealthcareFacility(
        id: '3',
        name: 'MediQuick Pharmacy',
        type: 'Pharmacy',
        latitude: currentPos.latitude + 0.003,
        longitude: currentPos.longitude - 0.007,
        address: '789 Pine St, Uptown',
        phone: '+1-555-0789',
        rating: 4.0,
      ),
    ];

    // Filter by type if specified
    if (facilityType != null) {
      mockFacilities = mockFacilities
          .where((facility) => facility.type.toLowerCase() == facilityType.toLowerCase())
          .toList();
    }

    // Calculate distances and filter by radius
    List<HealthcareFacility> nearbyFacilities = [];
    for (var facility in mockFacilities) {
      double distance = calculateDistance(
        currentPos.latitude,
        currentPos.longitude,
        facility.latitude,
        facility.longitude,
      );

      if (distance <= radiusInMeters) {
        facility.distanceFromUser = distance;
        nearbyFacilities.add(facility);
      }
    }

    // Sort by distance
    nearbyFacilities.sort((a, b) => (a.distanceFromUser ?? 0).compareTo(b.distanceFromUser ?? 0));

    return nearbyFacilities;
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Private method to update address from position
  Future<void> _updateAddressFromPosition(Position position) async {
    try {
      _currentAddress = await getAddressFromPosition(position);
    } catch (e) {
      print('Error updating address: $e');
      _currentAddress = 'Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
    }
  }

  /// Private method to format address from placemark
  String _formatAddress(Placemark place) {
    List<String> addressParts = [];

    if (place.street != null && place.street!.isNotEmpty) {
      addressParts.add(place.street!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
      addressParts.add(place.administrativeArea!);
    }
    if (place.postalCode != null && place.postalCode!.isNotEmpty) {
      addressParts.add(place.postalCode!);
    }
    if (place.country != null && place.country!.isNotEmpty) {
      addressParts.add(place.country!);
    }

    return addressParts.join(', ');
  }
}

/// Healthcare facility model
class HealthcareFacility {
  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String address;
  final String phone;
  final double rating;
  double? distanceFromUser;

  HealthcareFacility({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.phone,
    required this.rating,
    this.distanceFromUser,
  });

  /// Get formatted distance string
  String get formattedDistance {
    if (distanceFromUser == null) return '';
    
    if (distanceFromUser! < 1000) {
      return '${distanceFromUser!.round()}m away';
    } else {
      return '${(distanceFromUser! / 1000).toStringAsFixed(1)}km away';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'phone': phone,
      'rating': rating,
      'distanceFromUser': distanceFromUser,
    };
  }

  factory HealthcareFacility.fromJson(Map<String, dynamic> json) {
    return HealthcareFacility(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      phone: json['phone'],
      rating: json['rating'],
      distanceFromUser: json['distanceFromUser'],
    );
  }
}
