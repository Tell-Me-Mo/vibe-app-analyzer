import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Service for tracking analytics events throughout the app
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Get the FirebaseAnalytics instance for direct access if needed
  FirebaseAnalytics get analytics => _analytics;

  /// Get an analytics observer for navigation tracking
  FirebaseAnalyticsObserver get analyticsObserver {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  /// Log a custom event with optional parameters
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) async {
    try {
      // Filter out null values to match Firebase's Map<String, Object> requirement
      final filteredParams = parameters?.map((key, value) {
        return MapEntry(key, value ?? 'null');
      });

      await _analytics.logEvent(name: name, parameters: filteredParams);
      debugPrint(
        'Analytics Event: $name${parameters != null ? ' - $parameters' : ''}',
      );
    } catch (e) {
      debugPrint('Failed to log analytics event: $e');
    }
  }

  /// Log screen view event
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      debugPrint('Analytics Screen View: $screenName');
    } catch (e) {
      debugPrint('Failed to log screen view: $e');
    }
  }

  /// Log app open event
  Future<void> logAppOpen() async {
    await logEvent(name: 'app_open');
  }

  /// Log code analysis started
  Future<void> logAnalysisStarted({
    required String codeType,
    int? codeLength,
  }) async {
    await logEvent(
      name: 'analysis_started',
      parameters: {
        'code_type': codeType,
        if (codeLength != null) 'code_length': codeLength,
      },
    );
  }

  /// Log code analysis completed
  Future<void> logAnalysisCompleted({
    required String codeType,
    int? issuesFound,
    int? durationMs,
  }) async {
    await logEvent(
      name: 'analysis_completed',
      parameters: {
        'code_type': codeType,
        if (issuesFound != null) 'issues_found': issuesFound,
        if (durationMs != null) 'duration_ms': durationMs,
      },
    );
  }

  /// Log user authentication
  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  /// Log user sign up
  Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  /// Log search event
  Future<void> logSearch({required String searchTerm}) async {
    await _analytics.logSearch(searchTerm: searchTerm);
  }

  /// Log share event
  Future<void> logShare({
    required String contentType,
    required String itemId,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: 'app_share',
    );
  }

  /// Log purchase event (Firebase standard event for ecommerce)
  Future<void> logPurchase({
    required String transactionId,
    required String currency,
    required double value,
    String? coupon,
  }) async {
    try {
      await _analytics.logPurchase(
        currency: currency,
        value: value,
        transactionId: transactionId,
        coupon: coupon,
      );
      debugPrint('Analytics Purchase: $value $currency (ID: $transactionId)');
    } catch (e) {
      debugPrint('Failed to log purchase: $e');
    }
  }

  /// Log begin checkout event
  Future<void> logBeginCheckout({
    required double value,
    required String currency,
    String? coupon,
  }) async {
    try {
      await _analytics.logBeginCheckout(
        value: value,
        currency: currency,
        coupon: coupon,
      );
      debugPrint('Analytics Begin Checkout: $value $currency');
    } catch (e) {
      debugPrint('Failed to log begin checkout: $e');
    }
  }

  /// Set user ID for analytics
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
      debugPrint('Analytics User ID set: $userId');
    } catch (e) {
      debugPrint('Failed to set user ID: $e');
    }
  }

  /// Set user property
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      debugPrint('Analytics User Property: $name = $value');
    } catch (e) {
      debugPrint('Failed to set user property: $e');
    }
  }

  /// Enable or disable analytics collection
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
      debugPrint('Analytics Collection: ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('Failed to set analytics collection: $e');
    }
  }

  /// Log user feedback (thumbs up/down)
  Future<void> logFeedback({
    required String resultId,
    required bool isPositive,
    String? feedbackText,
  }) async {
    await logEvent(
      name: 'analysis_feedback',
      parameters: {
        'result_id': resultId,
        'is_positive': isPositive ? 1 : 0,
        if (feedbackText != null) 'feedback_text': feedbackText,
      },
    );
  }
}
