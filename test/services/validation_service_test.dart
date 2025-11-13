import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:vibecheck/services/validation_service.dart';
import 'package:vibecheck/services/credits_service.dart';
import 'package:vibecheck/services/github_service.dart';
import 'package:vibecheck/services/openai_service.dart';
import 'package:vibecheck/models/security_issue.dart';
import 'package:vibecheck/models/monitoring_recommendation.dart';
import 'package:vibecheck/models/validation_result.dart';
import 'package:vibecheck/models/validation_status.dart';
import 'package:vibecheck/models/analysis_mode.dart';
import 'package:vibecheck/models/severity.dart';

@GenerateMocks([CreditsService, GitHubService, OpenAIService])
import 'validation_service_test.mocks.dart';

void main() {
  group('ValidationService', () {
    late MockCreditsService mockCreditsService;
    late MockGitHubService mockGitHubService;
    late MockOpenAIService mockOpenAIService;
    late ValidationService validationService;

    setUp(() {
      mockCreditsService = MockCreditsService();
      mockGitHubService = MockGitHubService();
      mockOpenAIService = MockOpenAIService();
      validationService = ValidationService(
        creditsService: mockCreditsService,
        githubService: mockGitHubService,
        openaiService: mockOpenAIService,
      );
    });

    test('costPerValidation is 1 credit', () {
      expect(ValidationService.costPerValidation, 1);
    });

    group('validateSecurityFix', () {
      final testIssue = SecurityIssue(
        id: 'test-issue-1',
        title: 'Test Security Issue',
        category: 'security',
        severity: Severity.high,
        description: 'Test description',
        aiGenerationRisk: 'Developers may overlook this security issue',
        claudeCodePrompt: 'Fix the security vulnerability',
        filePath: 'lib/test.dart',
        lineNumber: 42,
      );

      final mockValidationResult = ValidationResult(
        id: 'val-1',
        status: ValidationStatus.passed,
        timestamp: DateTime.now(),
        summary: 'Validation passed',
        details: 'All checks passed',
      );

      test('should skip GitHub fetch for runtime analysis mode', () async {
        // Arrange
        when(mockCreditsService.hasEnoughCredits(any)).thenAnswer((_) async => true);
        when(mockOpenAIService.validateSecurityFix(
          issue: anyNamed('issue'),
          updatedCode: anyNamed('updatedCode'),
          repositoryName: anyNamed('repositoryName'),
        )).thenAnswer((_) async => mockValidationResult);

        // Act
        final result = await validationService.validateSecurityFix(
          issue: testIssue,
          repositoryUrl: 'https://example.com',
          repositoryName: 'example.com',
          analysisMode: AnalysisMode.runtime,
        );

        // Assert
        expect(result.validationStatus, ValidationStatus.passed);

        // Verify GitHub service was NOT called for runtime mode
        verifyNever(mockGitHubService.getFileContent(any, any));
        verifyNever(mockGitHubService.getRepositoryTree(any));

        // Verify OpenAI was called with empty code
        verify(mockOpenAIService.validateSecurityFix(
          issue: testIssue,
          updatedCode: '', // Empty for runtime mode
          repositoryName: 'example.com',
        )).called(1);
      });

      test('should fetch code from GitHub for static code analysis mode', () async {
        // Arrange
        when(mockCreditsService.hasEnoughCredits(any)).thenAnswer((_) async => true);
        when(mockGitHubService.getFileContent(any, any))
            .thenAnswer((_) async => 'const testCode = "fixed";');
        when(mockOpenAIService.validateSecurityFix(
          issue: anyNamed('issue'),
          updatedCode: anyNamed('updatedCode'),
          repositoryName: anyNamed('repositoryName'),
        )).thenAnswer((_) async => mockValidationResult);

        // Act
        final result = await validationService.validateSecurityFix(
          issue: testIssue,
          repositoryUrl: 'https://github.com/user/repo',
          repositoryName: 'repo',
          analysisMode: AnalysisMode.staticCode,
        );

        // Assert
        expect(result.validationStatus, ValidationStatus.passed);

        // Verify GitHub service WAS called for static mode
        verify(mockGitHubService.getFileContent(
          'https://github.com/user/repo',
          'lib/test.dart',
        )).called(1);

        // Verify OpenAI was called with fetched code
        verify(mockOpenAIService.validateSecurityFix(
          issue: testIssue,
          updatedCode: argThat(isNotEmpty, named: 'updatedCode'),
          repositoryName: 'repo',
        )).called(1);
      });

      test('should handle GitHub fetch errors gracefully for static mode', () async {
        // Arrange
        when(mockCreditsService.hasEnoughCredits(any)).thenAnswer((_) async => true);
        when(mockGitHubService.getFileContent(any, any))
            .thenThrow(Exception('Invalid GitHub URL'));
        // Mock getRepositoryTree as well (fallback in validation service)
        when(mockGitHubService.getRepositoryTree(any))
            .thenThrow(Exception('Invalid GitHub URL'));

        // Act
        final result = await validationService.validateSecurityFix(
          issue: testIssue,
          repositoryUrl: 'https://invalid-url.com',
          repositoryName: 'invalid',
          analysisMode: AnalysisMode.staticCode,
        );

        // Assert
        expect(result.validationStatus, ValidationStatus.error);
        expect(result.validationResult?.details, contains('Invalid GitHub URL'));
      });
    });

    group('validateMonitoringImplementation', () {
      final testRecommendation = MonitoringRecommendation(
        id: 'rec-1',
        title: 'Test Monitoring',
        category: 'analytics',
        severity: Severity.medium,
        description: 'Add analytics',
        businessValue: 'Track user behavior',
        claudeCodePrompt: 'Implement analytics tracking',
      );

      final mockValidationResult = ValidationResult(
        id: 'val-2',
        status: ValidationStatus.passed,
        timestamp: DateTime.now(),
        summary: 'Monitoring implemented',
        details: 'Analytics properly configured',
      );

      test('should skip GitHub fetch for runtime analysis mode', () async {
        // Arrange
        when(mockCreditsService.hasEnoughCredits(any)).thenAnswer((_) async => true);
        when(mockOpenAIService.validateMonitoringImplementation(
          recommendation: anyNamed('recommendation'),
          updatedCode: anyNamed('updatedCode'),
          repositoryName: anyNamed('repositoryName'),
        )).thenAnswer((_) async => mockValidationResult);

        // Act
        final result = await validationService.validateMonitoringImplementation(
          recommendation: testRecommendation,
          repositoryUrl: 'https://myapp.com',
          repositoryName: 'myapp.com',
          analysisMode: AnalysisMode.runtime,
        );

        // Assert
        expect(result.validationStatus, ValidationStatus.passed);

        // Verify GitHub service was NOT called
        verifyNever(mockGitHubService.getFileContent(any, any));

        // Verify OpenAI was called with empty code
        verify(mockOpenAIService.validateMonitoringImplementation(
          recommendation: testRecommendation,
          updatedCode: '', // Empty for runtime mode
          repositoryName: 'myapp.com',
        )).called(1);
      });

      test('should fetch code from GitHub for static code analysis mode', () async {
        // Arrange
        when(mockCreditsService.hasEnoughCredits(any)).thenAnswer((_) async => true);
        // Mock getRepositoryTree for the fallback scenario
        when(mockGitHubService.getRepositoryTree(any)).thenAnswer((_) async => [
          {'path': 'lib/analytics.dart', 'type': 'blob'},
        ]);
        when(mockGitHubService.getFileContent(any, any))
            .thenAnswer((_) async => 'analytics.track("event");');
        when(mockOpenAIService.validateMonitoringImplementation(
          recommendation: anyNamed('recommendation'),
          updatedCode: anyNamed('updatedCode'),
          repositoryName: anyNamed('repositoryName'),
        )).thenAnswer((_) async => mockValidationResult);

        // Act
        final result = await validationService.validateMonitoringImplementation(
          recommendation: testRecommendation,
          repositoryUrl: 'https://github.com/user/repo',
          repositoryName: 'repo',
          analysisMode: AnalysisMode.staticCode,
        );

        // Assert
        expect(result.validationStatus, ValidationStatus.passed);

        // Verify OpenAI was called with fetched code
        verify(mockOpenAIService.validateMonitoringImplementation(
          recommendation: testRecommendation,
          updatedCode: argThat(isNotEmpty, named: 'updatedCode'),
          repositoryName: 'repo',
        )).called(1);
      });
    });

    group('Credit Management', () {
      test('canValidate returns true when sufficient credits', () async {
        when(mockCreditsService.hasEnoughCredits(1)).thenAnswer((_) async => true);

        final canValidate = await validationService.canValidate();

        expect(canValidate, true);
      });

      test('canValidate returns false when insufficient credits', () async {
        when(mockCreditsService.hasEnoughCredits(1)).thenAnswer((_) async => false);

        final canValidate = await validationService.canValidate();

        expect(canValidate, false);
      });

      test('getCredits returns current balance', () async {
        when(mockCreditsService.getCredits()).thenAnswer((_) async => 42);

        final credits = await validationService.getCredits();

        expect(credits, 42);
      });
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
