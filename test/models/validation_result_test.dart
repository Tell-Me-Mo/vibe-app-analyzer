import 'package:flutter_test/flutter_test.dart';
import 'package:vibecheck/models/validation_result.dart';
import 'package:vibecheck/models/validation_status.dart';

void main() {
  group('ValidationResult', () {
    test('creates instance with all fields', () {
      final timestamp = DateTime.now();
      final result = ValidationResult(
        id: 'test-id',
        status: ValidationStatus.passed,
        timestamp: timestamp,
        summary: 'Test summary',
        details: 'Test details',
        remainingIssues: ['Issue 1', 'Issue 2'],
        recommendation: 'Test recommendation',
      );

      expect(result.id, 'test-id');
      expect(result.status, ValidationStatus.passed);
      expect(result.timestamp, timestamp);
      expect(result.summary, 'Test summary');
      expect(result.details, 'Test details');
      expect(result.remainingIssues, ['Issue 1', 'Issue 2']);
      expect(result.recommendation, 'Test recommendation');
    });

    test('creates instance with optional fields as null', () {
      final timestamp = DateTime.now();
      final result = ValidationResult(
        id: 'test-id',
        status: ValidationStatus.passed,
        timestamp: timestamp,
      );

      expect(result.summary, isNull);
      expect(result.details, isNull);
      expect(result.remainingIssues, isNull);
      expect(result.recommendation, isNull);
    });

    group('JSON serialization', () {
      test('toJson converts to map correctly - passed status', () {
        final timestamp = DateTime(2025, 1, 1, 12, 0, 0);
        final result = ValidationResult(
          id: 'test-id',
          status: ValidationStatus.passed,
          timestamp: timestamp,
          summary: 'Validation passed',
          details: 'All checks passed',
        );

        final json = result.toJson();

        expect(json['id'], 'test-id');
        expect(json['status'], 'passed');
        expect(json['timestamp'], timestamp.toIso8601String());
        expect(json['summary'], 'Validation passed');
        expect(json['details'], 'All checks passed');
        expect(json['remainingIssues'], isNull);
        expect(json['recommendation'], isNull);
      });

      test('toJson converts to map correctly - failed status', () {
        final timestamp = DateTime(2025, 1, 1, 12, 0, 0);
        final result = ValidationResult(
          id: 'test-id',
          status: ValidationStatus.failed,
          timestamp: timestamp,
          summary: 'Validation failed',
          remainingIssues: ['Issue 1', 'Issue 2'],
          recommendation: 'Fix these issues',
        );

        final json = result.toJson();

        expect(json['status'], 'failed');
        expect(json['remainingIssues'], ['Issue 1', 'Issue 2']);
        expect(json['recommendation'], 'Fix these issues');
      });

      test('fromJson creates instance from map', () {
        final json = {
          'id': 'test-id',
          'status': 'passed',
          'timestamp': '2025-01-01T12:00:00.000',
          'summary': 'Test summary',
          'details': 'Test details',
        };

        final result = ValidationResult.fromJson(json);

        expect(result.id, 'test-id');
        expect(result.status, ValidationStatus.passed);
        expect(result.summary, 'Test summary');
        expect(result.details, 'Test details');
      });

      test('fromJson handles all status values', () {
        final statuses = [
          ('passed', ValidationStatus.passed),
          ('failed', ValidationStatus.failed),
          ('validating', ValidationStatus.validating),
          ('notStarted', ValidationStatus.notStarted),
          ('error', ValidationStatus.error),
        ];

        for (final (statusStr, expectedStatus) in statuses) {
          final json = {
            'id': 'test',
            'status': statusStr,
            'timestamp': '2025-01-01T12:00:00.000',
          };

          final result = ValidationResult.fromJson(json);
          expect(result.status, expectedStatus,
              reason: 'Status $statusStr should map to $expectedStatus');
        }
      });

      test('round-trip serialization preserves data', () {
        final original = ValidationResult(
          id: 'test-id',
          status: ValidationStatus.failed,
          timestamp: DateTime(2025, 1, 1, 12, 0, 0),
          summary: 'Test',
          details: 'Details',
          remainingIssues: ['Issue'],
          recommendation: 'Rec',
        );

        final json = original.toJson();
        final restored = ValidationResult.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.status, original.status);
        expect(restored.summary, original.summary);
        expect(restored.details, original.details);
        expect(restored.remainingIssues, original.remainingIssues);
        expect(restored.recommendation, original.recommendation);
      });
    });
  });

  group('ValidationStatus extension', () {
    test('displayName returns correct values', () {
      expect(ValidationStatus.notStarted.displayName, 'Not Validated');
      expect(ValidationStatus.validating.displayName, 'Validating...');
      expect(ValidationStatus.passed.displayName, 'Fix Validated');
      expect(ValidationStatus.failed.displayName, 'Fix Failed');
      expect(ValidationStatus.error.displayName, 'Validation Error');
    });

    test('icon returns correct emoji', () {
      expect(ValidationStatus.notStarted.icon, '⚪');
      expect(ValidationStatus.validating.icon, '🔄');
      expect(ValidationStatus.passed.icon, '✅');
      expect(ValidationStatus.failed.icon, '❌');
      expect(ValidationStatus.error.icon, '⚠️');
    });
  });
}
