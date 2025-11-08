import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
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

  /// Performs runtime analysis on live application data
  Future<AnalysisResult> _performRuntimeAnalysis({
    required String appUrl,
    required String appName,
    required RuntimeAnalysisData runtimeData,
    required AnalysisType analysisType,
  }) async {
    try {
      final prompt = _buildRuntimePrompt(runtimeData, analysisType);

      final response = await _dio.post(
        '/v1/chat/completions',
        data: {
          'model': AppConfig.openaiModel,
          'messages': [
            {
              'role': 'system',
              'content': _getRuntimeSystemPrompt(analysisType)
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'response_format': {'type': 'json_object'},
        },
      );

      // Comprehensive null-safety checks (same as static analysis)
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
          'OpenAI rate limit exceeded. Please wait a few minutes and try again.',
        );
      } else if (e.response?.statusCode == 401) {
        throw Exception(
          'OpenAI API key is invalid or expired. Please check your configuration.',
        );
      } else if (e.response?.statusCode == 400) {
        final errorMsg = e.response?.data?['error']?['message'] ?? 'Bad request';
        throw Exception('OpenAI API error: $errorMsg');
      } else if (e.response?.statusCode == 500 ||
          e.response?.statusCode == 502 ||
          e.response?.statusCode == 503) {
        throw Exception(
          'OpenAI service is temporarily unavailable. Please try again later.',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection to OpenAI timed out. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'OpenAI is taking too long to respond. The application data may be too large.',
        );
      } else if (e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          'Failed to send request to OpenAI. The application data may be too large.',
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

  /// Gets the system prompt for runtime analysis
  String _getRuntimeSystemPrompt(AnalysisType analysisType) {
    if (analysisType == AnalysisType.security) {
      return '''You are a senior security expert analyzing DEPLOYED applications for runtime security vulnerabilities.

CRITICAL REQUIREMENTS:
1. Focus on RUNTIME security issues visible in deployed applications
2. Analyze HTTP headers, cookies, security configuration, and live page content
3. Provide actionable recommendations that can be immediately deployed
4. Prioritize based on actual risk exposure

SEVERITY GUIDELINES:
- CRITICAL: Missing HTTPS, no HSTS, cookies without Secure/HttpOnly on sensitive data
- HIGH: Missing CSP, weak CORS configuration, exposed sensitive data
- MEDIUM: Missing security headers (X-Frame-Options, etc.), suboptimal cookie settings
- LOW: Security best practices, additional hardening opportunities

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
      "description": "<detailed description of the runtime security issue>",
      "runtimeRisk": "<why this matters in production>",
      "claudeCodePrompt": "<specific, actionable prompt to fix this issue>",
      "filePath": null,
      "lineNumber": null
    }
  ]
}

IMPORTANT: For runtime analysis, filePath and lineNumber should be null since we're analyzing deployed applications, not source code.''';
    } else {
      return '''You are an observability expert analyzing DEPLOYED applications for monitoring gaps.

CRITICAL REQUIREMENTS:
1. Identify what monitoring tools are currently deployed (or missing)
2. Focus on production-ready, actionable recommendations
3. Recommend specific tools and configurations
4. Prioritize based on business impact

CATEGORY GUIDELINES:
- analytics: User behavior tracking, conversion metrics (detected/missing tools)
- error_tracking: Production error monitoring (Sentry, Bugsnag, etc.)
- business_metrics: Revenue tracking, KPIs, performance monitoring
- performance_monitoring: APM tools, Core Web Vitals, page load metrics

Return your analysis as a JSON object with this exact structure:
{
  "summary": {
    "total": <number>,
    "byCategory": {
      "analytics": <number>,
      "error_tracking": <number>,
      "business_metrics": <number>,
      "performance_monitoring": <number>
    }
  },
  "recommendations": [
    {
      "id": "<unique-id>",
      "title": "<specific recommendation title>",
      "category": "analytics|error_tracking|business_metrics|performance_monitoring",
      "description": "<what's missing or incomplete>",
      "businessValue": "<concrete business impact>",
      "claudeCodePrompt": "<specific implementation prompt>",
      "filePath": null,
      "lineNumber": null
    }
  ]
}

IMPORTANT: Mention detected tools in descriptions (e.g., "Google Analytics detected but missing conversion tracking"). For runtime analysis, filePath and lineNumber should be null.''';
    }
  }

  /// Builds the prompt for runtime analysis
  String _buildRuntimePrompt(
      RuntimeAnalysisData runtimeData, AnalysisType analysisType) {
    if (analysisType == AnalysisType.security) {
      return '''Analyze this LIVE deployed application for runtime security vulnerabilities.

${runtimeData.toAnalysisPrompt()}

ANALYSIS INSTRUCTIONS:
1. Examine HTTP security headers - identify missing or misconfigured headers
2. Analyze cookie security - check for Secure, HttpOnly, SameSite attributes
3. Review HTTPS configuration and HSTS
4. Check for exposed sensitive data in HTML/JavaScript
5. Identify security misconfigurations

Focus on HIGH-CONFIDENCE findings that pose real security risks:
- Missing or misconfigured security headers (CSP, HSTS, X-Frame-Options)
- Insecure cookie configurations
- CORS misconfigurations
- Exposed API keys or sensitive data in page source
- Missing HTTPS or weak TLS configuration

Provide specific, actionable remediation steps for each issue found.''';
    } else {
      return '''Analyze this LIVE deployed application for monitoring and observability gaps.

${runtimeData.toAnalysisPrompt()}

ANALYSIS INSTRUCTIONS:
1. Review detected monitoring tools - what's present vs. what's missing
2. Identify gaps in analytics, error tracking, and performance monitoring
3. Recommend specific tools and configurations
4. Focus on high-value, business-critical monitoring

Look for monitoring opportunities:
- Missing analytics: If no Google Analytics/Mixpanel detected, recommend installation
- Incomplete analytics: If present, identify missing events (conversions, funnels)
- No error tracking: Recommend Sentry, Bugsnag, or similar
- Missing performance monitoring: Recommend Web Vitals tracking, APM tools
- Business metrics gaps: Conversion tracking, revenue analytics

For each recommendation:
- Explain what's missing and why it matters
- Provide concrete business value (revenue impact, user retention, etc.)
- Give specific, copy-paste ready implementation code
- Prioritize based on potential impact

Remember to acknowledge tools that ARE detected and suggest how to enhance them.''';
    }
  }

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
      analysisMode: analysisMode,
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
      final prompt = _buildSecurityValidationPrompt(issue, updatedCode, repositoryName);

      final response = await _dio.post(
        '/v1/chat/completions',
        data: {
          'model': AppConfig.openaiModel,
          'messages': [
            {'role': 'system', 'content': _getSecurityValidationSystemPrompt()},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.3, // Lower temperature for more focused validation
          'response_format': {'type': 'json_object'},
        },
      );

      final responseData = response.data;
      if (responseData == null || responseData is! Map<String, dynamic>) {
        throw Exception('OpenAI API returned invalid response');
      }

      final content = responseData['choices']?[0]?['message']?['content'];
      if (content == null || content is! String) {
        throw Exception('Missing content in validation response');
      }

      final validationData = jsonDecode(content) as Map<String, dynamic>;
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
      final prompt = _buildMonitoringValidationPrompt(recommendation, updatedCode, repositoryName);

      final response = await _dio.post(
        '/v1/chat/completions',
        data: {
          'model': AppConfig.openaiModel,
          'messages': [
            {'role': 'system', 'content': _getMonitoringValidationSystemPrompt()},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.3,
          'response_format': {'type': 'json_object'},
        },
      );

      final responseData = response.data;
      if (responseData == null || responseData is! Map<String, dynamic>) {
        throw Exception('OpenAI API returned invalid response');
      }

      final content = responseData['choices']?[0]?['message']?['content'];
      if (content == null || content is! String) {
        throw Exception('Missing content in validation response');
      }

      final validationData = jsonDecode(content) as Map<String, dynamic>;
      return _parseValidationResult(validationData);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Validation error: $e');
    }
  }

  String _getSecurityValidationSystemPrompt() {
    return '''You are a security expert validating whether a security vulnerability has been properly fixed.

Your task is to analyze the updated code and determine if the security issue has been resolved.

Return your validation as a JSON object with this exact structure:
{
  "status": "passed" | "failed",
  "summary": "<brief summary of validation result>",
  "details": "<detailed explanation of what was checked and the outcome>",
  "remainingIssues": ["<issue 1>", "<issue 2>"] (only if status is "failed"),
  "recommendation": "<what to do next>" (only if status is "failed")
}

IMPORTANT:
- Set status to "passed" ONLY if the security vulnerability is completely resolved
- Set status to "failed" if the issue persists or the fix is incomplete
- Be specific in your analysis - reference actual code
- If the fix is partial, explain what's missing in remainingIssues''';
  }

  String _getMonitoringValidationSystemPrompt() {
    return '''You are an observability expert validating whether monitoring has been properly implemented.

Your task is to analyze the updated code and determine if the monitoring recommendation has been correctly implemented.

Return your validation as a JSON object with this exact structure:
{
  "status": "passed" | "failed",
  "summary": "<brief summary of validation result>",
  "details": "<detailed explanation of what was checked and the outcome>",
  "remainingIssues": ["<issue 1>", "<issue 2>"] (only if status is "failed"),
  "recommendation": "<what to do next>" (only if status is "failed")
}

IMPORTANT:
- Set status to "passed" ONLY if monitoring is properly implemented
- Set status to "failed" if monitoring is missing or incomplete
- Verify that proper instrumentation, logging, or tracking code exists
- Be specific about what monitoring was implemented or what's missing''';
  }

  String _buildSecurityValidationPrompt(
    SecurityIssue issue,
    String updatedCode,
    String repositoryName,
  ) {
    return '''Repository: $repositoryName

ORIGINAL SECURITY ISSUE:
Title: ${issue.title}
Category: ${issue.category}
Severity: ${issue.severity.value}
Description: ${issue.description}
${issue.filePath != null ? 'File: ${issue.filePath}' : ''}
${issue.lineNumber != null ? 'Line: ${issue.lineNumber}' : ''}

TASK: Validate if this security issue has been fixed in the updated code below.

UPDATED CODE:
$updatedCode

VALIDATION CHECKLIST:
1. Check if the vulnerable code pattern has been removed or fixed
2. Verify that the fix addresses the root cause, not just symptoms
3. Ensure no new security issues were introduced
4. Confirm the fix follows security best practices

Provide your validation result as JSON.''';
  }

  String _buildMonitoringValidationPrompt(
    MonitoringRecommendation recommendation,
    String updatedCode,
    String repositoryName,
  ) {
    return '''Repository: $repositoryName

ORIGINAL MONITORING RECOMMENDATION:
Title: ${recommendation.title}
Category: ${recommendation.category}
Description: ${recommendation.description}
Business Value: ${recommendation.businessValue}
${recommendation.filePath != null ? 'File: ${recommendation.filePath}' : ''}
${recommendation.lineNumber != null ? 'Line: ${recommendation.lineNumber}' : ''}

TASK: Validate if this monitoring recommendation has been implemented in the updated code below.

UPDATED CODE:
$updatedCode

VALIDATION CHECKLIST:
1. Check if monitoring/tracking code has been added
2. Verify it captures the recommended metrics or events
3. Ensure proper instrumentation for the business value described
4. Confirm the monitoring follows best practices

Provide your validation result as JSON.''';
  }

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
