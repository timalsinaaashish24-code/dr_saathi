class Pharmacy {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String registrationNumber;
  final String district;
  final String zone;
  final String province;
  final double latitude;
  final double longitude;
  final bool isActive;
  final bool isVerified;
  final PharmacyType type;
  final List<String> services;
  final String operatingHours;
  final double rating;
  final String? profileImage;
  final String? website;
  final String? fax;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.registrationNumber,
    required this.district,
    required this.zone,
    required this.province,
    required this.latitude,
    required this.longitude,
    this.isActive = true,
    this.isVerified = false,
    required this.type,
    required this.services,
    required this.operatingHours,
    this.rating = 0.0,
    this.profileImage,
    this.website,
    this.fax,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      registrationNumber: json['registration_number'],
      district: json['district'],
      zone: json['zone'],
      province: json['province'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      isActive: json['is_active'] ?? true,
      isVerified: json['is_verified'] ?? false,
      type: PharmacyType.values.firstWhere(
        (type) => type.toString() == json['type'],
        orElse: () => PharmacyType.retail,
      ),
      services: List<String>.from(json['services'] ?? []),
      operatingHours: json['operating_hours'] ?? '9:00 AM - 9:00 PM',
      rating: json['rating']?.toDouble() ?? 0.0,
      profileImage: json['profile_image'],
      website: json['website'],
      fax: json['fax'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'registration_number': registrationNumber,
      'district': district,
      'zone': zone,
      'province': province,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
      'is_verified': isVerified,
      'type': type.toString(),
      'services': services,
      'operating_hours': operatingHours,
      'rating': rating,
      'profile_image': profileImage,
      'website': website,
      'fax': fax,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Pharmacy copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    String? registrationNumber,
    String? district,
    String? zone,
    String? province,
    double? latitude,
    double? longitude,
    bool? isActive,
    bool? isVerified,
    PharmacyType? type,
    List<String>? services,
    String? operatingHours,
    double? rating,
    String? profileImage,
    String? website,
    String? fax,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pharmacy(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      district: district ?? this.district,
      zone: zone ?? this.zone,
      province: province ?? this.province,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      type: type ?? this.type,
      services: services ?? this.services,
      operatingHours: operatingHours ?? this.operatingHours,
      rating: rating ?? this.rating,
      profileImage: profileImage ?? this.profileImage,
      website: website ?? this.website,
      fax: fax ?? this.fax,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum PharmacyType {
  retail,
  hospital,
  chain,
  community,
  online,
}

extension PharmacyTypeExtension on PharmacyType {
  String get displayName {
    switch (this) {
      case PharmacyType.retail:
        return 'Retail Pharmacy';
      case PharmacyType.hospital:
        return 'Hospital Pharmacy';
      case PharmacyType.chain:
        return 'Chain Pharmacy';
      case PharmacyType.community:
        return 'Community Pharmacy';
      case PharmacyType.online:
        return 'Online Pharmacy';
    }
  }
}

class PrescriptionDelivery {
  final String id;
  final String prescriptionId;
  final String pharmacyId;
  final String patientId;
  final String doctorId;
  final DeliveryStatus status;
  final String deliveryAddress;
  final String patientPhone;
  final DateTime orderDate;
  final DateTime? estimatedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final double totalAmount;
  final bool isPaid;
  final String? paymentMethod;
  final String? paymentTransactionId;
  final String? deliveryInstructions;
  final String? trackingNumber;
  final List<PrescriptionItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  PrescriptionDelivery({
    required this.id,
    required this.prescriptionId,
    required this.pharmacyId,
    required this.patientId,
    required this.doctorId,
    required this.status,
    required this.deliveryAddress,
    required this.patientPhone,
    required this.orderDate,
    this.estimatedDeliveryDate,
    this.actualDeliveryDate,
    required this.totalAmount,
    this.isPaid = false,
    this.paymentMethod,
    this.paymentTransactionId,
    this.deliveryInstructions,
    this.trackingNumber,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PrescriptionDelivery.fromJson(Map<String, dynamic> json) {
    return PrescriptionDelivery(
      id: json['id'],
      prescriptionId: json['prescription_id'],
      pharmacyId: json['pharmacy_id'],
      patientId: json['patient_id'],
      doctorId: json['doctor_id'],
      status: DeliveryStatus.values.firstWhere(
        (status) => status.toString() == json['status'],
        orElse: () => DeliveryStatus.pending,
      ),
      deliveryAddress: json['delivery_address'],
      patientPhone: json['patient_phone'],
      orderDate: DateTime.parse(json['order_date']),
      estimatedDeliveryDate: json['estimated_delivery_date'] != null
          ? DateTime.parse(json['estimated_delivery_date'])
          : null,
      actualDeliveryDate: json['actual_delivery_date'] != null
          ? DateTime.parse(json['actual_delivery_date'])
          : null,
      totalAmount: json['total_amount'].toDouble(),
      isPaid: json['is_paid'] ?? false,
      paymentMethod: json['payment_method'],
      paymentTransactionId: json['payment_transaction_id'],
      deliveryInstructions: json['delivery_instructions'],
      trackingNumber: json['tracking_number'],
      items: (json['items'] as List? ?? [])
          .map((item) => PrescriptionItem.fromJson(item))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prescription_id': prescriptionId,
      'pharmacy_id': pharmacyId,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'status': status.toString(),
      'delivery_address': deliveryAddress,
      'patient_phone': patientPhone,
      'order_date': orderDate.toIso8601String(),
      'estimated_delivery_date': estimatedDeliveryDate?.toIso8601String(),
      'actual_delivery_date': actualDeliveryDate?.toIso8601String(),
      'total_amount': totalAmount,
      'is_paid': isPaid,
      'payment_method': paymentMethod,
      'payment_transaction_id': paymentTransactionId,
      'delivery_instructions': deliveryInstructions,
      'tracking_number': trackingNumber,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

enum DeliveryStatus {
  pending,
  confirmed,
  preparing,
  readyForDelivery,
  outForDelivery,
  delivered,
  cancelled,
  returned,
}

extension DeliveryStatusExtension on DeliveryStatus {
  String get displayName {
    switch (this) {
      case DeliveryStatus.pending:
        return 'Pending';
      case DeliveryStatus.confirmed:
        return 'Confirmed';
      case DeliveryStatus.preparing:
        return 'Preparing';
      case DeliveryStatus.readyForDelivery:
        return 'Ready for Delivery';
      case DeliveryStatus.outForDelivery:
        return 'Out for Delivery';
      case DeliveryStatus.delivered:
        return 'Delivered';
      case DeliveryStatus.cancelled:
        return 'Cancelled';
      case DeliveryStatus.returned:
        return 'Returned';
    }
  }
}

class PrescriptionItem {
  final String id;
  final String medicationId;
  final String medicationName;
  final String dosage;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final bool isAvailable;
  final String? alternativeId;
  final String? alternativeName;
  final String? notes;

  PrescriptionItem({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.isAvailable = true,
    this.alternativeId,
    this.alternativeName,
    this.notes,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) {
    return PrescriptionItem(
      id: json['id'],
      medicationId: json['medication_id'],
      medicationName: json['medication_name'],
      dosage: json['dosage'],
      quantity: json['quantity'],
      unitPrice: json['unit_price'].toDouble(),
      totalPrice: json['total_price'].toDouble(),
      isAvailable: json['is_available'] ?? true,
      alternativeId: json['alternative_id'],
      alternativeName: json['alternative_name'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medication_id': medicationId,
      'medication_name': medicationName,
      'dosage': dosage,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'is_available': isAvailable,
      'alternative_id': alternativeId,
      'alternative_name': alternativeName,
      'notes': notes,
    };
  }
}
