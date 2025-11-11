import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analysis_result.dart';
import '../models/security_issue.dart';
import '../models/monitoring_recommendation.dart';
import '../models/validation_status.dart';
import '../services/validation_service.dart';
import 'history_provider.dart';

/// Provider for managing validation state and operations
class ValidationNotifier extends Notifier<Map<String, dynamic>> {
  late final ValidationService _validationService;
  late final HistoryNotifier _historyNotifier;

  @override
  Map<String, dynamic> build() {
    _validationService = ref.watch(validationServiceProvider);
    _historyNotifier = ref.watch(historyProvider.notifier);
    return {};
  }

  /// Validates a security issue fix
  Future<void> validateSecurityFix({
    required BuildContext context,
    required String resultId,
    required SecurityIssue issue,
    required String repositoryUrl,
    required String repositoryName,
    required VoidCallback onInsufficientCredits,
  }) async {
    try {
      // Check credits first
      if (!await _validationService.canValidate()) {
        onInsufficientCredits();
        return;
      }

      // Perform validation
      final updatedIssue = await _validationService.validateSecurityFix(
        issue: issue,
        repositoryUrl: repositoryUrl,
        repositoryName: repositoryName,
      );

      // Update the issue in the analysis result
      await _updateIssueInResult(resultId, updatedIssue);

      // Show success snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedIssue.validationResult?.status.displayName ?? 'Validation complete',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } on InsufficientCreditsException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      onInsufficientCredits();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Validation failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Validates a monitoring recommendation implementation
  Future<void> validateMonitoringImplementation({
    required BuildContext context,
    required String resultId,
    required MonitoringRecommendation recommendation,
    required String repositoryUrl,
    required String repositoryName,
    required VoidCallback onInsufficientCredits,
  }) async {
    try {
      // Check credits first
      if (!await _validationService.canValidate()) {
        onInsufficientCredits();
        return;
      }

      // Perform validation
      final updatedRecommendation =
          await _validationService.validateMonitoringImplementation(
        recommendation: recommendation,
        repositoryUrl: repositoryUrl,
        repositoryName: repositoryName,
      );

      // Update the recommendation in the analysis result
      await _updateRecommendationInResult(resultId, updatedRecommendation);

      // Show success snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedRecommendation.validationResult?.status.displayName ??
                  'Validation complete',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } on InsufficientCreditsException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      onInsufficientCredits();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Validation failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Updates a security issue in the analysis result
  Future<void> _updateIssueInResult(
    String resultId,
    SecurityIssue updatedIssue,
  ) async {
    final result = _historyNotifier.getById(resultId);
    if (result == null) return;

    final updatedIssues = result.securityIssues?.map((issue) {
      return issue.id == updatedIssue.id ? updatedIssue : issue;
    }).toList();

    final updatedResult = AnalysisResult(
      id: result.id,
      repositoryUrl: result.repositoryUrl,
      repositoryName: result.repositoryName,
      analysisType: result.analysisType,
      timestamp: result.timestamp,
      summary: result.summary,
      securityIssues: updatedIssues,
      monitoringRecommendations: result.monitoringRecommendations,
    );

    await _historyNotifier.updateResult(updatedResult);
    state = {...state, resultId: updatedResult};
  }

  /// Updates a monitoring recommendation in the analysis result
  Future<void> _updateRecommendationInResult(
    String resultId,
    MonitoringRecommendation updatedRecommendation,
  ) async {
    final result = _historyNotifier.getById(resultId);
    if (result == null) return;

    final updatedRecommendations = result.monitoringRecommendations?.map((rec) {
      return rec.id == updatedRecommendation.id ? updatedRecommendation : rec;
    }).toList();

    final updatedResult = AnalysisResult(
      id: result.id,
      repositoryUrl: result.repositoryUrl,
      repositoryName: result.repositoryName,
      analysisType: result.analysisType,
      timestamp: result.timestamp,
      summary: result.summary,
      securityIssues: result.securityIssues,
      monitoringRecommendations: updatedRecommendations,
    );

    await _historyNotifier.updateResult(updatedResult);
    state = {...state, resultId: updatedResult};
  }
}

/// Provider for validation notifier
final validationProvider =
    NotifierProvider<ValidationNotifier, Map<String, dynamic>>(() {
  return ValidationNotifier();
});
