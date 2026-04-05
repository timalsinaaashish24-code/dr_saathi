class PricingTier {
  final String id;
  final String name;
  final int maxPatients;
  final double price;
  final String currency;
  final List<String> features;
  final bool isPopular;
  final String description;

  const PricingTier({
    required this.id,
    required this.name,
    required this.maxPatients,
    required this.price,
    required this.currency,
    required this.features,
    this.isPopular = false,
    required this.description,
  });

  // Static method to get all available tiers
  static List<PricingTier> getAllTiers() {
    return [
      const PricingTier(
        id: 'tier1',
        name: 'Starter',
        maxPatients: 500,
        price: 5000,
        currency: 'Rs',
        description: 'Perfect for small clinics and individual practitioners',
        features: [
          'Up to 500 patients',
          'Digital prescriptions',
          'SMS reminders',
          'Basic analytics',
          'Patient management',
          'Email support',
        ],
      ),
      const PricingTier(
        id: 'tier2',
        name: 'Professional',
        maxPatients: 1500,
        price: 10000,
        currency: 'Rs',
        description: 'Ideal for growing practices and multi-doctor clinics',
        isPopular: true,
        features: [
          'Up to 1,500 patients',
          'Digital prescriptions',
          'SMS reminders',
          'Advanced analytics',
          'Patient management',
          'Appointment scheduling',
          'Priority support',
          'Multi-doctor access',
        ],
      ),
      const PricingTier(
        id: 'tier3',
        name: 'Enterprise',
        maxPatients: 3000,
        price: 15000,
        currency: 'Rs',
        description: 'Comprehensive solution for large hospitals and networks',
        features: [
          'Up to 3,000 patients',
          'Digital prescriptions',
          'SMS reminders',
          'Comprehensive analytics',
          'Patient management',
          'Appointment scheduling',
          'Inventory management',
          '24/7 priority support',
          'Multi-location support',
          'Custom integrations',
        ],
      ),
    ];
  }

  // Get tier by ID
  static PricingTier? getTierById(String id) {
    try {
      return getAllTiers().firstWhere((tier) => tier.id == id);
    } catch (e) {
      return null;
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'maxPatients': maxPatients,
      'price': price,
      'currency': currency,
      'features': features,
      'isPopular': isPopular,
      'description': description,
    };
  }

  // Create from JSON
  factory PricingTier.fromJson(Map<String, dynamic> json) {
    return PricingTier(
      id: json['id'],
      name: json['name'],
      maxPatients: json['maxPatients'],
      price: json['price'].toDouble(),
      currency: json['currency'],
      features: List<String>.from(json['features']),
      isPopular: json['isPopular'] ?? false,
      description: json['description'],
    );
  }

  @override
  String toString() {
    return 'PricingTier(id: $id, name: $name, maxPatients: $maxPatients, price: $price)';
  }
}
