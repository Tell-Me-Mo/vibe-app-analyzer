import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibecheck/models/security_issue.dart';
import 'package:vibecheck/models/severity.dart';
import 'package:vibecheck/models/validation_status.dart';
import 'package:vibecheck/models/validation_result.dart';

void main() {
  group('SecurityIssue with validation fields', () {
    test('creates instance with default validation status', () {
      final issue = SecurityIssue(
        id: 'test-id',
        title: 'Test Issue',
        category: 'Test',
        severity: Severity.high,
        description: 'Description',
        aiGenerationRisk: 'Risk',
        claudeCodePrompt: 'Prompt',
      );

      expect(issue.validationStatus, ValidationStatus.notStarted);
      expect(issue.validationResult, isNull);
    });

    test('creates instance with validation result', () {
      final validationResult = ValidationResult(
        id: 'val-id',
        status: ValidationStatus.passed,
        timestamp: DateTime.now(),
        summary: 'Passed',
      );

      final issue = SecurityIssue(
        id: 'test-id',
        title: 'Test Issue',
        category: 'Test',
        severity: Severity.high,
        description: 'Description',
        aiGenerationRisk: 'Risk',
        claudeCodePrompt: 'Prompt',
        validationStatus: ValidationStatus.passed,
        validationResult: validationResult,
      );

      expect(issue.validationStatus, ValidationStatus.passed);
      expect(issue.validationResult, validationResult);
    });

    test('copyWith updates validation status', () {
      final original = SecurityIssue(
        id: 'test-id',
        title: 'Test Issue',
        category: 'Test',
        severity: Severity.high,
        description: 'Description',
        aiGenerationRisk: 'Risk',
        claudeCodePrompt: 'Prompt',
      );

      final updated = original.copyWith(
        validationStatus: ValidationStatus.passed,
      );

      expect(updated.validationStatus, ValidationStatus.passed);
      expect(updated.id, original.id); // Other fields unchanged
      expect(updated.title, original.title);
    });

    test('copyWith updates validation result', () {
      final original = SecurityIssue(
        id: 'test-id',
        title: 'Test Issue',
        category: 'Test',
        severity: Severity.high,
        description: 'Description',
        aiGenerationRisk: 'Risk',
        claudeCodePrompt: 'Prompt',
      );

      final validationResult = ValidationResult(
        id: 'val-id',
        status: ValidationStatus.passed,
        timestamp: DateTime.now(),
      );

      final updated = original.copyWith(
        validationResult: validationResult,
      );

      expect(updated.validationResult, validationResult);
    });

    group('JSON serialization with validation', () {
      test('fromJson parses validation fields', () {
        final json = {
          'id': 'test-id',
          'title': 'Test Issue',
          'category': 'Test',
          'severity': 'high',
          'description': 'Description',
          'aiGenerationRisk': 'Risk',
          'claudeCodePrompt': 'Prompt',
          'validationStatus': 'passed',
          'validationResult': {
            'id': 'val-id',
            'status': 'passed',
            'timestamp': '2025-01-01T00:00:00.000',
            'summary': 'Test',
          },
        };

        final issue = SecurityIssue.fromJson(json);

        expect(issue.validationStatus, ValidationStatus.passed);
        expect(issue.validationResult, isNotNull);
        expect(issue.validationResult!.id, 'val-id');
        expect(issue.validationResult!.status, ValidationStatus.passed);
      });

      test('fromJson handles missing validation fields', () {
        final json = {
          'id': 'test-id',
          'title': 'Test Issue',
          'category': 'Test',
          'severity': 'high',
          'description': 'Description',
          'aiGenerationRisk': 'Risk',
          'claudeCodePrompt': 'Prompt',
        };

        final issue = SecurityIssue.fromJson(json);

        expect(issue.validationStatus, ValidationStatus.notStarted);
        expect(issue.validationResult, isNull);
      });

      test('round-trip serialization preserves validation data', () {
        final validationResult = ValidationResult(
          id: 'val-id',
          status: ValidationStatus.failed,
          timestamp: DateTime(2025, 1, 1, 12, 0, 0),
          summary: 'Failed',
          remainingIssues: ['Issue 1'],
        );

        final original = SecurityIssue(
          id: 'test-id',
          title: 'Test Issue',
          category: 'Test',
          severity: Severity.high,
          description: 'Description',
          aiGenerationRisk: 'Risk',
          claudeCodePrompt: 'Prompt',
          validationStatus: ValidationStatus.failed,
          validationResult: validationResult,
        );

        // Convert to JSON string and back to simulate real storage
        final jsonMap = original.toJson();
        final jsonString = jsonEncode(jsonMap);
        final restoredMap = jsonDecode(jsonString) as Map<String, dynamic>;
        final restored = SecurityIssue.fromJson(restoredMap);

        expect(restored.validationStatus, original.validationStatus);
        expect(restored.validationResult!.id, original.validationResult!.id);
        expect(restored.validationResult!.status,
            original.validationResult!.status);
        expect(restored.validationResult!.remainingIssues,
            original.validationResult!.remainingIssues);
      });
    });
  });
}
