import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import 'auth_service.dart';
import 'credits_service.dart';

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
      final customerInfo = await Purchases.purchasePackage(package);

      // Sync credits after successful purchase
      await _syncCreditsFromPurchases(customerInfo);

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
      final customerInfo = await Purchases.restorePurchases();
      await _syncCreditsFromPurchases(customerInfo);
    } catch (e) {
      throw PaymentException('Restore failed: $e');
    }
  }

  /// Sync credits from RevenueCat purchases
  Future<void> _syncCreditsFromPurchases(CustomerInfo customerInfo) async {
    // Calculate total credits from all purchases
    int totalCredits = 0;

    // You would implement your own logic here to map purchases to credits
    // For now, we'll check for active entitlements
    for (final entry in customerInfo.entitlements.active.entries) {
      final entitlement = entry.value;
      // Parse credits from product identifier
      final credits = _parseCreditsFromProductId(entitlement.productIdentifier);
      totalCredits += credits;
    }

    if (totalCredits > 0) {
      // Update credits in both local storage and database
      await CreditsService().addCredits(totalCredits);
      final authService = AuthService();
      if (authService.isSignedIn) {
        final currentCredits = await CreditsService().getCredits();
        await authService.updateCredits(currentCredits);
      }
    }
  }

  /// Parse credits from product identifier
  int _parseCreditsFromProductId(String productId) {
    // Map product IDs to credit amounts
    // This should match your RevenueCat product configuration
    if (productId.contains('starter')) return 20;
    if (productId.contains('popular')) return 50;
    if (productId.contains('professional')) return 120;
    if (productId.contains('enterprise')) return 300;
    return 0;
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
