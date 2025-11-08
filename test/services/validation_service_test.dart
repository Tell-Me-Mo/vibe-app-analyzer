import 'package:flutter_test/flutter_test.dart';
import 'package:vibecheck/services/validation_service.dart';

void main() {
  group('ValidationService', () {
    test('costPerValidation is 1 credit', () {
      expect(ValidationService.costPerValidation, 1);
    });
  });

  group('InsufficientCreditsException', () {
    test('creates exception with message', () {
      final exception = InsufficientCreditsException('Test message');

      expect(exception.message, 'Test message');
      expect(exception.toString(), 'Test message');
    });

    test('exception can be caught', () {
      expect(
        () => throw InsufficientCreditsException('Not enough credits'),
        throwsA(isA<InsufficientCreditsException>()),
      );
    });
  });
}
