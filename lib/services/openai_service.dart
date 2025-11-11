import 'dart:math';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../models/analysis_type.dart';
import '../models/analysis_mode.dart';
import '../models/analysis_result.dart';
import '../models/security_issue.dart';
import '../models/monitoring_recommendation.dart';
import '../models/validation_status.dart';
import '../models/validation_result.dart';
import '../models/runtime_analysis_data.dart';

class OpenAIService {
  final Dio _dio;
  final SupabaseClient _supabase = Supabase.instance.client;

  OpenAIService()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 90),
          sendTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
          },
        ));

  Future<AnalysisResult> analyzeCode({
    required String repositoryUrl,
    required String repositoryName,
    required String code,
    required AnalysisType analysisType,
  }) async {
    return _retryWithExponentialBackoff(
      () => _performAnalysis(
        repositoryUrl: repositoryUrl,
        repositoryName: repositoryName,
        code: code,
        analysisType: analysisType,
      ),
      maxRetries: 3,
    );
  }

  /// Analyzes runtime data from a live application
  Future<AnalysisResult> analyzeRuntimeApp({
    required String appUrl,
    required String appName,
    required RuntimeAnalysisData runtimeData,
    required AnalysisType analysisType,
  }) async {
    return _retryWithExponentialBackoff(
      () => _performRuntimeAnalysis(
        appUrl: appUrl,
        appName: appName,
        runtimeData: runtimeData,
        analysisType: analysisType,
      ),
      maxRetries: 3,
    );
  }

  /// Performs the actual analysis with comprehensive error handling
  Future<AnalysisResult> _performAnalysis({
    required String repositoryUrl,
    required String repositoryName,
    required String code,
    required AnalysisType analysisType,
  }) async {
    try {
      // Get the Supabase Edge Function URL
      final supabaseUrl = AppConfig.supabaseUrl;
      final supabaseKey = AppConfig.supabaseAnonKey;
      final functionUrl = '$supabaseUrl/functions/v1/analyze-code';

      // Get the current session token
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('No active session. Please sign in.');
      }

      final response = await _dio.post(
        functionUrl,
        data: {
          'repositoryUrl': repositoryUrl,
          'repositoryName': repositoryName,
          'code': code,
          'analysisType': analysisType.value,
          'analysisMode': 'staticCode',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'apikey': supabaseKey,
          },
        ),
      );

      // The Edge Function returns the analysis data directly
      final analysisData = response.data;
      if (analysisData == null || analysisData is! Map<String, dynamic>) {
        throw Exception('Invalid response from analysis service');
      }

      return _parseAnalysisResult(
        repositoryUrl: repositoryUrl,
        repositoryName: repositoryName,
        analysisType: analysisType,
        data: analysisData,
      );
    } on DioException catch (e) {
      // Handle specific HTTP error codes
      if (e.response?.statusCode == 429) {
        throw Exception(
          'Analysis rate limit exceeded. Please wait a few minutes and try again.',
        );
      } else if (e.response?.statusCode == 401) {
        throw Exception(
          'Authentication failed. Please sign in again.',
        );
      } else if (e.response?.statusCode == 402) {
        throw Exception(
          'Insufficient credits. Please purchase more credits to continue.',
        );
      } else if (e.response?.statusCode == 400) {
        final errorMsg = e.response?.data?['error'] ?? 'Bad request';
        throw Exception('Analysis error: $errorMsg');
      } else if (e.response?.statusCode == 500 || e.response?.statusCode == 502 || e.response?.statusCode == 503) {
        throw Exception(
          'Analysis service is temporarily unavailable. Please try again later.',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'Analysis is taking too long. The repository may be too large.',
        );
      } else if (e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          'Failed to send request. The repository may be too large.',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      // Re-throw if already formatted
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Unexpected error during analysis: $e');
    }
  }

  /// Performs runtime analysis on live application data
  Future<AnalysisResult> _performRuntimeAnalysis({
    required String appUrl,
    required String appName,
    required RuntimeAnalysisData runtimeData,
    required AnalysisType analysisType,
  }) async {
    try {
      // Get the Supabase Edge Function URL
      final supabaseUrl = AppConfig.supabaseUrl;
      final supabaseKey = AppConfig.supabaseAnonKey;
      final functionUrl = '$supabaseUrl/functions/v1/analyze-code';

      // Get the current session token
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('No active session. Please sign in.');
      }

      final response = await _dio.post(
        functionUrl,
        data: {
          'repositoryUrl': appUrl,
          'repositoryName': appName,
          'code': '', // Not used for runtime analysis
          'analysisType': analysisType.value,
          'analysisMode': 'runtime',
          'runtimeData': {
            'url': runtimeData.url,
            'html': runtimeData.html,
            'headers': runtimeData.headers,
            'statusCode': runtimeData.statusCode,
            'ttfb': runtimeData.ttfb,
            'pageLoadTime': runtimeData.pageLoadTime,
            'detectedTools': {
              'hasGoogleAnalytics': runtimeData.detectedTools.hasGoogleAnalytics,
              'hasMixpanel': runtimeData.detectedTools.hasMixpanel,
              'hasSegment': runtimeData.detectedTools.hasSegment,
              'hasSentry': runtimeData.detectedTools.hasSentry,
              'hasBugsnag': runtimeData.detectedTools.hasBugsnag,
            },
            'securityConfig': {
              'hasHttps': runtimeData.securityConfig.hasHttps,
              'hasHSTS': runtimeData.securityConfig.hasHSTS,
              'hasCSP': runtimeData.securityConfig.hasCSP,
              'securityHeaders': runtimeData.securityConfig.securityHeaders,
              'cookies': runtimeData.securityConfig.cookies.map((c) => {
                'name': c.name,
                'isSecure': c.isSecure,
                'isHttpOnly': c.isHttpOnly,
                'sameSite': c.sameSite,
              }).toList(),
            },
          },
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'apikey': supabaseKey,
          },
        ),
      );

      // The Edge Function returns the analysis data directly
      final analysisData = response.data;
      if (analysisData == null || analysisData is! Map<String, dynamic>) {
        throw Exception('Invalid response from analysis service');
      }

      return _parseAnalysisResult(
        repositoryUrl: appUrl,
        repositoryName: appName,
        analysisType: analysisType,
        data: analysisData,
        analysisMode: AnalysisMode.runtime,
      );
    } on DioException catch (e) {
      // Use same error handling as static analysis
      if (e.response?.statusCode == 429) {
        throw Exception(
          'Analysis rate limit exceeded. Please wait a few minutes and try again.',
        );
      } else if (e.response?.statusCode == 401) {
        throw Exception(
          'Authentication failed. Please sign in again.',
        );
      } else if (e.response?.statusCode == 402) {
        throw Exception(
          'Insufficient credits. Please purchase more credits to continue.',
        );
      } else if (e.response?.statusCode == 400) {
        final errorMsg = e.response?.data?['error'] ?? 'Bad request';
        throw Exception('Analysis error: $errorMsg');
      } else if (e.response?.statusCode == 500 ||
          e.response?.statusCode == 502 ||
          e.response?.statusCode == 503) {
        throw Exception(
          'Analysis service is temporarily unavailable. Please try again later.',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'Analysis is taking too long. The application data may be too large.',
        );
      } else if (e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          'Failed to send request. The application data may be too large.',
        );
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      // Re-throw if already formatted
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Unexpected error during runtime analysis: $e');
    }
  }

  /// Retry logic with exponential backoff for transient failures
  Future<T> _retryWithExponentialBackoff<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
  }) async {
    int attempt = 0;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempt++;

        // Don't retry on non-transient errors
        if (e is Exception) {
          final errorMsg = e.toString();
          if (errorMsg.contains('rate limit exceeded') ||
              errorMsg.contains('API key is invalid') ||
              errorMsg.contains('Bad request') ||
              errorMsg.contains('too large')) {
            rethrow;
          }
        }

        if (attempt >= maxRetries) {
          rethrow;
        }

        // Exponential backoff: 2^attempt seconds (2s, 4s, 8s)
        final delaySeconds = pow(2, attempt).toInt();
        await Future.delayed(Duration(seconds: delaySeconds));
      }
    }
  }

  // Note: Prompt building methods removed - now handled by Edge Functions

  AnalysisResult _parseAnalysisResult({
    required String repositoryUrl,
    required String repositoryName,
    required AnalysisType analysisType,
    required Map<String, dynamic> data,
    AnalysisMode analysisMode = AnalysisMode.staticCode,
  }) {
    // Validate summary exists and is valid
    final summaryData = data['summary'];
    if (summaryData == null || summaryData is! Map<String, dynamic>) {
      throw Exception('Analysis response missing or invalid summary object');
    }

    AnalysisSummary summary;
    try {
      summary = AnalysisSummary.fromJson(summaryData);
    } catch (e) {
      throw Exception('Failed to parse analysis summary: $e');
    }

    List<SecurityIssue>? securityIssues;
    List<MonitoringRecommendation>? monitoringRecommendations;

    if (analysisType == AnalysisType.security) {
      final issuesData = data['issues'];

      if (issuesData != null) {
        if (issuesData is! List) {
          throw Exception('Security issues must be an array');
        }

        try {
          securityIssues = issuesData.map((issue) {
            if (issue is! Map<String, dynamic>) {
              throw Exception('Each issue must be an object');
            }

            // Validate required fields
            _validateSecurityIssue(issue);

            // Add generated ID if not present
            if (!issue.containsKey('id') || issue['id'] == null) {
              issue['id'] = const Uuid().v4();
            }

            return SecurityIssue.fromJson(issue);
          }).toList();
        } catch (e) {
          throw Exception('Failed to parse security issues: $e');
        }
      }
    } else {
      final recsData = data['recommendations'];

      if (recsData != null) {
        if (recsData is! List) {
          throw Exception('Monitoring recommendations must be an array');
        }

        try {
          monitoringRecommendations = recsData.map((rec) {
            if (rec is! Map<String, dynamic>) {
              throw Exception('Each recommendation must be an object');
            }

            // Validate required fields
            _validateMonitoringRecommendation(rec);

            // Add generated ID if not present
            if (!rec.containsKey('id') || rec['id'] == null) {
              rec['id'] = const Uuid().v4();
            }

            return MonitoringRecommendation.fromJson(rec);
          }).toList();
        } catch (e) {
          throw Exception('Failed to parse monitoring recommendations: $e');
        }
      }
    }

    return AnalysisResult(
      id: const Uuid().v4(),
      repositoryUrl: repositoryUrl,
      repositoryName: repositoryName,
      analysisType: analysisType,
      analysisMode: analysisMode,
      timestamp: DateTime.now(),
      summary: summary,
      securityIssues: securityIssues,
      monitoringRecommendations: monitoringRecommendations,
    );
  }

  /// Validates a security issue object has required fields
  void _validateSecurityIssue(Map<String, dynamic> issue) {
    final requiredFields = ['title', 'category', 'severity', 'description', 'aiGenerationRisk', 'claudeCodePrompt'];

    for (final field in requiredFields) {
      if (!issue.containsKey(field) || issue[field] == null) {
        throw Exception('Security issue missing required field: $field');
      }
      if (issue[field] is String && (issue[field] as String).isEmpty) {
        throw Exception('Security issue field "$field" cannot be empty');
      }
    }

    // Validate severity is a valid enum value
    final severity = issue['severity'];
    if (severity is! String || !['critical', 'high', 'medium', 'low'].contains(severity.toLowerCase())) {
      throw Exception('Invalid severity value: $severity');
    }

    // Validate line number if present
    final lineNumber = issue['lineNumber'];
    if (lineNumber != null) {
      if (lineNumber is! int || lineNumber < 1 || lineNumber > 999999) {
        throw Exception('Invalid line number: $lineNumber (must be between 1 and 999999)');
      }
    }

    // Validate file path if present
    final filePath = issue['filePath'];
    if (filePath != null && filePath is String) {
      if (filePath.isEmpty || filePath.length > 1000) {
        throw Exception('Invalid file path length');
      }
      // Check for suspicious path traversal patterns
      if (filePath.contains('..') || filePath.startsWith('/')) {
        throw Exception('Invalid file path format: $filePath');
      }
    }
  }

  /// Validates a monitoring recommendation object has required fields
  void _validateMonitoringRecommendation(Map<String, dynamic> rec) {
    final requiredFields = ['title', 'category', 'description', 'businessValue', 'claudeCodePrompt'];

    for (final field in requiredFields) {
      if (!rec.containsKey(field) || rec[field] == null) {
        throw Exception('Monitoring recommendation missing required field: $field');
      }
      if (rec[field] is String && (rec[field] as String).isEmpty) {
        throw Exception('Monitoring recommendation field "$field" cannot be empty');
      }
    }

    // Validate category is a valid enum value
    final category = rec['category'];
    if (category is! String || !['analytics', 'error_tracking', 'business_metrics'].contains(category.toLowerCase())) {
      throw Exception('Invalid monitoring category: $category');
    }

    // Validate line number if present
    final lineNumber = rec['lineNumber'];
    if (lineNumber != null) {
      if (lineNumber is! int || lineNumber < 1 || lineNumber > 999999) {
        throw Exception('Invalid line number: $lineNumber (must be between 1 and 999999)');
      }
    }

    // Validate file path if present
    final filePath = rec['filePath'];
    if (filePath != null && filePath is String) {
      if (filePath.isEmpty || filePath.length > 1000) {
        throw Exception('Invalid file path length');
      }
      // Check for suspicious path traversal patterns
      if (filePath.contains('..') || filePath.startsWith('/')) {
        throw Exception('Invalid file path format: $filePath');
      }
    }
  }

  /// Validates a security issue fix by analyzing the updated code
  Future<ValidationResult> validateSecurityFix({
    required SecurityIssue issue,
    required String updatedCode,
    required String repositoryName,
  }) async {
    return _retryWithExponentialBackoff(
      () => _performSecurityValidation(
        issue: issue,
        updatedCode: updatedCode,
        repositoryName: repositoryName,
      ),
      maxRetries: 2,
    );
  }

  /// Validates a monitoring recommendation implementation by analyzing the updated code
  Future<ValidationResult> validateMonitoringImplementation({
    required MonitoringRecommendation recommendation,
    required String updatedCode,
    required String repositoryName,
  }) async {
    return _retryWithExponentialBackoff(
      () => _performMonitoringValidation(
        recommendation: recommendation,
        updatedCode: updatedCode,
        repositoryName: repositoryName,
      ),
      maxRetries: 2,
    );
  }

  /// Performs security fix validation
  Future<ValidationResult> _performSecurityValidation({
    required SecurityIssue issue,
    required String updatedCode,
    required String repositoryName,
  }) async {
    try {
      // Get the Supabase Edge Function URL
      final supabaseUrl = AppConfig.supabaseUrl;
      final supabaseKey = AppConfig.supabaseAnonKey;
      final functionUrl = '$supabaseUrl/functions/v1/validate-fix';

      // Get the current session token
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('No active session. Please sign in.');
      }

      final response = await _dio.post(
        functionUrl,
        data: {
          'validationType': 'security',
          'repositoryName': repositoryName,
          'updatedCode': updatedCode,
          'issue': {
            'title': issue.title,
            'category': issue.category,
            'severity': issue.severity.value,
            'description': issue.description,
            'filePath': issue.filePath,
            'lineNumber': issue.lineNumber,
          },
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'apikey': supabaseKey,
          },
        ),
      );

      final validationData = response.data;
      if (validationData == null || validationData is! Map<String, dynamic>) {
        throw Exception('Invalid response from validation service');
      }

      return _parseValidationResult(validationData);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Validation error: $e');
    }
  }

  /// Performs monitoring implementation validation
  Future<ValidationResult> _performMonitoringValidation({
    required MonitoringRecommendation recommendation,
    required String updatedCode,
    required String repositoryName,
  }) async {
    try {
      // Get the Supabase Edge Function URL
      final supabaseUrl = AppConfig.supabaseUrl;
      final supabaseKey = AppConfig.supabaseAnonKey;
      final functionUrl = '$supabaseUrl/functions/v1/validate-fix';

      // Get the current session token
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('No active session. Please sign in.');
      }

      final response = await _dio.post(
        functionUrl,
        data: {
          'validationType': 'monitoring',
          'repositoryName': repositoryName,
          'updatedCode': updatedCode,
          'recommendation': {
            'title': recommendation.title,
            'category': recommendation.category,
            'description': recommendation.description,
            'businessValue': recommendation.businessValue,
            'filePath': recommendation.filePath,
            'lineNumber': recommendation.lineNumber,
          },
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'apikey': supabaseKey,
          },
        ),
      );

      final validationData = response.data;
      if (validationData == null || validationData is! Map<String, dynamic>) {
        throw Exception('Invalid response from validation service');
      }

      return _parseValidationResult(validationData);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Validation error: $e');
    }
  }

  // Note: Validation prompt building methods removed - now handled by Edge Function

  ValidationResult _parseValidationResult(Map<String, dynamic> data) {
    final statusStr = data['status'] as String?;
    if (statusStr == null) {
      throw Exception('Validation response missing status');
    }

    ValidationStatus status;
    if (statusStr.toLowerCase() == 'passed') {
      status = ValidationStatus.passed;
    } else if (statusStr.toLowerCase() == 'failed') {
      status = ValidationStatus.failed;
    } else {
      throw Exception('Invalid validation status: $statusStr');
    }

    final summary = data['summary'] as String?;
    final details = data['details'] as String?;
    final remainingIssues = (data['remainingIssues'] as List?)
        ?.map((e) => e.toString())
        .toList();
    final recommendation = data['recommendation'] as String?;

    return ValidationResult(
      id: const Uuid().v4(),
      status: status,
      timestamp: DateTime.now(),
      summary: summary,
      details: details,
      remainingIssues: remainingIssues,
      recommendation: recommendation,
    );
  }

  Exception _handleDioException(DioException e) {
    if (e.response?.statusCode == 429) {
      return Exception(
        'OpenAI rate limit exceeded. Please wait a few minutes and try again.',
      );
    } else if (e.response?.statusCode == 401) {
      return Exception(
        'OpenAI API key is invalid or expired.',
      );
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout. Please try again.');
    } else {
      return Exception('Network error: ${e.message}');
    }
  }
}
