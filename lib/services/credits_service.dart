import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

/// Service for managing user credits
class CreditsService {
  static final CreditsService _instance = CreditsService._internal();
  factory CreditsService() => _instance;
  CreditsService._internal();

  static const String _creditsKey = 'user_credits';
  static const String _hasSeenWelcomeKey = 'has_seen_welcome';
  static const int initialCredits = 10;
  static const int costPerAnalysis = 5;

  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get current credits (from local storage for guests, from profile for authenticated users)
  Future<int> getCredits() async {
    return _prefs.getInt(_creditsKey) ?? initialCredits;
  }

  /// Set credits
  Future<void> setCredits(int credits) async {
    await _prefs.setInt(_creditsKey, credits);
  }

  /// Add credits to user account
  Future<void> addCredits(int amount) async {
    final current = await getCredits();
    await setCredits(current + amount);
  }

  /// Consume credits for an analysis
  Future<bool> consumeCredits(int amount) async {
    final current = await getCredits();
    if (current >= amount) {
      await setCredits(current - amount);
      return true;
    }
    return false;
  }

  /// Check if user has enough credits
  Future<bool> hasEnoughCredits(int amount) async {
    final current = await getCredits();
    return current >= amount;
  }

  /// Check if user has seen the welcome popup
  Future<bool> hasSeenWelcome() async {
    return _prefs.getBool(_hasSeenWelcomeKey) ?? false;
  }

  /// Mark welcome popup as seen
  Future<void> markWelcomeAsSeen() async {
    await _prefs.setBool(_hasSeenWelcomeKey, true);
  }

  /// Reset credits (for testing or logout)
  Future<void> resetCredits() async {
    await _prefs.remove(_creditsKey);
    await _prefs.remove(_hasSeenWelcomeKey);
  }

  /// Sync credits from user profile (when user logs in)
  Future<void> syncFromProfile(UserProfile profile) async {
    await setCredits(profile.credits);
    await _prefs.setBool(_hasSeenWelcomeKey, profile.hasSeenWelcome);
  }
}

/// Provider for credits service
final creditsServiceProvider = Provider<CreditsService>((ref) {
  return CreditsService();
});

/// Provider for current credits count
final creditsProvider = StreamProvider<int>((ref) async* {
  final service = ref.watch(creditsServiceProvider);

  // Initial value
  yield await service.getCredits();

  // Listen to changes
  while (true) {
    await Future.delayed(const Duration(milliseconds: 500));
    yield await service.getCredits();
  }
});
