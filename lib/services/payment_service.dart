import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import 'credits_service.dart';
import '../models/credit_package.dart';

/// Payment service using RevenueCat
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  bool _initialized = false;

  /// Initialize RevenueCat
  Future<void> initialize(String userId) async {
    if (_initialized) return;

    try {
      String apiKey;

      if (kIsWeb) {
        apiKey = dotenv.env['REVENUECAT_API_KEY_WEB'] ?? '';
      } else if (Platform.isIOS || Platform.isMacOS) {
        apiKey = dotenv.env['REVENUECAT_API_KEY_IOS'] ?? '';
      } else if (Platform.isAndroid) {
        apiKey = dotenv.env['REVENUECAT_API_KEY_ANDROID'] ?? '';
      } else {
        // For other platforms (Linux, Windows), we'll use web key as fallback
        apiKey = dotenv.env['REVENUECAT_API_KEY_WEB'] ?? '';
      }

      if (apiKey.isEmpty) {
        throw PaymentException('RevenueCat API key not found');
      }

      final configuration = PurchasesConfiguration(apiKey);
      await Purchases.configure(configuration);

      // Set user ID for RevenueCat
      await Purchases.logIn(userId);

      // Listen to purchase updates
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdate);

      _initialized = true;
    } catch (e) {
      throw PaymentException('Failed to initialize payments: $e');
    }
  }

  /// Handle customer info updates
  void _onCustomerInfoUpdate(CustomerInfo customerInfo) {
    // Handle entitlements and credits
    _syncCreditsFromPurchases(customerInfo);
  }

  /// Get available packages
  Future<List<Package>> getAvailablePackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        return offerings.current!.availablePackages;
      }
      return [];
    } catch (e) {
      throw PaymentException('Failed to fetch packages: $e');
    }
  }

  /// Purchase a credit package
  Future<bool> purchasePackage(Package package) async {
    try {
      // In RevenueCat SDK 9.x, purchase methods return PurchaseResult
      // Note: purchasePackage is deprecated in favor of purchase(PurchaseParams),
      // but we're using it for simplicity. The new API requires creating
      // PurchaseParams with package: PurchaseParams.package(package)
      // ignore: deprecated_member_use
      await Purchases.purchasePackage(package);

      // Grant credits immediately for consumable purchases
      await grantCreditsForPurchase(package.storeProduct.identifier);

      return true;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        // User cancelled
        return false;
      }
      throw PaymentException('Purchase failed: ${e.message}');
    } catch (e) {
      throw PaymentException('Purchase failed: $e');
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    try {
      // In RevenueCat SDK 9.x, restorePurchases still returns CustomerInfo
      final customerInfo = await Purchases.restorePurchases();
      await _syncCreditsFromPurchases(customerInfo);
    } catch (e) {
      throw PaymentException('Restore failed: $e');
    }
  }

  /// Sync credits from RevenueCat purchases
  ///
  /// This method adds credits based on active entitlements.
  /// For consumable credits (non-subscription model), you should instead
  /// listen to purchase events and grant credits immediately upon purchase.
  Future<void> _syncCreditsFromPurchases(CustomerInfo customerInfo) async {
    // For non-consumable/entitlement-based credits:
    // Calculate total credits from all active entitlements
    int totalCredits = 0;

    for (final entry in customerInfo.entitlements.active.entries) {
      final entitlement = entry.value;
      // Use centralized product ID to credits mapping
      final credits = CreditPackages.getCreditsForProductId(
        entitlement.productIdentifier,
      );
      totalCredits += credits;
    }

    if (totalCredits > 0) {
      // Add credits to database only
      await CreditsService().addCredits(totalCredits);
    }
  }

  /// Grant credits immediately after purchase (for consumable model)
  ///
  /// Call this after a successful purchase to add credits to the user's account.
  /// This is the preferred approach for consumable credit packages.
  Future<void> grantCreditsForPurchase(String productId) async {
    final credits = CreditPackages.getCreditsForProductId(productId);

    if (credits > 0) {
      // Add credits to database only
      await CreditsService().addCredits(credits);
    }
  }

  /// Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Logout from RevenueCat
  Future<void> logout() async {
    try {
      await Purchases.logOut();
      _initialized = false;
    } catch (e) {
      // Ignore logout errors
    }
  }
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
