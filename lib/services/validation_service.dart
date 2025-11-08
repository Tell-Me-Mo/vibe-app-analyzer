import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/security_issue.dart';
import '../models/monitoring_recommendation.dart';
import '../models/validation_status.dart';
import '../models/validation_result.dart';
import 'credits_service.dart';
import 'github_service.dart';
import 'openai_service.dart';

/// Service for validating security fixes and monitoring implementations
class ValidationService {
  final CreditsService _creditsService;
  final GitHubService _githubService;
  final OpenAIService _openaiService;

  static const int costPerValidation = 1;

  ValidationService({
    required CreditsService creditsService,
    required GitHubService githubService,
    required OpenAIService openaiService,
  })  : _creditsService = creditsService,
        _githubService = githubService,
        _openaiService = openaiService;

  /// Check if user has enough credits for validation
  Future<bool> canValidate() async {
    return await _creditsService.hasEnoughCredits(costPerValidation);
  }

  /// Get current credit balance
  Future<int> getCredits() async {
    return await _creditsService.getCredits();
  }

  /// Validates a security issue fix
  ///
  /// Returns updated SecurityIssue with validation result
  /// Throws exception if validation fails or insufficient credits
  Future<SecurityIssue> validateSecurityFix({
    required SecurityIssue issue,
    required String repositoryUrl,
    required String repositoryName,
  }) async {
    // Check credits
    if (!await canValidate()) {
      throw InsufficientCreditsException(
        'You need $costPerValidation credit to validate a fix. Current balance: ${await getCredits()}',
      );
    }

    // Consume credits before validation
    final consumed = await _creditsService.consumeCredits(costPerValidation);
    if (!consumed) {
      throw Exception('Failed to consume credits for validation');
    }

    try {
      // Update status to validating
      var updatedIssue = issue.copyWith(
        validationStatus: ValidationStatus.validating,
      );

      // Fetch updated code from repository
      final updatedCode = await _fetchRepositoryCode(repositoryUrl);

      // Perform validation
      final validationResult = await _openaiService.validateSecurityFix(
        issue: issue,
        updatedCode: updatedCode,
        repositoryName: repositoryName,
      );

      // Update issue with validation result
      updatedIssue = updatedIssue.copyWith(
        validationStatus: validationResult.status,
        validationResult: validationResult,
      );

      return updatedIssue;
    } catch (e) {
      // Refund credit if validation failed due to error
      await _creditsService.addCredits(costPerValidation);

      // Return issue with error status
      return issue.copyWith(
        validationStatus: ValidationStatus.error,
        validationResult: ValidationResult(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          status: ValidationStatus.error,
          timestamp: DateTime.now(),
          summary: 'Validation failed',
          details: e.toString(),
        ),
      );
    }
  }

  /// Validates a monitoring recommendation implementation
  ///
  /// Returns updated MonitoringRecommendation with validation result
  /// Throws exception if validation fails or insufficient credits
  Future<MonitoringRecommendation> validateMonitoringImplementation({
    required MonitoringRecommendation recommendation,
    required String repositoryUrl,
    required String repositoryName,
  }) async {
    // Check credits
    if (!await canValidate()) {
      throw InsufficientCreditsException(
        'You need $costPerValidation credit to validate an implementation. Current balance: ${await getCredits()}',
      );
    }

    // Consume credits before validation
    final consumed = await _creditsService.consumeCredits(costPerValidation);
    if (!consumed) {
      throw Exception('Failed to consume credits for validation');
    }

    try {
      // Update status to validating
      var updatedRecommendation = recommendation.copyWith(
        validationStatus: ValidationStatus.validating,
      );

      // Fetch updated code from repository
      final updatedCode = await _fetchRepositoryCode(repositoryUrl);

      // Perform validation
      final validationResult =
          await _openaiService.validateMonitoringImplementation(
        recommendation: recommendation,
        updatedCode: updatedCode,
        repositoryName: repositoryName,
      );

      // Update recommendation with validation result
      updatedRecommendation = updatedRecommendation.copyWith(
        validationStatus: validationResult.status,
        validationResult: validationResult,
      );

      return updatedRecommendation;
    } catch (e) {
      // Refund credit if validation failed due to error
      await _creditsService.addCredits(costPerValidation);

      // Return recommendation with error status
      return recommendation.copyWith(
        validationStatus: ValidationStatus.error,
        validationResult: ValidationResult(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          status: ValidationStatus.error,
          timestamp: DateTime.now(),
          summary: 'Validation failed',
          details: e.toString(),
        ),
      );
    }
  }

  /// Fetches repository code for validation
  Future<String> _fetchRepositoryCode(String repositoryUrl) async {
    try {
      // Get repository tree
      final tree = await _githubService.getRepositoryTree(repositoryUrl);

      // Filter relevant files (same logic as analysis)
      final relevantFiles = tree.where((file) {
        final path = file['path'] as String?;
        if (path == null) return false;

        // Skip non-code files
        final excludedPatterns = [
          '.git/',
          'node_modules/',
          'vendor/',
          'dist/',
          'build/',
          '.png',
          '.jpg',
          '.jpeg',
          '.gif',
          '.svg',
          '.ico',
          '.woff',
          '.ttf',
          '.lock',
          'package-lock.json',
          'yarn.lock',
        ];

        for (final pattern in excludedPatterns) {
          if (path.contains(pattern)) return false;
        }

        // Include code files
        final includedExtensions = [
          '.dart',
          '.js',
          '.ts',
          '.jsx',
          '.tsx',
          '.py',
          '.java',
          '.go',
          '.rs',
          '.cpp',
          '.c',
          '.h',
          '.swift',
          '.kt',
          '.rb',
          '.php',
          '.cs',
          '.json',
          '.yaml',
          '.yml',
        ];

        return includedExtensions.any((ext) => path.endsWith(ext));
      }).toList();

      // Fetch file contents with size limit
      final codeBuffer = StringBuffer();
      int totalSize = 0;
      const maxSize = 100000; // ~100KB limit for validation context

      for (final file in relevantFiles) {
        if (totalSize >= maxSize) break;

        final path = file['path'] as String;
        try {
          final content = await _githubService.getFileContent(
            repositoryUrl,
            path,
          );

          codeBuffer.writeln('--- $path ---');
          codeBuffer.writeln(content);
          codeBuffer.writeln();

          totalSize += content.length;
        } catch (e) {
          // Skip files that fail to fetch
          continue;
        }
      }

      if (codeBuffer.isEmpty) {
        throw Exception('No code files found in repository');
      }

      return codeBuffer.toString();
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to fetch repository code: $e');
    }
  }
}

/// Exception thrown when user has insufficient credits
class InsufficientCreditsException implements Exception {
  final String message;
  InsufficientCreditsException(this.message);

  @override
  String toString() => message;
}

/// Provider for validation service
final validationServiceProvider = Provider<ValidationService>((ref) {
  return ValidationService(
    creditsService: ref.watch(creditsServiceProvider),
    githubService: GitHubService(),
    openaiService: OpenAIService(),
  );
});
