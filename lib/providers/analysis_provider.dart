import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analysis_type.dart';
import '../models/analysis_mode.dart';
import '../models/analysis_result.dart';
import '../services/github_service.dart';
import '../services/openai_service.dart';
import '../services/app_runtime_service.dart';
import '../services/storage_service.dart';
import '../services/credits_service.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';

final githubServiceProvider = Provider((ref) => GitHubService());
final openaiServiceProvider = Provider((ref) => OpenAIService());
final appRuntimeServiceProvider = Provider((ref) => AppRuntimeService());
final storageServiceProvider = Provider((ref) => StorageService());
final creditsServiceProviderForAnalysis = Provider((ref) => CreditsService());
final authServiceProviderForAnalysis = Provider((ref) => AuthService());

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

class AnalysisNotifier extends StateNotifier<AnalysisState> {
  final GitHubService _githubService;
  final OpenAIService _openaiService;
  final AppRuntimeService _appRuntimeService;
  final StorageService _storageService;
  final CreditsService _creditsService;
  final AuthService _authService;

  AnalysisNotifier(
    this._githubService,
    this._openaiService,
    this._appRuntimeService,
    this._storageService,
    this._creditsService,
    this._authService,
  ) : super(AnalysisState());

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
    if (!Validators.isValidGitHubUrl(repositoryUrl)) {
      state = state.copyWith(
        error: 'Please enter a valid GitHub repository URL',
      );
      return;
    }

    try {
      // Consume credits before starting analysis
      final consumed = await _creditsService.consumeCredits(5);
      if (!consumed) {
        state = state.copyWith(
          error: 'Insufficient credits. Please purchase more credits to continue.',
        );
        return;
      }

      // Sync credits with database if user is authenticated
      if (_authService.isSignedIn) {
        final currentCredits = await _creditsService.getCredits();
        await _authService.updateCredits(currentCredits);
      }

      state = state.copyWith(
        isLoading: true,
        error: null,
        progress: 0.1,
        progressMessage: 'Validating repository...',
      );

      // Get repository info
      final repoInfo = await _githubService.getRepository(repositoryUrl);
      final repositoryName = repoInfo['name'];

      state = state.copyWith(
        progress: 0.3,
        progressMessage: 'Fetching repository code...',
      );

      // Aggregate code
      final code = await _githubService.aggregateCode(repositoryUrl);

      state = state.copyWith(
        progress: 0.5,
        progressMessage: 'Running AI code analysis...',
      );

      // Analyze with OpenAI
      final result = await _openaiService.analyzeCode(
        repositoryUrl: repositoryUrl,
        repositoryName: repositoryName,
        code: code,
        analysisType: analysisType,
      );

      state = state.copyWith(
        progress: 0.9,
        progressMessage: 'Generating recommendations...',
      );

      // Save to history
      await _storageService.saveAnalysis(result);

      state = state.copyWith(
        isLoading: false,
        result: result,
        progress: 1.0,
        progressMessage: 'Analysis complete!',
      );
    } catch (e) {
      // Refund credits on error
      await _creditsService.refundCredits(5);

      // Sync with database
      if (_authService.isSignedIn) {
        final currentCredits = await _creditsService.getCredits();
        await _authService.updateCredits(currentCredits);
      }

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
    if (!Validators.isValidAppUrl(appUrl)) {
      state = state.copyWith(
        error: 'Please enter a valid application URL',
      );
      return;
    }

    try {
      // Consume credits before starting analysis
      final consumed = await _creditsService.consumeCredits(5);
      if (!consumed) {
        state = state.copyWith(
          error: 'Insufficient credits. Please purchase more credits to continue.',
        );
        return;
      }

      // Sync credits with database if user is authenticated
      if (_authService.isSignedIn) {
        final currentCredits = await _creditsService.getCredits();
        await _authService.updateCredits(currentCredits);
      }

      state = state.copyWith(
        isLoading: true,
        error: null,
        progress: 0.1,
        progressMessage: 'Connecting to application...',
      );

      // Fetch and analyze runtime data
      final runtimeData = await _appRuntimeService.analyzeApp(appUrl);

      // Extract app name from URL
      final uri = Uri.parse(appUrl);
      final appName = uri.host;

      state = state.copyWith(
        progress: 0.4,
        progressMessage: 'Analyzing security configuration...',
      );

      await Future.delayed(const Duration(milliseconds: 500));

      state = state.copyWith(
        progress: 0.6,
        progressMessage: 'Running AI runtime analysis...',
      );

      // Analyze with OpenAI
      final result = await _openaiService.analyzeRuntimeApp(
        appUrl: appUrl,
        appName: appName,
        runtimeData: runtimeData,
        analysisType: analysisType,
      );

      state = state.copyWith(
        progress: 0.9,
        progressMessage: 'Generating recommendations...',
      );

      // Save to history
      await _storageService.saveAnalysis(result);

      state = state.copyWith(
        isLoading: false,
        result: result,
        progress: 1.0,
        progressMessage: 'Analysis complete!',
      );
    } catch (e) {
      // Refund credits on error
      await _creditsService.refundCredits(5);

      // Sync with database
      if (_authService.isSignedIn) {
        final currentCredits = await _creditsService.getCredits();
        await _authService.updateCredits(currentCredits);
      }

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

final analysisProvider =
    StateNotifierProvider<AnalysisNotifier, AnalysisState>((ref) {
  return AnalysisNotifier(
    ref.watch(githubServiceProvider),
    ref.watch(openaiServiceProvider),
    ref.watch(appRuntimeServiceProvider),
    ref.watch(storageServiceProvider),
    ref.watch(creditsServiceProviderForAnalysis),
    ref.watch(authServiceProviderForAnalysis),
  );
});
