import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../config/app_config.dart';
import '../models/analysis_type.dart';
import '../models/analysis_result.dart';
import '../models/security_issue.dart';
import '../models/monitoring_recommendation.dart';

class OpenAIService {
  final Dio _dio;

  OpenAIService()
      : _dio = Dio(BaseOptions(
          baseUrl: AppConfig.openaiApiUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 90),
          sendTimeout: const Duration(seconds: 30),
          headers: {
            'Authorization': 'Bearer ${AppConfig.openaiApiKey}',
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

  /// Performs the actual analysis with comprehensive error handling
  Future<AnalysisResult> _performAnalysis({
    required String repositoryUrl,
    required String repositoryName,
    required String code,
    required AnalysisType analysisType,
  }) async {
    try {
      final prompt = _buildPrompt(code, analysisType);

      final response = await _dio.post(
        '/v1/chat/completions',
        data: {
          'model': AppConfig.openaiModel,
          'messages': [
            {'role': 'system', 'content': _getSystemPrompt(analysisType)},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'response_format': {'type': 'json_object'},
        },
      );

      // Comprehensive null-safety checks
      final responseData = response.data;
      if (responseData == null) {
        throw Exception('OpenAI API returned null response');
      }

      if (responseData is! Map<String, dynamic>) {
        throw Exception('OpenAI API returned invalid response format');
      }

      final choices = responseData['choices'];
      if (choices == null || choices is! List || choices.isEmpty) {
        throw Exception('OpenAI API response missing choices array');
      }

      final firstChoice = choices[0];
      if (firstChoice == null || firstChoice is! Map<String, dynamic>) {
        throw Exception('Invalid choice format in OpenAI response');
      }

      final message = firstChoice['message'];
      if (message == null || message is! Map<String, dynamic>) {
        throw Exception('Missing message in OpenAI response');
      }

      final content = message['content'];
      if (content == null || content is! String || content.isEmpty) {
        throw Exception('Missing or invalid content in OpenAI response');
      }

      // Parse JSON with error handling
      Map<String, dynamic> analysisData;
      try {
        final decoded = jsonDecode(content);
        if (decoded is! Map<String, dynamic>) {
          throw Exception('OpenAI returned non-object JSON');
        }
        analysisData = decoded;
      } on FormatException catch (e) {
        throw Exception('Failed to parse OpenAI JSON response: ${e.message}');
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
          'OpenAI rate limit exceeded. Please wait a few minutes and try again.',
        );
      } else if (e.response?.statusCode == 401) {
        throw Exception(
          'OpenAI API key is invalid or expired. Please check your configuration.',
        );
      } else if (e.response?.statusCode == 400) {
        final errorMsg = e.response?.data?['error']?['message'] ?? 'Bad request';
        throw Exception('OpenAI API error: $errorMsg');
      } else if (e.response?.statusCode == 500 || e.response?.statusCode == 502 || e.response?.statusCode == 503) {
        throw Exception(
          'OpenAI service is temporarily unavailable. Please try again later.',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection to OpenAI timed out. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'OpenAI is taking too long to respond. The repository may be too large.',
        );
      } else if (e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          'Failed to send request to OpenAI. The repository may be too large.',
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

  String _getSystemPrompt(AnalysisType analysisType) {
    if (analysisType == AnalysisType.security) {
      return '''You are a senior security auditor analyzing code for real security vulnerabilities.

CRITICAL REQUIREMENTS:
1. Only report ACTUAL security issues you can verify in the provided code
2. You MUST provide the exact file path and line number where each issue exists
3. Do NOT report issues if you cannot identify the specific location in the code
4. Verify that the line number you provide actually contains the problematic code
5. Focus on high-confidence findings only - avoid false positives

SEVERITY GUIDELINES:
- CRITICAL: Confirmed hardcoded secrets, SQL injection, RCE vulnerabilities with clear exploit path
- HIGH: Authentication bypass, XSS with user input, insecure cryptography actually in use
- MEDIUM: Missing security headers, weak validation that exists but is flawed
- LOW: Security best practices, defense-in-depth improvements

Return your analysis as a JSON object with this exact structure:
{
  "summary": {
    "total": <number>,
    "bySeverity": {
      "critical": <number>,
      "high": <number>,
      "medium": <number>,
      "low": <number>
    }
  },
  "issues": [
    {
      "id": "<unique-id>",
      "title": "<specific issue title>",
      "category": "<category>",
      "severity": "critical|high|medium|low",
      "description": "<detailed description with actual code reference>",
      "aiGenerationRisk": "<why AI assistants commonly generate this pattern>",
      "claudeCodePrompt": "<specific, actionable prompt to fix this exact issue>",
      "filePath": "<exact relative path like src/auth.py or lib/main.dart>",
      "lineNumber": <exact line number where issue starts, or null if file-wide>
    }
  ]
}

IMPORTANT: Each filePath and lineNumber must point to actual problematic code in the repository. If you cannot pinpoint the exact location, do not report the issue.''';
    } else {
      return '''You are an observability expert analyzing business applications for monitoring opportunities.

CRITICAL REQUIREMENTS:
1. Only recommend monitoring for actual business-critical code paths you can see
2. You MUST provide the exact file path and line number where monitoring should be added
3. Do NOT make generic recommendations - be specific to the actual code
4. Verify that the file and line number you provide is a logical place to add monitoring
5. Focus on high-value, actionable recommendations

CATEGORY GUIDELINES:
- analytics: User behavior, feature usage, conversion tracking (e.g., signup flows, purchases)
- error_tracking: Error boundaries, API failures, exception handling that exists but lacks monitoring
- business_metrics: Revenue events, SLA metrics, performance KPIs for critical operations

Return your analysis as a JSON object with this exact structure:
{
  "summary": {
    "total": <number>,
    "byCategory": {
      "analytics": <number>,
      "error_tracking": <number>,
      "business_metrics": <number>
    }
  },
  "recommendations": [
    {
      "id": "<unique-id>",
      "title": "<specific recommendation title>",
      "category": "analytics|error_tracking|business_metrics",
      "description": "<detailed description referencing actual code>",
      "businessValue": "<concrete business impact and metrics that could be tracked>",
      "claudeCodePrompt": "<specific prompt to add monitoring at this location>",
      "filePath": "<exact relative path like src/checkout.py or lib/pages/payment.dart>",
      "lineNumber": <exact line number where monitoring should be added, or null if file-wide>
    }
  ]
}

IMPORTANT: Each filePath and lineNumber must point to actual code where monitoring would add business value. Reference specific functions, API endpoints, or user flows.''';
    }
  }

  String _buildPrompt(String code, AnalysisType analysisType) {
    if (analysisType == AnalysisType.security) {
      return '''Analyze this repository for CONFIRMED security vulnerabilities.

ANALYSIS INSTRUCTIONS:
1. Read through the code carefully to identify actual security issues
2. For EACH issue you report, verify the exact file path and line number
3. Only report issues where you can see the vulnerable code
4. Include code snippets in your description to prove the issue exists

Focus on HIGH-CONFIDENCE findings:
- Hardcoded secrets/credentials (API keys, passwords, tokens visible in code)
- SQL injection (string concatenation in SQL queries with user input)
- XSS vulnerabilities (unsanitized user input rendered in HTML)
- Authentication bypass (missing auth checks, hardcoded credentials)
- Insecure API endpoints (public endpoints exposing sensitive data)
- Command injection (user input passed to system commands)
- Path traversal (file operations with unsanitized paths)

Repository code with file paths:
$code

REMEMBER: Every issue MUST include the exact filePath and lineNumber where the vulnerability exists. If you cannot identify the specific location, do NOT report it.''';
    } else {
      return '''Analyze this repository for specific, high-value monitoring opportunities.

ANALYSIS INSTRUCTIONS:
1. Identify actual business-critical code paths (auth flows, payments, API calls, etc.)
2. For EACH recommendation, provide the exact file path and line number
3. Only recommend monitoring where you can see the actual code that needs instrumentation
4. Focus on monitoring that would provide concrete business insights

Look for monitoring gaps in:
- User action tracking: Signup flows, login attempts, feature usage, conversion events
- Error tracking: API failures, payment errors, authentication failures with actual error handling code
- Business metrics: Transaction completion, response times for critical endpoints, usage patterns
- Performance monitoring: Database query times, API latency, resource usage in bottleneck areas

Repository code with file paths:
$code

REMEMBER: Every recommendation MUST include the exact filePath and lineNumber where monitoring should be added. Reference specific functions, classes, or endpoints.''';
    }
  }

  AnalysisResult _parseAnalysisResult({
    required String repositoryUrl,
    required String repositoryName,
    required AnalysisType analysisType,
    required Map<String, dynamic> data,
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
      timestamp: DateTime.now(),
      summary: summary,
      securityIssues: securityIssues,
      monitoringRecommendations: monitoringRecommendations,
    );
  }

  /// Validates a security issue object has required fields
  void _validateSecurityIssue(Map<String, dynamic> issue) {
    final requiredFields = ['id', 'title', 'category', 'severity', 'description', 'aiGenerationRisk', 'claudeCodePrompt'];

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
    final requiredFields = ['id', 'title', 'category', 'description', 'businessValue', 'claudeCodePrompt'];

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
}
