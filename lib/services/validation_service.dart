import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/security_issue.dart';
import '../models/monitoring_recommendation.dart';
import '../models/validation_status.dart';
import '../models/validation_result.dart';
import '../models/analysis_mode.dart';
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
    required AnalysisMode analysisMode,
  }) async {
    // Check credits (client-side check for UI feedback)
    if (!await canValidate()) {
      throw InsufficientCreditsException(
        'You need $costPerValidation credit to validate a fix. Current balance: ${await getCredits()}',
      );
    }

    // NOTE: Credits are consumed by the Edge Function, not here
    // This prevents double-spending and race conditions

    try {
      print('🔍 [VALIDATION] Starting security fix validation');
      print('🔍 [VALIDATION] Analysis Mode: $analysisMode');
      print('🔍 [VALIDATION] Repository URL: $repositoryUrl');
      print('🔍 [VALIDATION] Repository Name: $repositoryName');

      // Update status to validating
      var updatedIssue = issue.copyWith(
        validationStatus: ValidationStatus.validating,
      );

      // Fetch updated code from repository (only for static code analysis)
      // For runtime monitoring, we don't need to fetch code from GitHub
      final updatedCode = analysisMode == AnalysisMode.staticCode
          ? await _fetchRepositoryCode(
              repositoryUrl,
              filePath: issue.filePath,
            )
          : '';

      print('🔍 [VALIDATION] Updated code length: ${updatedCode.length}');
      print('🔍 [VALIDATION] Calling OpenAI service for validation');

      // Perform validation (Edge Function will consume credits)
      final validationResult = await _openaiService.validateSecurityFix(
        issue: issue,
        updatedCode: updatedCode,
        repositoryName: repositoryName,
      );

      print('🔍 [VALIDATION] Validation result received: ${validationResult.status}');

      // Update issue with validation result
      updatedIssue = updatedIssue.copyWith(
        validationStatus: validationResult.status,
        validationResult: validationResult,
      );

      return updatedIssue;
    } catch (e) {
      print('❌ [VALIDATION] Error caught: ${e.toString()}');
      print('❌ [VALIDATION] Error type: ${e.runtimeType}');
      // Note: No refund here since Edge Function handles credit management
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
    required AnalysisMode analysisMode,
  }) async {
    // Check credits (client-side check for UI feedback)
    if (!await canValidate()) {
      throw InsufficientCreditsException(
        'You need $costPerValidation credit to validate an implementation. Current balance: ${await getCredits()}',
      );
    }

    // NOTE: Credits are consumed by the Edge Function, not here
    // This prevents double-spending and race conditions

    try {
      print('🔍 [VALIDATION] Starting monitoring validation');
      print('🔍 [VALIDATION] Analysis Mode: $analysisMode');
      print('🔍 [VALIDATION] Repository URL: $repositoryUrl');
      print('🔍 [VALIDATION] Repository Name: $repositoryName');

      // Update status to validating
      var updatedRecommendation = recommendation.copyWith(
        validationStatus: ValidationStatus.validating,
      );

      // Fetch updated code from repository (only for static code analysis)
      // For runtime monitoring, we don't need to fetch code from GitHub
      final updatedCode = analysisMode == AnalysisMode.staticCode
          ? await _fetchRepositoryCode(
              repositoryUrl,
              filePath: recommendation.filePath,
            )
          : '';

      print('🔍 [VALIDATION] Updated code length: ${updatedCode.length}');
      print('🔍 [VALIDATION] Calling OpenAI service for validation');

      // Perform validation (Edge Function will consume credits)
      final validationResult =
          await _openaiService.validateMonitoringImplementation(
        recommendation: recommendation,
        updatedCode: updatedCode,
        repositoryName: repositoryName,
      );

      print('🔍 [VALIDATION] Validation result received: ${validationResult.status}');

      // Update recommendation with validation result
      updatedRecommendation = updatedRecommendation.copyWith(
        validationStatus: validationResult.status,
        validationResult: validationResult,
      );

      return updatedRecommendation;
    } catch (e) {
      print('❌ [VALIDATION] Error caught: ${e.toString()}');
      print('❌ [VALIDATION] Error type: ${e.runtimeType}');
      // Note: No refund here since Edge Function handles credit management
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

  /// Fetches specific file for validation (not entire repository)
  Future<String> _fetchRepositoryCode(String repositoryUrl, {String? filePath}) async {
    try {
      final codeBuffer = StringBuffer();

      // If a specific file is provided, only fetch that file
      if (filePath != null && filePath.isNotEmpty) {
        try {
          final content = await _githubService.getFileContent(
            repositoryUrl,
            filePath,
          );

          codeBuffer.writeln('--- $filePath ---');
          codeBuffer.writeln(content);
          codeBuffer.writeln();

          return codeBuffer.toString();
        } catch (e) {
          // If specific file fetch fails, fall back to directory fetch
          // Extract directory from filePath
          final directory = filePath.contains('/')
              ? filePath.substring(0, filePath.lastIndexOf('/'))
              : '';

          if (directory.isNotEmpty) {
            return _fetchDirectoryCode(repositoryUrl, directory);
          }

          throw Exception('Failed to fetch file $filePath: $e');
        }
      }

      // Fallback: fetch small subset of relevant files
      return _fetchDirectoryCode(repositoryUrl, '');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to fetch repository code: $e');
    }
  }

  /// Fetches code from a specific directory or root
  Future<String> _fetchDirectoryCode(String repositoryUrl, String directory) async {
    // Get repository tree
    final tree = await _githubService.getRepositoryTree(repositoryUrl);

    // Filter files in the specified directory
    final relevantFiles = tree.where((file) {
      final path = file['path'] as String?;
      if (path == null) return false;

      // If directory specified, only include files from that directory
      if (directory.isNotEmpty && !path.startsWith(directory)) {
        return false;
      }

      // Skip non-code files
      final excludedPatterns = [
        '.git/',
        'node_modules/',
        'vendor/',
        'dist/',
        'build/',
        'test/',
        'tests/',
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
      ];

      return includedExtensions.any((ext) => path.endsWith(ext));
    }).toList();

    // Limit to first 10 files
    final limitedFiles = relevantFiles.take(10).toList();

    // Fetch file contents
    final codeBuffer = StringBuffer();
    for (final file in limitedFiles) {
      final path = file['path'] as String;
      try {
        final content = await _githubService.getFileContent(
          repositoryUrl,
          path,
        );

        codeBuffer.writeln('--- $path ---');
        codeBuffer.writeln(content);
        codeBuffer.writeln();
      } catch (e) {
        // Skip files that fail to fetch
        continue;
      }
    }

    if (codeBuffer.isEmpty) {
      throw Exception('No code files found in repository');
    }

    return codeBuffer.toString();
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
