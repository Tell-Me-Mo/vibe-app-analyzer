import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibecheck/services/credits_service.dart';

void main() {
  late CreditsService creditsService;

  setUp(() async {
    // Initialize with in-memory shared preferences
    SharedPreferences.setMockInitialValues({});
    creditsService = CreditsService();
    await creditsService.initialize();
  });

  group('CreditsService - Initial State', () {
    test('should return initial credits (10) on first use', () async {
      final credits = await creditsService.getCredits();
      expect(credits, equals(10));
    });

    test('should return false for hasSeenWelcome on first use', () async {
      final hasSeenWelcome = await creditsService.hasSeenWelcome();
      expect(hasSeenWelcome, isFalse);
    });
  });

  group('CreditsService - Credit Management', () {
    test('should set and get credits correctly', () async {
      await creditsService.setCredits(25);
      final credits = await creditsService.getCredits();
      expect(credits, equals(25));
    });

    test('should add credits correctly', () async {
      await creditsService.setCredits(10);
      await creditsService.addCredits(50);
      final credits = await creditsService.getCredits();
      expect(credits, equals(60));
    });

    test('should consume credits when enough available', () async {
      await creditsService.setCredits(10);
      final success = await creditsService.consumeCredits(5);

      expect(success, isTrue);
      final remainingCredits = await creditsService.getCredits();
      expect(remainingCredits, equals(5));
    });

    test('should not consume credits when insufficient', () async {
      await creditsService.setCredits(3);
      final success = await creditsService.consumeCredits(5);

      expect(success, isFalse);
      final remainingCredits = await creditsService.getCredits();
      expect(remainingCredits, equals(3)); // Should remain unchanged
    });

    test('should check if enough credits available', () async {
      await creditsService.setCredits(10);

      expect(await creditsService.hasEnoughCredits(5), isTrue);
      expect(await creditsService.hasEnoughCredits(10), isTrue);
      expect(await creditsService.hasEnoughCredits(15), isFalse);
    });
  });

  group('CreditsService - Welcome State', () {
    test('should mark welcome as seen', () async {
      await creditsService.markWelcomeAsSeen();
      final hasSeenWelcome = await creditsService.hasSeenWelcome();
      expect(hasSeenWelcome, isTrue);
    });
  });

  group('CreditsService - Reset', () {
    test('should reset credits to initial state', () async {
      await creditsService.setCredits(100);
      await creditsService.markWelcomeAsSeen();

      await creditsService.resetCredits();

      final credits = await creditsService.getCredits();
      final hasSeenWelcome = await creditsService.hasSeenWelcome();

      expect(credits, equals(10)); // Back to initial
      expect(hasSeenWelcome, isFalse);
    });
  });

  group('CreditsService - Analysis Cost', () {
    test('should consume correct amount per analysis (5 credits)', () async {
      await creditsService.setCredits(10);

      // First analysis
      await creditsService.consumeCredits(CreditsService.costPerAnalysis);
      expect(await creditsService.getCredits(), equals(5));

      // Second analysis
      await creditsService.consumeCredits(CreditsService.costPerAnalysis);
      expect(await creditsService.getCredits(), equals(0));

      // Third analysis should fail
      final canAnalyze = await creditsService.consumeCredits(
        CreditsService.costPerAnalysis,
      );
      expect(canAnalyze, isFalse);
      expect(await creditsService.getCredits(), equals(0));
    });
  });
}
