import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analysis_type.dart';
import '../models/analysis_result.dart';
import '../services/github_service.dart';
import '../services/openai_service.dart';
import '../services/storage_service.dart';
import '../services/credits_service.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';

final githubServiceProvider = Provider((ref) => GitHubService());
final openaiServiceProvider = Provider((ref) => OpenAIService());
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
  final StorageService _storageService;
  final CreditsService _creditsService;
  final AuthService _authService;

  AnalysisNotifier(
    this._githubService,
    this._openaiService,
    this._storageService,
    this._creditsService,
    this._authService,
  ) : super(AnalysisState());

  Future<void> analyzeRepository({
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
        progressMessage: 'Cloning repository...',
      );

      // Aggregate code
      final code = await _githubService.aggregateCode(repositoryUrl);

      state = state.copyWith(
        progress: 0.5,
        progressMessage: 'Running AI analysis...',
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
    ref.watch(storageServiceProvider),
    ref.watch(creditsServiceProviderForAnalysis),
    ref.watch(authServiceProviderForAnalysis),
  );
});
