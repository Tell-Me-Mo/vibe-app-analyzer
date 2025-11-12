import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing user credits using Supabase database only
/// No local storage - single source of truth
class CreditsService {
  static final CreditsService _instance = CreditsService._internal();
  factory CreditsService() => _instance;
  CreditsService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  static const int initialCredits = 10;
  static const int costPerAnalysis = 5;

  /// Get current user ID
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUserId != null;

  /// Get current credits from database
  /// Returns 0 if user is not authenticated or profile doesn't exist
  Future<int> getCredits() async {
    if (!isAuthenticated) {
      debugPrint('⚠️ [CREDITS SERVICE] User not authenticated, returning 0 credits');
      return 0;
    }

    try {
      final response = await _supabase
          .from('profiles')
          .select('credits')
          .eq('id', _currentUserId!)
          .single();

      final credits = response['credits'] as int? ?? initialCredits;
      debugPrint('✅ [CREDITS SERVICE] Fetched credits from DB: $credits');
      return credits;
    } catch (e) {
      debugPrint('❌ [CREDITS SERVICE] Error fetching credits: $e');
      return 0;
    }
  }

  /// Set credits in database
  Future<void> setCredits(int credits) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to set credits');
    }

    try {
      await _supabase.from('profiles').update({
        'credits': credits,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', _currentUserId!);

      debugPrint('✅ [CREDITS SERVICE] Updated credits in DB: $credits');
    } catch (e) {
      debugPrint('❌ [CREDITS SERVICE] Error setting credits: $e');
      rethrow;
    }
  }

  /// Add credits to user account
  Future<void> addCredits(int amount) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to add credits');
    }

    try {
      // Use atomic database operation to prevent race conditions
      await _supabase.rpc('add_credits', params: {
        'user_id': _currentUserId!,
        'amount': amount,
      });

      debugPrint('✅ [CREDITS SERVICE] Added $amount credits via RPC');
    } catch (e) {
      debugPrint('❌ [CREDITS SERVICE] Error adding credits: $e');
      // Fallback to manual update if RPC doesn't exist
      final current = await getCredits();
      await setCredits(current + amount);
    }
  }

  /// Consume credits for an analysis
  /// Returns true if successful, false if insufficient credits
  Future<bool> consumeCredits(int amount) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to consume credits');
    }

    try {
      // Use atomic database operation to prevent race conditions
      final result = await _supabase.rpc('consume_credits', params: {
        'user_id': _currentUserId!,
        'amount': amount,
      });

      final success = result as bool? ?? false;
      debugPrint(success
          ? '✅ [CREDITS SERVICE] Consumed $amount credits via RPC'
          : '⚠️ [CREDITS SERVICE] Insufficient credits to consume $amount');
      return success;
    } catch (e) {
      debugPrint('❌ [CREDITS SERVICE] Error consuming credits: $e');
      // Fallback to manual check and update
      final current = await getCredits();
      if (current >= amount) {
        await setCredits(current - amount);
        return true;
      }
      return false;
    }
  }

  /// Refund credits (e.g., when analysis fails)
  Future<void> refundCredits(int amount) async {
    await addCredits(amount);
  }

  /// Check if user has enough credits
  Future<bool> hasEnoughCredits(int amount) async {
    final current = await getCredits();
    return current >= amount;
  }

  /// Check if user has seen the welcome popup
  Future<bool> hasSeenWelcome() async {
    if (!isAuthenticated) {
      return false;
    }

    try {
      final response = await _supabase
          .from('profiles')
          .select('has_seen_welcome')
          .eq('id', _currentUserId!)
          .single();

      return response['has_seen_welcome'] as bool? ?? false;
    } catch (e) {
      debugPrint('❌ [CREDITS SERVICE] Error fetching has_seen_welcome: $e');
      return false;
    }
  }

  /// Mark welcome popup as seen
  Future<void> markWelcomeAsSeen() async {
    if (!isAuthenticated) {
      return;
    }

    try {
      await _supabase.from('profiles').update({
        'has_seen_welcome': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', _currentUserId!);

      debugPrint('✅ [CREDITS SERVICE] Marked welcome as seen');
    } catch (e) {
      debugPrint('❌ [CREDITS SERVICE] Error marking welcome as seen: $e');
    }
  }

  /// Get credits as a stream for real-time updates
  Stream<int> watchCredits() {
    if (!isAuthenticated) {
      return Stream.value(0);
    }

    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', _currentUserId!)
        .map((data) {
          if (data.isEmpty) return 0;
          final credits = data.first['credits'] as int? ?? 0;
          debugPrint('🔄 [CREDITS SERVICE] Stream update: $credits credits');
          return credits;
        });
  }
}

/// Provider for credits service
final creditsServiceProvider = Provider<CreditsService>((ref) {
  return CreditsService();
});

/// Provider for current credits count using real-time database stream
final creditsProvider = StreamProvider<int>((ref) async* {
  final service = ref.watch(creditsServiceProvider);

  debugPrint('🟢 [CREDITS PROVIDER] Initializing creditsProvider with database stream');

  // If not authenticated, emit 0
  if (!service.isAuthenticated) {
    debugPrint('⚠️ [CREDITS PROVIDER] User not authenticated, emitting 0');
    yield 0;
    return;
  }

  // Get initial value
  final initialCredits = await service.getCredits();
  debugPrint('🟢 [CREDITS PROVIDER] ✅ Initial credits: $initialCredits, emitting');
  yield initialCredits;

  // Watch for real-time updates from database
  await for (final credits in service.watchCredits()) {
    debugPrint('🟢 [CREDITS PROVIDER] ✅ Credits changed to: $credits, emitting');
    yield credits;
  }
});
