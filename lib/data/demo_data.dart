import 'package:uuid/uuid.dart';
import '../models/analysis_result.dart';
import '../models/analysis_type.dart';
import '../models/analysis_mode.dart';
import '../models/security_issue.dart';
import '../models/monitoring_recommendation.dart';
import '../models/severity.dart';

class DemoData {
  static final List<AnalysisResult> demoExamples = [
    _securityDemoExample,
    _monitoringDemoExample,
  ];

  static final AnalysisResult _securityDemoExample = AnalysisResult(
    id: 'demo-security-123',
    repositoryUrl: 'https://github.com/demo/ecommerce-app',
    repositoryName: 'ecommerce-app',
    analysisType: AnalysisType.security,
    analysisMode: AnalysisMode.staticCode,
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    summary: AnalysisSummary(
      total: 5,
      bySeverity: {'critical': 2, 'high': 1, 'medium': 1, 'low': 1},
    ),
    securityIssues: [
      SecurityIssue(
        id: const Uuid().v4(),
        title: 'Hardcoded API Keys in Environment File',
        category: 'Secrets Management',
        severity: Severity.critical,
        description:
            'Found hardcoded API keys directly in the codebase. This exposes sensitive credentials to anyone with repository access.',
        aiGenerationRisk:
            'AI assistants often generate example code with placeholder API keys that developers forget to replace with proper environment variables.',
        claudeCodePrompt:
            'Replace all hardcoded API keys in the codebase with environment variables. Create a .env.example file with placeholder values, add .env to .gitignore, and use a package like flutter_dotenv to load environment variables securely.',
      ),
      SecurityIssue(
        id: const Uuid().v4(),
        title: 'Missing Input Validation on User Registration',
        category: 'Input Validation',
        severity: Severity.critical,
        description:
            'User registration endpoint accepts unvalidated input, allowing potential injection attacks and malformed data.',
        aiGenerationRisk:
            'AI-generated code often focuses on happy-path scenarios without implementing comprehensive input validation.',
        claudeCodePrompt:
            'Add input validation to the user registration endpoint. Validate email format, password strength, sanitize all user inputs, and implement rate limiting to prevent abuse.',
      ),
      SecurityIssue(
        id: const Uuid().v4(),
        title: 'Insecure Direct Object References (IDOR)',
        category: 'Authorization',
        severity: Severity.high,
        description:
            'API endpoints expose user data based solely on URL parameters without verifying ownership.',
        aiGenerationRisk:
            'AI models may generate straightforward CRUD operations without considering authorization checks.',
        claudeCodePrompt:
            'Implement authorization middleware that verifies users can only access their own resources. Add ownership checks before returning sensitive data.',
      ),
      SecurityIssue(
        id: const Uuid().v4(),
        title: 'Missing CORS Configuration',
        category: 'Network Security',
        severity: Severity.medium,
        description:
            'API does not properly configure CORS headers, potentially allowing unauthorized cross-origin requests.',
        aiGenerationRisk:
            'AI assistants may omit security headers to simplify initial implementation.',
        claudeCodePrompt:
            'Configure CORS properly by specifying allowed origins, methods, and headers. Restrict to your frontend domain in production.',
      ),
      SecurityIssue(
        id: const Uuid().v4(),
        title: 'Passwords Stored Without Proper Hashing',
        category: 'Cryptography',
        severity: Severity.low,
        description:
            'User passwords are not being hashed with a secure algorithm before storage.',
        aiGenerationRisk:
            'AI may generate simple storage patterns without implementing proper password hashing.',
        claudeCodePrompt:
            'Implement password hashing using bcrypt or argon2. Hash all passwords before storing them in the database and use secure comparison methods for authentication.',
      ),
    ],
    isDemo: true,
  );

  static final AnalysisResult _monitoringDemoExample = AnalysisResult(
    id: const Uuid().v4(),
    repositoryUrl: 'https://github.com/demo/todo-flutter-app',
    repositoryName: 'todo-flutter-app',
    analysisType: AnalysisType.monitoring,
    analysisMode: AnalysisMode.staticCode,
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    summary: AnalysisSummary(
      total: 4,
      byCategory: {'analytics': 2, 'error_tracking': 1, 'business_metrics': 1},
    ),
    monitoringRecommendations: [
      MonitoringRecommendation(
        id: const Uuid().v4(),
        title: 'Track Task Completion Metrics',
        category: 'business_metrics',
        severity: Severity.high,
        description:
            'Missing tracking for key task completion metrics such as completion rate, time to complete, and task abandonment.',
        businessValue:
            'Understanding task completion patterns helps identify UX issues and measure user engagement. Completion rates are critical KPIs for productivity apps.',
        claudeCodePrompt:
            'Add analytics events to track: task creation, task completion, task deletion, and time between creation and completion. Implement a simple event tracking service using Firebase Analytics or a similar tool.',
      ),
      MonitoringRecommendation(
        id: const Uuid().v4(),
        title: 'Implement User Journey Analytics',
        category: 'analytics',
        severity: Severity.medium,
        description:
            'No tracking of user navigation patterns or feature usage across the app.',
        businessValue:
            'User journey analytics reveal which features are most valuable and where users encounter friction, enabling data-driven product decisions.',
        claudeCodePrompt:
            'Implement screen view tracking for all major screens. Track button clicks and feature usage. Add user properties like signup date and feature preferences.',
      ),
      MonitoringRecommendation(
        id: const Uuid().v4(),
        title: 'Add Crash Reporting and Error Tracking',
        category: 'error_tracking',
        severity: Severity.critical,
        description:
            'Application lacks crash reporting and error tracking capabilities.',
        businessValue:
            'Proactive error tracking helps identify and fix issues before they impact many users, improving app reliability and user satisfaction.',
        claudeCodePrompt:
            'Integrate Sentry or Firebase Crashlytics for crash reporting. Wrap async operations in try-catch blocks and log errors with context. Add error boundaries for Flutter widgets.',
      ),
      MonitoringRecommendation(
        id: const Uuid().v4(),
        title: 'Monitor API Response Times',
        category: 'analytics',
        severity: Severity.medium,
        description:
            'No monitoring of API performance or response times that could indicate backend issues.',
        businessValue:
            'Tracking API performance helps identify bottlenecks and degraded user experience before users complain.',
        claudeCodePrompt:
            'Add middleware to measure and log API request/response times. Track slow queries and failed requests. Set up alerts for response times exceeding thresholds.',
      ),
    ],
    isDemo: true,
  );
}
