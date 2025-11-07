import 'dart:convert';
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
    try {
      final prompt = _buildPrompt(code, analysisType);

      final response = await _dio.post(
        '',
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

      final content = response.data['choices'][0]['message']['content'];
      final analysisData = jsonDecode(content);

      return _parseAnalysisResult(
        repositoryUrl: repositoryUrl,
        repositoryName: repositoryName,
        analysisType: analysisType,
        data: analysisData,
      );
    } catch (e) {
      throw Exception('Failed to analyze code: $e');
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
    final summary = AnalysisSummary.fromJson(data['summary']);

    List<SecurityIssue>? securityIssues;
    List<MonitoringRecommendation>? monitoringRecommendations;

    if (analysisType == AnalysisType.security) {
      securityIssues = (data['issues'] as List?)
          ?.map((issue) => SecurityIssue.fromJson(issue))
          .toList();
    } else {
      monitoringRecommendations = (data['recommendations'] as List?)
          ?.map((rec) => MonitoringRecommendation.fromJson(rec))
          .toList();
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
}
