import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analysis_result.dart';
import '../models/security_issue.dart';
import '../models/monitoring_recommendation.dart';
import '../models/validation_status.dart';
import '../services/validation_service.dart';
import '../services/notification_service.dart';
import '../services/analytics_service.dart';
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

      // Set status to validating immediately for UI feedback
      final validatingIssue = issue.copyWith(
        validationStatus: ValidationStatus.validating,
      );
      await _updateIssueInResult(resultId, validatingIssue);

      // Perform validation
      final updatedIssue = await _validationService.validateSecurityFix(
        issue: issue,
        repositoryUrl: repositoryUrl,
        repositoryName: repositoryName,
      );

      // Update the issue in the analysis result
      await _updateIssueInResult(resultId, updatedIssue);

      // Show success notification
      if (context.mounted) {
        NotificationService.showSuccess(
          context,
          title: 'Validation Complete',
          message: updatedIssue.validationResult?.status.displayName ?? 'Validation complete',
        );
      }

      // Track successful validation
      await AnalyticsService().logEvent(
        name: 'validation_completed',
        parameters: {
          'validation_type': 'security_issue',
          'severity': issue.severity,
          'validation_result': updatedIssue.validationResult?.status.toString(),
        },
      );
    } on InsufficientCreditsException catch (e) {
      if (context.mounted) {
        NotificationService.showWarning(
          context,
          title: 'Insufficient Credits',
          message: e.message,
        );
      }
      onInsufficientCredits();
    } catch (e) {
      // Track validation error
      await AnalyticsService().logEvent(
        name: 'validation_error',
        parameters: {
          'validation_type': 'security_issue',
          'error_message': e.toString(),
        },
      );

      if (context.mounted) {
        NotificationService.showError(
          context,
          title: 'Validation Failed',
          message: e.toString(),
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

      // Set status to validating immediately for UI feedback
      final validatingRecommendation = recommendation.copyWith(
        validationStatus: ValidationStatus.validating,
      );
      await _updateRecommendationInResult(resultId, validatingRecommendation);

      // Perform validation
      final updatedRecommendation =
          await _validationService.validateMonitoringImplementation(
        recommendation: recommendation,
        repositoryUrl: repositoryUrl,
        repositoryName: repositoryName,
      );

      // Update the recommendation in the analysis result
      await _updateRecommendationInResult(resultId, updatedRecommendation);

      // Show success notification
      if (context.mounted) {
        NotificationService.showSuccess(
          context,
          title: 'Validation Complete',
          message: updatedRecommendation.validationResult?.status.displayName ??
              'Validation complete',
        );
      }

      // Track successful validation
      await AnalyticsService().logEvent(
        name: 'validation_completed',
        parameters: {
          'validation_type': 'monitoring_recommendation',
          'category': recommendation.category,
          'validation_result': updatedRecommendation.validationResult?.status.toString(),
        },
      );
    } on InsufficientCreditsException catch (e) {
      if (context.mounted) {
        NotificationService.showWarning(
          context,
          title: 'Insufficient Credits',
          message: e.message,
        );
      }
      onInsufficientCredits();
    } catch (e) {
      // Track validation error
      await AnalyticsService().logEvent(
        name: 'validation_error',
        parameters: {
          'validation_type': 'monitoring_recommendation',
          'error_message': e.toString(),
        },
      );

      if (context.mounted) {
        NotificationService.showError(
          context,
          title: 'Validation Failed',
          message: e.toString(),
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
