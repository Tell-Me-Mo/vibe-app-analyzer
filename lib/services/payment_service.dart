import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'credits_service.dart';
import '../models/credit_package.dart';

/// Mock Payment Service - Simulates purchases without real payment provider
/// This allows testing the credits flow without integrating Stripe/Paddle
///
/// TODO: Replace with real Paddle integration for production
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  bool _initialized = false;

  /// Initialize payment service (mock - does nothing)
  Future<void> initialize(String userId) async {
    if (_initialized) return;

    // Mock initialization - just mark as initialized
    await Future.delayed(const Duration(milliseconds: 100));
    _initialized = true;
    debugPrint('✅ [MOCK PAYMENT] Payment service initialized (mock mode)');
  }

  /// Get available packages (returns mock packages based on CreditPackages)
  Future<List<MockPackage>> getAvailablePackages() async {
    await Future.delayed(const Duration(milliseconds: 200));

    return CreditPackages.allPackages.map((pkg) => MockPackage(
      id: pkg.id,
      name: pkg.name,
      credits: pkg.credits,
      price: pkg.price,
    )).toList();
  }

  /// Simulate purchasing a package
  /// This will immediately grant credits without any payment
  Future<bool> purchasePackage(CreditPackage package) async {
    try {
      debugPrint('🛒 [MOCK PAYMENT] Simulating purchase of ${package.name}');

      // Simulate payment processing delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Grant credits immediately
      await grantCreditsForPurchase(package.id);

      debugPrint('✅ [MOCK PAYMENT] Purchase successful - ${package.credits} credits granted');
      return true;
    } catch (e) {
      debugPrint('❌ [MOCK PAYMENT] Purchase failed: $e');
      throw PaymentException('Mock purchase failed: $e');
    }
  }

  /// Grant credits for a purchase
  Future<void> grantCreditsForPurchase(String productId) async {
    final credits = CreditPackages.getCreditsForProductId(productId);

    if (credits > 0) {
      await CreditsService().addCredits(credits);
      debugPrint('💰 [MOCK PAYMENT] Granted $credits credits for product $productId');
    } else {
      debugPrint('⚠️ [MOCK PAYMENT] No credits found for product $productId');
    }
  }

  /// Restore purchases (mock - does nothing)
  Future<void> restorePurchases() async {
    await Future.delayed(const Duration(milliseconds: 200));
    debugPrint('🔄 [MOCK PAYMENT] Restore purchases called (mock mode - no action)');
  }

  /// Check if user has active subscription (mock - always returns false)
  Future<bool> hasActiveSubscription() async {
    return false;
  }

  /// Logout (mock - does nothing)
  Future<void> logout() async {
    _initialized = false;
    debugPrint('👋 [MOCK PAYMENT] Logout called (mock mode)');
  }
}

/// Mock package class to replace RevenueCat Package
class MockPackage {
  final String id;
  final String name;
  final int credits;
  final double price;

  MockPackage({
    required this.id,
    required this.name,
    required this.credits,
    required this.price,
  });
}

/// Custom exception for payment errors
class PaymentException implements Exception {
  final String message;
  PaymentException(this.message);

  @override
  String toString() => message;
}

/// Provider for payment service
final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});
