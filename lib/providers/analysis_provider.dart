import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analysis_type.dart';
import '../models/analysis_mode.dart';
import '../models/analysis_result.dart';
import '../services/github_service.dart';
import '../services/openai_service.dart';
import '../services/app_runtime_service.dart';
import '../services/storage_service.dart';
import '../services/credits_service.dart';
import '../services/analytics_service.dart';
import '../utils/validators.dart';
import 'history_provider.dart';

// Service providers with retry configuration for network failures
final githubServiceProvider = Provider(
  (ref) => GitHubService(),
  retry: (retryCount, error) {
    // Retry GitHub API failures up to 2 times with exponential backoff
    if (retryCount > 2) return null;
    // Don't retry on 404, 403, or validation errors
    if (error.toString().contains('not found') ||
        error.toString().contains('forbidden') ||
        error.toString().contains('Invalid')) {
      return null;
    }
    return Duration(seconds: retryCount * 2); // 2s, 4s
  },
);

final openaiServiceProvider = Provider(
  (ref) => OpenAIService(),
  retry: (retryCount, error) {
    // Retry OpenAI API failures up to 3 times (it already has internal retry)
    if (retryCount > 3) return null;
    // Don't retry on rate limits or auth errors
    if (error.toString().contains('rate limit') ||
        error.toString().contains('unauthorized') ||
        error.toString().contains('API key')) {
      return null;
    }
    return Duration(seconds: retryCount * 3); // 3s, 6s, 9s
  },
);

final appRuntimeServiceProvider = Provider(
  (ref) => AppRuntimeService(),
  retry: (retryCount, error) {
    // Retry runtime analysis failures up to 2 times
    if (retryCount > 2) return null;
    return Duration(seconds: retryCount * 2);
  },
);

final storageServiceProvider = Provider((ref) => StorageService());
final creditsServiceProviderForAnalysis = Provider((ref) => CreditsService());

class AnalysisState {
  final bool isLoading;
  final AnalysisResult? result;
  final String? error;
  final double progress;
  final String? progressMessage;

  AnalysisState({
    this.isLoading = false,
    this.result,
    this.error,
    this.progress = 0.0,
    this.progressMessage,
  });

  AnalysisState copyWith({
    bool? isLoading,
    AnalysisResult? result,
    String? error,
    double? progress,
    String? progressMessage,
  }) {
    return AnalysisState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error ?? this.error,
      progress: progress ?? this.progress,
      progressMessage: progressMessage ?? this.progressMessage,
    );
  }
}

class AnalysisNotifier extends Notifier<AnalysisState> {
  late final GitHubService _githubService;
  late final OpenAIService _openaiService;
  late final AppRuntimeService _appRuntimeService;
  late final StorageService _storageService;
  late final CreditsService _creditsService;

  @override
  AnalysisState build() {
    _githubService = ref.watch(githubServiceProvider);
    _openaiService = ref.watch(openaiServiceProvider);
    _appRuntimeService = ref.watch(appRuntimeServiceProvider);
    _storageService = ref.watch(storageServiceProvider);
    _creditsService = ref.watch(creditsServiceProviderForAnalysis);

    return AnalysisState();
  }

  /// Main analysis method that routes to static code or runtime analysis
  Future<void> analyze({
    required String url,
    required AnalysisType analysisType,
    required AnalysisMode analysisMode,
  }) async {
    // Route to appropriate analysis method
    if (analysisMode == AnalysisMode.staticCode) {
      return _analyzeStaticCode(
        repositoryUrl: url,
        analysisType: analysisType,
      );
    } else {
      return _analyzeRuntimeApp(
        appUrl: url,
        analysisType: analysisType,
      );
    }
  }

  /// Analyzes static code from GitHub repository
  Future<void> _analyzeStaticCode({
    required String repositoryUrl,
    required AnalysisType analysisType,
  }) async {
    // Sanitize URL (adds https:// if missing)
    final sanitizedUrl = Validators.sanitizeGitHubUrl(repositoryUrl);
    if (sanitizedUrl == null) {
      state = state.copyWith(
        error: 'Enter a valid GitHub repository URL',
      );
      return;
    }

    final startTime = DateTime.now();

    try {
      // Track analysis start
      await AnalyticsService().logAnalysisStarted(
        codeType: 'github_repository',
      );

      // Consume credits before starting analysis (database-only operation)
      final consumed = await _creditsService.consumeCredits(5);
      if (!consumed) {
        state = state.copyWith(
          error: 'Insufficient credits. Please purchase more credits to continue.',
        );
        return;
      }

      state = state.copyWith(
        isLoading: true,
        error: null,
        progress: 0.1,
        progressMessage: 'Validating repository...',
      );

      // Get repository info (use sanitized URL)
      final repoInfo = await _githubService.getRepository(sanitizedUrl);
      if (!ref.mounted) return;

      final repositoryName = repoInfo['name'];

      state = state.copyWith(
        progress: 0.3,
        progressMessage: 'Fetching repository code...',
      );

      // Aggregate code (use sanitized URL)
      final code = await _githubService.aggregateCode(sanitizedUrl);
      if (!ref.mounted) return;

      state = state.copyWith(
        progress: 0.5,
        progressMessage: 'Running AI code analysis...',
      );

      // Analyze with OpenAI (use sanitized URL)
      final result = await _openaiService.analyzeCode(
        repositoryUrl: sanitizedUrl,
        repositoryName: repositoryName,
        code: code,
        analysisType: analysisType,
      );
      if (!ref.mounted) return;

      state = state.copyWith(
        progress: 0.9,
        progressMessage: 'Saving results...',
      );

      // Save to history - MUST complete before setting result
      print('📝 [STATIC ANALYSIS] Starting to save analysis with ID: ${result.id}');
      await _storageService.saveAnalysis(result);
      print('📝 [STATIC ANALYSIS] ✅ Save completed for ID: ${result.id}');
      if (!ref.mounted) return;

      // Invalidate history provider to force reload of fresh data
      print('📝 [STATIC ANALYSIS] Invalidating history provider');
      ref.invalidate(historyProvider);

      // Small delay to ensure data is persisted and provider is refreshed
      await Future.delayed(const Duration(milliseconds: 100));
      print('📝 [STATIC ANALYSIS] Delay completed, setting result in state');
      if (!ref.mounted) return;

      state = state.copyWith(
        isLoading: false,
        result: result,
        progress: 1.0,
        progressMessage: 'Analysis complete!',
      );
      print('📝 [STATIC ANALYSIS] ✅ Result set in state, navigation should trigger');

      // Track successful analysis completion
      final duration = DateTime.now().difference(startTime);
      final totalIssues = (result.securityIssues?.length ?? 0) +
                         (result.monitoringRecommendations?.length ?? 0);
      await AnalyticsService().logAnalysisCompleted(
        codeType: 'github_repository',
        issuesFound: totalIssues,
        durationMs: duration.inMilliseconds,
      );
    } catch (e) {
      // Refund credits on error (database-only operation)
      await _creditsService.refundCredits(5);

      if (!ref.mounted) return;

      // Track analysis error
      await AnalyticsService().logEvent(
        name: 'analysis_error',
        parameters: {
          'error_type': 'static_code_analysis',
          'error_message': e.toString(),
        },
      );

      state = state.copyWith(
        isLoading: false,
        error: 'Analysis failed: ${e.toString()}',
        progress: 0.0,
        progressMessage: null,
      );
    }
  }

  /// Analyzes a live deployed application
  Future<void> _analyzeRuntimeApp({
    required String appUrl,
    required AnalysisType analysisType,
  }) async {
    // Sanitize URL (adds https:// if missing)
    final sanitizedUrl = Validators.sanitizeAppUrl(appUrl);
    if (sanitizedUrl == null) {
      state = state.copyWith(
        error: 'Enter a valid application URL',
      );
      return;
    }

    final startTime = DateTime.now();

    try {
      // Track analysis start
      await AnalyticsService().logAnalysisStarted(
        codeType: 'runtime_app',
      );

      // Consume credits before starting analysis (database-only operation)
      final consumed = await _creditsService.consumeCredits(5);
      if (!consumed) {
        state = state.copyWith(
          error: 'Insufficient credits. Please purchase more credits to continue.',
        );
        return;
      }

      state = state.copyWith(
        isLoading: true,
        error: null,
        progress: 0.1,
        progressMessage: 'Connecting to application...',
      );

      // Fetch and analyze runtime data (use sanitized URL)
      final runtimeData = await _appRuntimeService.analyzeApp(sanitizedUrl);
      if (!ref.mounted) return;

      // Extract app name from URL
      final uri = Uri.parse(sanitizedUrl);
      final appName = uri.host;

      state = state.copyWith(
        progress: 0.4,
        progressMessage: 'Analyzing security configuration...',
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (!ref.mounted) return;

      state = state.copyWith(
        progress: 0.6,
        progressMessage: 'Running AI runtime analysis...',
      );

      // Analyze with OpenAI (use sanitized URL)
      final result = await _openaiService.analyzeRuntimeApp(
        appUrl: sanitizedUrl,
        appName: appName,
        runtimeData: runtimeData,
        analysisType: analysisType,
      );
      if (!ref.mounted) return;

      state = state.copyWith(
        progress: 0.9,
        progressMessage: 'Saving results...',
      );

      // Save to history - MUST complete before setting result
      print('📝 [RUNTIME ANALYSIS] Starting to save analysis with ID: ${result.id}');
      await _storageService.saveAnalysis(result);
      print('📝 [RUNTIME ANALYSIS] ✅ Save completed for ID: ${result.id}');
      if (!ref.mounted) return;

      // Invalidate history provider to force reload of fresh data
      print('📝 [RUNTIME ANALYSIS] Invalidating history provider');
      ref.invalidate(historyProvider);

      // Small delay to ensure data is persisted and provider is refreshed
      await Future.delayed(const Duration(milliseconds: 100));
      print('📝 [RUNTIME ANALYSIS] Delay completed, setting result in state');
      if (!ref.mounted) return;

      state = state.copyWith(
        isLoading: false,
        result: result,
        progress: 1.0,
        progressMessage: 'Analysis complete!',
      );
      print('📝 [RUNTIME ANALYSIS] ✅ Result set in state, navigation should trigger');

      // Track successful analysis completion
      final duration = DateTime.now().difference(startTime);
      final totalIssues = (result.securityIssues?.length ?? 0) +
                         (result.monitoringRecommendations?.length ?? 0);
      await AnalyticsService().logAnalysisCompleted(
        codeType: 'runtime_app',
        issuesFound: totalIssues,
        durationMs: duration.inMilliseconds,
      );
    } catch (e) {
      // Refund credits on error (database-only operation)
      await _creditsService.refundCredits(5);

      if (!ref.mounted) return;

      // Track analysis error
      await AnalyticsService().logEvent(
        name: 'analysis_error',
        parameters: {
          'error_type': 'runtime_app_analysis',
          'error_message': e.toString(),
        },
      );

      state = state.copyWith(
        isLoading: false,
        error: 'Analysis failed: ${e.toString()}',
        progress: 0.0,
        progressMessage: null,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = AnalysisState();
  }
}

final analysisProvider = NotifierProvider<AnalysisNotifier, AnalysisState>(() {
  return AnalysisNotifier();
});
