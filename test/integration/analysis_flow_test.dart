import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibecheck/services/credits_service.dart';

/// Integration test for the complete analysis flow with credits
void main() {
  late CreditsService creditsService;

  setUp(() async {
    // Reset shared preferences
    SharedPreferences.setMockInitialValues({});
    creditsService = CreditsService();
    await creditsService.initialize();
  });

  group('Analysis Flow Integration', () {
    test('Complete user journey: 10 credits -> 2 analyses -> out of credits',
        () async {
      // STEP 1: User starts with 10 free credits
      final initialCredits = await creditsService.getCredits();
      expect(initialCredits, equals(10));

      // STEP 2: User performs first analysis (costs 5 credits)
      final canAnalyze1 = await creditsService.hasEnoughCredits(5);
      expect(canAnalyze1, isTrue);

      final consumed1 = await creditsService.consumeCredits(5);
      expect(consumed1, isTrue);

      final creditsAfterFirst = await creditsService.getCredits();
      expect(creditsAfterFirst, equals(5));

      // STEP 3: User performs second analysis (costs 5 credits)
      final canAnalyze2 = await creditsService.hasEnoughCredits(5);
      expect(canAnalyze2, isTrue);

      final consumed2 = await creditsService.consumeCredits(5);
      expect(consumed2, isTrue);

      final creditsAfterSecond = await creditsService.getCredits();
      expect(creditsAfterSecond, equals(0));

      // STEP 4: User tries third analysis (insufficient credits)
      final canAnalyze3 = await creditsService.hasEnoughCredits(5);
      expect(canAnalyze3, isFalse);

      final consumed3 = await creditsService.consumeCredits(5);
      expect(consumed3, isFalse);

      final finalCredits = await creditsService.getCredits();
      expect(finalCredits, equals(0)); // Credits unchanged
    });

    test('Purchase credits and continue analyzing', () async {
      // User runs out of credits
      await creditsService.setCredits(0);
      expect(await creditsService.hasEnoughCredits(5), isFalse);

      // User purchases Starter Pack (20 credits)
      await creditsService.addCredits(20);
      expect(await creditsService.getCredits(), equals(20));

      // User can now analyze again
      expect(await creditsService.hasEnoughCredits(5), isTrue);

      // Perform 4 analyses with purchased credits
      for (int i = 0; i < 4; i++) {
        final success = await creditsService.consumeCredits(5);
        expect(success, isTrue);
      }

      final remainingCredits = await creditsService.getCredits();
      expect(remainingCredits, equals(0));
    });

    test('Credits refund on analysis failure scenario', () async {
      await creditsService.setCredits(10);

      // Analysis starts - credits consumed
      await creditsService.consumeCredits(5);
      expect(await creditsService.getCredits(), equals(5));

      // Simulate analysis failure - credits refunded
      await creditsService.addCredits(5);
      expect(await creditsService.getCredits(), equals(10));
    });

    test('Welcome flow: first launch to first analysis', () async {
      // First launch
      expect(await creditsService.hasSeenWelcome(), isFalse);
      expect(await creditsService.getCredits(), equals(10));

      // User sees welcome popup
      await creditsService.markWelcomeAsSeen();
      expect(await creditsService.hasSeenWelcome(), isTrue);

      // User performs first analysis
      final canAnalyze = await creditsService.hasEnoughCredits(5);
      expect(canAnalyze, isTrue);

      await creditsService.consumeCredits(5);
      expect(await creditsService.getCredits(), equals(5));
    });
  });

  group('Edge Cases', () {
    test('Attempting to consume more credits than available', () async {
      await creditsService.setCredits(3);

      final success = await creditsService.consumeCredits(5);
      expect(success, isFalse);

      // Credits should remain unchanged
      expect(await creditsService.getCredits(), equals(3));
    });

    test('Multiple credit operations in sequence', () async {
      await creditsService.setCredits(0);

      // Add credits multiple times
      await creditsService.addCredits(10);
      await creditsService.addCredits(20);
      await creditsService.addCredits(30);

      expect(await creditsService.getCredits(), equals(60));

      // Consume credits multiple times
      await creditsService.consumeCredits(5);
      await creditsService.consumeCredits(10);
      await creditsService.consumeCredits(15);

      expect(await creditsService.getCredits(), equals(30));
    });

    test('Zero credits edge case', () async {
      await creditsService.setCredits(0);

      expect(await creditsService.hasEnoughCredits(0), isTrue);
      expect(await creditsService.hasEnoughCredits(1), isFalse);

      final success = await creditsService.consumeCredits(0);
      expect(success, isTrue); // Consuming 0 credits succeeds
    });

    test('Large credit amounts', () async {
      // User purchases multiple enterprise packages
      await creditsService.setCredits(0);
      await creditsService.addCredits(300); // Enterprise pack
      await creditsService.addCredits(300); // Another one
      await creditsService.addCredits(300); // And another

      expect(await creditsService.getCredits(), equals(900));

      // Perform 180 analyses (900 / 5)
      for (int i = 0; i < 180; i++) {
        final success = await creditsService.consumeCredits(5);
        expect(success, isTrue);
      }

      expect(await creditsService.getCredits(), equals(0));
    });
  });
}
