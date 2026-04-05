class BillingItem {
  final String id;
  final String description;
  final BillingItemType type;
  final double quantity;
  final double unitPrice;
  final double totalAmount;
  final String? category;
  final DateTime createdAt;

  const BillingItem({
    required this.id,
    required this.description,
    required this.type,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    this.category,
    required this.createdAt,
  });

  // Factory constructor to create billing item with automatic total calculation
  factory BillingItem.create({
    required String description,
    required BillingItemType type,
    required double quantity,
    required double unitPrice,
    String? category,
  }) {
    final totalAmount = quantity * unitPrice;
    
    return BillingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: description,
      type: type,
      quantity: quantity,
      unitPrice: unitPrice,
      totalAmount: totalAmount,
      category: category,
      createdAt: DateTime.now(),
    );
  }

  // Predefined billing items for common medical services
  static List<BillingItem> getCommonBillingItems() {
    return [
      BillingItem.create(
        description: 'Consultation Fee',
        type: BillingItemType.consultation,
        quantity: 1,
        unitPrice: 1000.0,
        category: 'Medical Services',
      ),
      BillingItem.create(
        description: 'Follow-up Consultation',
        type: BillingItemType.consultation,
        quantity: 1,
        unitPrice: 500.0,
        category: 'Medical Services',
      ),
      BillingItem.create(
        description: 'Physical Examination',
        type: BillingItemType.examination,
        quantity: 1,
        unitPrice: 300.0,
        category: 'Medical Services',
      ),
      BillingItem.create(
        description: 'Blood Test - CBC',
        type: BillingItemType.laboratory,
        quantity: 1,
        unitPrice: 800.0,
        category: 'Laboratory',
      ),
      BillingItem.create(
        description: 'X-Ray Chest',
        type: BillingItemType.imaging,
        quantity: 1,
        unitPrice: 1500.0,
        category: 'Imaging',
      ),
      BillingItem.create(
        description: 'ECG',
        type: BillingItemType.procedure,
        quantity: 1,
        unitPrice: 600.0,
        category: 'Procedures',
      ),
      BillingItem.create(
        description: 'Prescription Writing',
        type: BillingItemType.prescription,
        quantity: 1,
        unitPrice: 100.0,
        category: 'Medical Services',
      ),
      BillingItem.create(
        description: 'Health Certificate',
        type: BillingItemType.certificate,
        quantity: 1,
        unitPrice: 200.0,
        category: 'Documentation',
      ),
    ];
  }

  // Get billing items by category
  static List<BillingItem> getBillingItemsByCategory(String category) {
    return getCommonBillingItems()
        .where((item) => item.category == category)
        .toList();
  }

  // Copy with method for updates
  BillingItem copyWith({
    String? id,
    String? description,
    BillingItemType? type,
    double? quantity,
    double? unitPrice,
    double? totalAmount,
    String? category,
    DateTime? createdAt,
  }) {
    return BillingItem(
      id: id ?? this.id,
      description: description ?? this.description,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? (quantity ?? this.quantity) * (unitPrice ?? this.unitPrice),
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'type': type.toString().split('.').last,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory BillingItem.fromJson(Map<String, dynamic> json) {
    return BillingItem(
      id: json['id'],
      description: json['description'],
      type: BillingItemType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      quantity: json['quantity'].toDouble(),
      unitPrice: json['unit_price'].toDouble(),
      totalAmount: json['total_amount'].toDouble(),
      category: json['category'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Convenience getter for backward compatibility
  double get total => totalAmount;

  // Get formatted display name for type
  String get typeDisplay {
    switch (type) {
      case BillingItemType.consultation:
        return 'Consultation';
      case BillingItemType.examination:
        return 'Examination';
      case BillingItemType.procedure:
        return 'Procedure';
      case BillingItemType.laboratory:
        return 'Laboratory Test';
      case BillingItemType.imaging:
        return 'Imaging';
      case BillingItemType.medication:
        return 'Medication';
      case BillingItemType.prescription:
        return 'Prescription';
      case BillingItemType.certificate:
        return 'Certificate';
      case BillingItemType.other:
        return 'Other';
    }
  }

  @override
  String toString() {
    return 'BillingItem(description: $description, quantity: $quantity, unitPrice: Rs $unitPrice, total: Rs $totalAmount)';
  }
}

enum BillingItemType {
  consultation,
  examination,
  procedure,
  laboratory,
  imaging,
  medication,
  prescription,
  certificate,
  other,
}