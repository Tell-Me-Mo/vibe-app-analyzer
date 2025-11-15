import 'package:json_annotation/json_annotation.dart';

part 'credit_package.g.dart';

@JsonSerializable()
class CreditPackage {
  final String id;
  final String name;
  final String description;
  final int credits;
  final double price;
  final String priceDisplay;
  final bool isPopular;
  final double? savings; // Percentage savings compared to base price

  const CreditPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.credits,
    required this.price,
    required this.priceDisplay,
    this.isPopular = false,
    this.savings,
  });

  factory CreditPackage.fromJson(Map<String, dynamic> json) =>
      _$CreditPackageFromJson(json);

  Map<String, dynamic> toJson() => _$CreditPackageToJson(this);

  /// Get the price per credit
  double get pricePerCredit => price / credits;
}

/// Pre-defined credit packages
class CreditPackages {
  static const starter = CreditPackage(
    id: 'starter_pack',
    name: 'Starter Pack',
    description: '20 credits for casual use',
    credits: 20,
    price: 4.99,
    priceDisplay: '\$4.99',
  );

  static const popular = CreditPackage(
    id: 'popular_pack',
    name: 'Popular Pack',
    description: '50 credits with 20% savings',
    credits: 50,
    price: 9.99,
    priceDisplay: '\$9.99',
    isPopular: true,
    savings: 20,
  );

  static const professional = CreditPackage(
    id: 'professional_pack',
    name: 'Professional Pack',
    description: '120 credits with 35% savings',
    credits: 120,
    price: 19.99,
    priceDisplay: '\$19.99',
    savings: 35,
  );

  static const enterprise = CreditPackage(
    id: 'enterprise_pack',
    name: 'Enterprise Pack',
    description: '300 credits with 50% savings',
    credits: 300,
    price: 39.99,
    priceDisplay: '\$39.99',
    savings: 50,
  );

  static const List<CreditPackage> all = [
    starter,
    popular,
    professional,
    enterprise,
  ];

  /// Map RevenueCat product identifiers to credit amounts
  /// This should match your RevenueCat product configuration
  static const Map<String, int> productIdToCredits = {
    'starter_pack': 20,
    'popular_pack': 50,
    'professional_pack': 120,
    'enterprise_pack': 300,
    // Alternative product ID formats (in case of platform prefixes)
    'rc_starter_pack': 20,
    'rc_popular_pack': 50,
    'rc_professional_pack': 120,
    'rc_enterprise_pack': 300,
  };

  /// Get credit amount for a given product identifier
  /// Returns the credit amount, or 0 if product ID is not recognized
  static int getCreditsForProductId(String productId) {
    // Try exact match first
    if (productIdToCredits.containsKey(productId)) {
      return productIdToCredits[productId]!;
    }

    // Fallback: try to extract package ID from product identifier
    // Handle cases where product ID might have platform-specific suffixes
    // e.g., "starter_pack.monthly" or "com.vibecheck.starter_pack"
    for (final entry in productIdToCredits.entries) {
      if (productId.contains(entry.key)) {
        return entry.value;
      }
    }

    return 0;
  }

  /// Get CreditPackage by ID
  static CreditPackage? getById(String id) {
    try {
      return all.firstWhere((package) => package.id == id);
    } catch (e) {
      return null;
    }
  }
}
