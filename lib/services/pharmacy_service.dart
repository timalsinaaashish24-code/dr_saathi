import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/pharmacy.dart';
import '../models/prescription.dart';
import 'database_service.dart';
import 'sync_service.dart';

class PharmacyService {
  static const String _baseUrl = 'https://api.drsaathi.com/nepal/pharmacies';
  final DatabaseService _databaseService = DatabaseService();
  final SyncService _syncService = SyncService();
  final Uuid _uuid = const Uuid();

  // Nepal's major districts and zones
  static const Map<String, List<String>> nepalDistricts = {
    'Province 1': [
      'Bhojpur', 'Dhankuta', 'Ilam', 'Jhapa', 'Khotang', 'Morang',
      'Okhaldhunga', 'Panchthar', 'Sankhuwasabha', 'Solukhumbu',
      'Sunsari', 'Taplejung', 'Terhathum', 'Udayapur'
    ],
    'Province 2': [
      'Bara', 'Dhanusha', 'Mahottari', 'Parsa', 'Rautahat', 
      'Saptari', 'Sarlahi', 'Siraha'
    ],
    'Bagmati Province': [
      'Bhaktapur', 'Chitwan', 'Dhading', 'Dolakha', 'Kathmandu',
      'Kavrepalanchok', 'Lalitpur', 'Makwanpur', 'Nuwakot',
      'Ramechhap', 'Rasuwa', 'Sindhuli', 'Sindhupalchok'
    ],
    'Gandaki Province': [
      'Baglung', 'Gorkha', 'Kaski', 'Lamjung', 'Manang',
      'Mustang', 'Myagdi', 'Nawalpur', 'Parbat', 'Syangja', 'Tanahun'
    ],
    'Lumbini Province': [
      'Arghakhanchi', 'Banke', 'Bardiya', 'Dang', 'Gulmi',
      'Kapilvastu', 'Nawalparasi West', 'Palpa', 'Pyuthan',
      'Rolpa', 'Rupandehi', 'Salyan'
    ],
    'Karnali Province': [
      'Dailekh', 'Dolpa', 'Humla', 'Jajarkot', 'Jumla',
      'Kalikot', 'Mugu', 'Rukum West', 'Salyan', 'Surkhet'
    ],
    'Sudurpashchim Province': [
      'Achham', 'Baitadi', 'Bajhang', 'Bajura', 'Dadeldhura',
      'Darchula', 'Doti', 'Kailali', 'Kanchanpur'
    ]
  };

  /// Initialize pharmacy service and setup database tables
  Future<void> initialize() async {
    await _createPharmacyTables();
    await _loadSamplePharmacies();
  }

  /// Create database tables for pharmacy functionality
  Future<void> _createPharmacyTables() async {
    final db = await _databaseService.database;
    
    // Pharmacies table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pharmacies (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        registration_number TEXT NOT NULL,
        district TEXT NOT NULL,
        zone TEXT NOT NULL,
        province TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        is_active INTEGER DEFAULT 1,
        is_verified INTEGER DEFAULT 0,
        type TEXT NOT NULL,
        services TEXT NOT NULL,
        operating_hours TEXT NOT NULL,
        rating REAL DEFAULT 0.0,
        profile_image TEXT,
        website TEXT,
        fax TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Prescription deliveries table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS prescription_deliveries (
        id TEXT PRIMARY KEY,
        prescription_id TEXT NOT NULL,
        pharmacy_id TEXT NOT NULL,
        patient_id TEXT NOT NULL,
        doctor_id TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        delivery_address TEXT NOT NULL,
        patient_phone TEXT NOT NULL,
        order_date TEXT NOT NULL,
        estimated_delivery_date TEXT,
        actual_delivery_date TEXT,
        total_amount REAL NOT NULL DEFAULT 0.0,
        is_paid INTEGER DEFAULT 0,
        payment_method TEXT,
        payment_transaction_id TEXT,
        delivery_instructions TEXT,
        tracking_number TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (prescription_id) REFERENCES prescriptions (id),
        FOREIGN KEY (pharmacy_id) REFERENCES pharmacies (id),
        FOREIGN KEY (patient_id) REFERENCES patients (id)
      )
    ''');

    // Prescription delivery items table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS prescription_delivery_items (
        id TEXT PRIMARY KEY,
        delivery_id TEXT NOT NULL,
        medication_id TEXT NOT NULL,
        medication_name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        is_available INTEGER DEFAULT 1,
        alternative_id TEXT,
        alternative_name TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (delivery_id) REFERENCES prescription_deliveries (id)
      )
    ''');
  }

  /// Load sample pharmacies for Nepal (for demo purposes)
  Future<void> _loadSamplePharmacies() async {
    final db = await _databaseService.database;
    
    // Check if we already have pharmacies
    final result = await db.query('pharmacies', limit: 1);
    if (result.isNotEmpty) return;

    // Sample pharmacies for major cities in Nepal
    final samplePharmacies = [
      Pharmacy(
        id: _uuid.v4(),
        name: 'New Road Medical Hall',
        address: 'New Road, Kathmandu',
        phone: '+977-1-4242424',
        email: 'info@newroadmedical.com.np',
        registrationNumber: 'PHM-KTM-001',
        district: 'Kathmandu',
        zone: 'Bagmati',
        province: 'Bagmati Province',
        latitude: 27.7044,
        longitude: 85.3137,
        isActive: true,
        isVerified: true,
        type: PharmacyType.retail,
        services: ['Prescription Filling', 'Home Delivery', 'Medicine Consultation'],
        operatingHours: '6:00 AM - 10:00 PM',
        rating: 4.5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Pharmacy(
        id: _uuid.v4(),
        name: 'Bhrikuti Pharmacy',
        address: 'Bhrikutimandap, Kathmandu',
        phone: '+977-1-4235678',
        email: 'contact@bhrikutipharmacy.com.np',
        registrationNumber: 'PHM-KTM-002',
        district: 'Kathmandu',
        zone: 'Bagmati',
        province: 'Bagmati Province',
        latitude: 27.6950,
        longitude: 85.3110,
        isActive: true,
        isVerified: true,
        type: PharmacyType.chain,
        services: ['24/7 Service', 'Online Orders', 'Insurance Claims'],
        operatingHours: '24 Hours',
        rating: 4.8,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Pharmacy(
        id: _uuid.v4(),
        name: 'Pokhara Central Pharmacy',
        address: 'Lakeside, Pokhara',
        phone: '+977-61-465432',
        email: 'info@pokharacentralpharmacy.com',
        registrationNumber: 'PHM-PKR-001',
        district: 'Kaski',
        zone: 'Gandaki',
        province: 'Gandaki Province',
        latitude: 28.2096,
        longitude: 83.9856,
        isActive: true,
        isVerified: true,
        type: PharmacyType.community,
        services: ['Prescription Filling', 'Health Checkups', 'Ayurvedic Medicines'],
        operatingHours: '7:00 AM - 9:00 PM',
        rating: 4.2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Pharmacy(
        id: _uuid.v4(),
        name: 'Biratnagar Medical Store',
        address: 'Main Road, Biratnagar',
        phone: '+977-21-234567',
        email: 'info@biratnagarmedical.com.np',
        registrationNumber: 'PHM-BRT-001',
        district: 'Morang',
        zone: 'Koshi',
        province: 'Province 1',
        latitude: 26.4549,
        longitude: 87.2718,
        isActive: true,
        isVerified: true,
        type: PharmacyType.retail,
        services: ['Medicine Supply', 'Lab Tests', 'Health Consultation'],
        operatingHours: '8:00 AM - 8:00 PM',
        rating: 4.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Pharmacy(
        id: _uuid.v4(),
        name: 'Chitwan Health Pharmacy',
        address: 'Bharatpur-10, Chitwan',
        phone: '+977-56-123456',
        email: 'contact@chitwanhealthpharmacy.com',
        registrationNumber: 'PHM-CHT-001',
        district: 'Chitwan',
        zone: 'Narayani',
        province: 'Bagmati Province',
        latitude: 27.6747,
        longitude: 84.4349,
        isActive: true,
        isVerified: true,
        type: PharmacyType.hospital,
        services: ['Emergency Medicine', 'Specialized Drugs', 'Patient Care'],
        operatingHours: '24 Hours',
        rating: 4.6,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    // Insert sample pharmacies
    for (final pharmacy in samplePharmacies) {
      await db.insert('pharmacies', pharmacy.toJson());
    }
  }

  /// Get all pharmacies
  Future<List<Pharmacy>> getAllPharmacies() async {
    final db = await _databaseService.database;
    final result = await db.query('pharmacies', orderBy: 'name ASC');
    
    return result.map((json) => Pharmacy.fromJson(json)).toList();
  }

  /// Get pharmacies by district
  Future<List<Pharmacy>> getPharmaciesByDistrict(String district) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'pharmacies',
      where: 'district = ? AND is_active = 1',
      whereArgs: [district],
      orderBy: 'name ASC',
    );
    
    return result.map((json) => Pharmacy.fromJson(json)).toList();
  }

  /// Get pharmacies by province
  Future<List<Pharmacy>> getPharmaciesByProvince(String province) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'pharmacies',
      where: 'province = ? AND is_active = 1',
      whereArgs: [province],
      orderBy: 'rating DESC, name ASC',
    );
    
    return result.map((json) => Pharmacy.fromJson(json)).toList();
  }

  /// Search pharmacies by name or address
  Future<List<Pharmacy>> searchPharmacies(String query) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'pharmacies',
      where: '(name LIKE ? OR address LIKE ?) AND is_active = 1',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'rating DESC, name ASC',
    );
    
    return result.map((json) => Pharmacy.fromJson(json)).toList();
  }

  /// Send prescription to pharmacy
  Future<String?> sendPrescriptionToPharmacy({
    required String prescriptionId,
    required String pharmacyId,
    required String patientId,
    required String deliveryAddress,
    required String patientPhone,
    String? deliveryInstructions,
  }) async {
    try {
      // Get prescription details
      final prescription = await _getPrescriptionById(prescriptionId);
      if (prescription == null) {
        throw Exception('Prescription not found');
      }

      // Get pharmacy details
      final pharmacy = await _getPharmacyById(pharmacyId);
      if (pharmacy == null) {
        throw Exception('Pharmacy not found');
      }

      // Create delivery order
      final deliveryId = _uuid.v4();
      final now = DateTime.now();
      
      final delivery = PrescriptionDelivery(
        id: deliveryId,
        prescriptionId: prescriptionId,
        pharmacyId: pharmacyId,
        patientId: patientId,
        doctorId: prescription.doctorId,
        status: DeliveryStatus.pending,
        deliveryAddress: deliveryAddress,
        patientPhone: patientPhone,
        orderDate: now,
        totalAmount: 0.0, // Will be calculated by pharmacy
        deliveryInstructions: deliveryInstructions,
        items: prescription.medications.map((med) => PrescriptionItem(
          id: _uuid.v4(),
          medicationId: med.id?.toString() ?? _uuid.v4(),
          medicationName: med.name,
          dosage: med.dosage,
          quantity: med.quantity,
          unitPrice: 0.0, // To be filled by pharmacy
          totalPrice: 0.0, // To be calculated by pharmacy
        )).toList(),
        createdAt: now,
        updatedAt: now,
      );

      // Save to local database
      await _savePrescriptionDelivery(delivery);

      // Try to send to pharmacy API (if online)
      try {
        await _sendToPharmacyAPI(delivery, pharmacy);
      } catch (e) {
        print('Failed to send to pharmacy API: $e');
        // Continue with local storage for offline functionality
      }

      return deliveryId;
    } catch (e) {
      print('Error sending prescription to pharmacy: $e');
      return null;
    }
  }

  /// Save prescription delivery to local database
  Future<void> _savePrescriptionDelivery(PrescriptionDelivery delivery) async {
    final db = await _databaseService.database;
    
    // Insert delivery
    await db.insert('prescription_deliveries', delivery.toJson());
    
    // Insert delivery items
    for (final item in delivery.items) {
      await db.insert('prescription_delivery_items', {
        ...item.toJson(),
        'delivery_id': delivery.id,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Send delivery to pharmacy API
  Future<void> _sendToPharmacyAPI(PrescriptionDelivery delivery, Pharmacy pharmacy) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/${pharmacy.id}/prescriptions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _getAuthToken()}',
      },
      body: json.encode(delivery.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send prescription to pharmacy: ${response.body}');
    }
  }

  /// Get prescription by ID
  Future<Prescription?> _getPrescriptionById(String prescriptionId) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'prescriptions',
      where: 'id = ?',
      whereArgs: [prescriptionId],
      limit: 1,
    );

    if (result.isEmpty) return null;

    final prescription = Prescription.fromDatabaseJson(result.first);
    
    // Load medications
    final medications = await _getMedicationsByPrescriptionId(prescriptionId);
    
    return prescription.copyWith(medications: medications);
  }

  /// Get medications by prescription ID
  Future<List<Medication>> _getMedicationsByPrescriptionId(String prescriptionId) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'medications',
      where: 'prescription_id = ?',
      whereArgs: [prescriptionId],
    );

    return result.map((json) => Medication.fromDatabaseJson(json)).toList();
  }

  /// Get pharmacy by ID
  Future<Pharmacy?> _getPharmacyById(String pharmacyId) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'pharmacies',
      where: 'id = ?',
      whereArgs: [pharmacyId],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Pharmacy.fromJson(result.first);
  }

  /// Get prescription deliveries for a patient
  Future<List<PrescriptionDelivery>> getPatientDeliveries(String patientId) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'prescription_deliveries',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'created_at DESC',
    );

    List<PrescriptionDelivery> deliveries = [];
    for (final json in result) {
      final items = await _getDeliveryItems(json['id'] as String);
      final delivery = PrescriptionDelivery.fromJson({...json, 'items': items.map((i) => i.toJson()).toList()});
      deliveries.add(delivery);
    }

    return deliveries;
  }

  /// Get delivery items
  Future<List<PrescriptionItem>> _getDeliveryItems(String deliveryId) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'prescription_delivery_items',
      where: 'delivery_id = ?',
      whereArgs: [deliveryId],
    );

    return result.map((json) => PrescriptionItem.fromJson(json)).toList();
  }

  /// Update delivery status
  Future<void> updateDeliveryStatus(String deliveryId, DeliveryStatus status) async {
    final db = await _databaseService.database;
    await db.update(
      'prescription_deliveries',
      {
        'status': status.toString(),
        'updated_at': DateTime.now().toIso8601String(),
        if (status == DeliveryStatus.delivered)
          'actual_delivery_date': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [deliveryId],
    );
  }

  /// Get all districts for a province
  static List<String> getDistrictsForProvince(String province) {
    return nepalDistricts[province] ?? [];
  }

  /// Get all provinces
  static List<String> getAllProvinces() {
    return nepalDistricts.keys.toList();
  }

  /// Get auth token for API calls (placeholder)
  Future<String> _getAuthToken() async {
    // In a real implementation, this would get the auth token
    // from secure storage or login service
    return 'demo_token_123';
  }

  /// Sync deliveries with server
  Future<void> syncDeliveries() async {
    await _syncService.syncPrescriptionDeliveries();
  }

  /// Get delivery tracking info
  Future<Map<String, dynamic>?> getDeliveryTracking(String trackingNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/tracking/$trackingNumber'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error getting delivery tracking: $e');
    }
    return null;
  }

  /// Rate pharmacy
  Future<void> ratePharmacy(String pharmacyId, double rating) async {
    final db = await _databaseService.database;
    
    // Get current rating
    final result = await db.query(
      'pharmacies',
      columns: ['rating'],
      where: 'id = ?',
      whereArgs: [pharmacyId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final currentRating = result.first['rating'] as double;
      final newRating = (currentRating + rating) / 2; // Simple average
      
      await db.update(
        'pharmacies',
        {
          'rating': newRating,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [pharmacyId],
      );
    }
  }
}
