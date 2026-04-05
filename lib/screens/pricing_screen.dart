import 'package:flutter/material.dart';
import '../models/pricing_tier.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  String? selectedTierId;

  @override
  Widget build(BuildContext context) {
    final tiers = PricingTier.getAllTiers();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
        backgroundColor: Colors.lightBlue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.lightBlue[600],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Doctor Promotional Offer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Special launch pricing for early adopters',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Limited Time Offer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Pricing Cards
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: tiers.length,
                itemBuilder: (context, index) {
                  final tier = tiers[index];
                  final isSelected = selectedTierId == tier.id;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildPricingCard(tier, isSelected),
                  );
                },
              ),
            ),
          ),

          // Bottom Action Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedTierId != null ? _subscribeToTier : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  selectedTierId != null ? 'Subscribe Now' : 'Select a Plan',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(PricingTier tier, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTierId = tier.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? Colors.lightBlue[600]! 
              : tier.isPopular 
                ? Colors.orange
                : Colors.grey[300]!,
            width: isSelected ? 3 : tier.isPopular ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? Colors.lightBlue.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
              spreadRadius: isSelected ? 2 : 1,
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Popular badge
            if (tier.isPopular)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'POPULAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Selected indicator
            if (isSelected)
              const Positioned(
                top: 16,
                left: 16,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.lightBlue,
                  size: 24,
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tier name and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tier.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${tier.maxPatients} patients',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text(
                                tier.currency,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tier.price.toStringAsFixed(0),
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlue[700],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'per month',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    tier.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Features list
                  ...tier.features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green[600],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _subscribeToTier() {
    if (selectedTierId == null) return;
    
    final selectedTier = PricingTier.getTierById(selectedTierId!);
    if (selectedTier == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You have selected the ${selectedTier.name} plan:'),
            const SizedBox(height: 8),
            Text('• Up to ${selectedTier.maxPatients} patients'),
            Text('• ${selectedTier.currency} ${selectedTier.price.toStringAsFixed(0)}/month'),
            const SizedBox(height: 16),
            const Text(
              'This is a promotional offer. Do you want to proceed?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processSubscription(selectedTier);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _processSubscription(PricingTier tier) {
    // Here you would integrate with payment processing
    // For now, we'll just show a success message
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscription Activated!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your ${tier.name} plan has been activated successfully!'),
            const SizedBox(height: 16),
            Text('You can now manage up to ${tier.maxPatients} patients.'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to dashboard
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Great!'),
          ),
        ],
      ),
    );

    // TODO: Save subscription to database
    // TODO: Update user's subscription status
    // TODO: Send confirmation email/SMS
  }
}
