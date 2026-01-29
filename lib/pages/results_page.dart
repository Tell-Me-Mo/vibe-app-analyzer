import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/analysis_result.dart';
import '../models/analysis_type.dart';
import '../models/security_issue.dart';
import '../models/monitoring_recommendation.dart';
import '../providers/history_provider.dart';
import '../providers/validation_provider.dart';
import '../services/notification_service.dart';
import '../services/analytics_service.dart';
import '../data/demo_data.dart';
import '../widgets/results/issue_card.dart';
import '../widgets/results/recommendation_card.dart';
import '../widgets/common/gradient_icon.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../services/export_service.dart';
import '../widgets/results/feedback_widget.dart';

class ResultsPage extends ConsumerStatefulWidget {
  final String resultId;

  const ResultsPage({super.key, required this.resultId});

  @override
  ConsumerState<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends ConsumerState<ResultsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Selected severity filters
  final Set<String> _selectedSeverities = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  AnalysisResult? _getResult(WidgetRef ref) {
    final history = ref.read(historyProvider);
    // Try to find in history first
    for (final result in history) {
      if (result.id == widget.resultId) return result;
    }
    // Then try demo data
    for (final result in DemoData.demoExamples) {
      if (result.id == widget.resultId) return result;
    }
    return null;
  }

  Future<void> _handleValidateSecurityIssue(SecurityIssue issue) async {
    final result = _getResult(ref);
    if (result == null || !mounted) return;

    await AnalyticsService().logEvent(
      name: 'validation_initiated',
      parameters: {
        'validation_type': 'security_issue',
        'severity': issue.severity.toString().split('.').last,
        'issue_title': issue.title,
      },
    );

    if (!mounted) return;

    final repositoryName = result.repositoryUrl
        .split('/')
        .last
        .replaceAll('.git', '');

    await ref
        .read(validationProvider.notifier)
        .validateSecurityFix(
          context: context,
          resultId: result.id,
          issue: issue,
          repositoryUrl: result.repositoryUrl,
          repositoryName: repositoryName,
          analysisMode: result.analysisMode,
          onInsufficientCredits: () {
            if (!mounted) return;
            NotificationService.showWarning(
              context,
              title: 'Insufficient Credits',
              message: 'Please purchase more credits to validate fixes.',
            );
          },
        );
  }

  Future<void> _handleValidateMonitoringRecommendation(
    MonitoringRecommendation recommendation,
  ) async {
    final result = _getResult(ref);
    if (result == null || !mounted) return;

    await AnalyticsService().logEvent(
      name: 'validation_initiated',
      parameters: {
        'validation_type': 'monitoring_recommendation',
        'category': recommendation.category.toString().split('.').last,
        'recommendation_title': recommendation.title,
      },
    );

    if (!mounted) return;

    final repositoryName = result.repositoryUrl
        .split('/')
        .last
        .replaceAll('.git', '');

    await ref
        .read(validationProvider.notifier)
        .validateMonitoringImplementation(
          context: context,
          resultId: result.id,
          recommendation: recommendation,
          repositoryUrl: result.repositoryUrl,
          repositoryName: repositoryName,
          analysisMode: result.analysisMode,
          onInsufficientCredits: () {
            if (!mounted) return;
            NotificationService.showWarning(
              context,
              title: 'Insufficient Credits',
              message:
                  'Please purchase more credits to validate implementations.',
            );
          },
        );
  }

  void _showBadgeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.backgroundTertiary,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusXL,
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: AppSpacing.paddingXL,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: AppColors.primaryBlue,
                    ),
                    AppSpacing.horizontalGapMD,
                    Text('Get Your Badge', style: AppTypography.headlineSmall),
                  ],
                ),
                AppSpacing.verticalGapLG,
                Text(
                  'Add this badge to your README.md to show your code is Vibe Checked.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                AppSpacing.verticalGapLG,
                Container(
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: AppRadius.radiusMD,
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '[![Vibe Check](https://img.shields.io/badge/Vibe-Checked-blue)](https://vibe-checker.dev)',
                          style: AppTypography.monoMedium.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(
                            const ClipboardData(
                              text:
                                  '[![Vibe Check](https://img.shields.io/badge/Vibe-Checked-blue)](https://vibe-checker.dev)',
                            ),
                          );
                          Navigator.pop(context);
                          NotificationService.showSuccess(
                            context,
                            message: 'Badge markdown copied!',
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 20),
                        tooltip: 'Copy Markdown',
                      ),
                    ],
                  ),
                ),
                AppSpacing.verticalGapLG,
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(historyProvider);
    ref.watch(validationProvider);

    final result = _getResult(ref);

    if (result == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: AppColors.textMuted,
              ),
              AppSpacing.verticalGapLG,
              Text(
                'Analysis not found',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.verticalGapLG,
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Go back home'),
              ),
            ],
          ),
        ),
      );
    }

    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');
    final isSecurityAnalysis = result.analysisType == AnalysisType.security;
    final gradient = isSecurityAnalysis
        ? AppColors.gradientSecurity
        : AppColors.gradientMonitoring;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLG,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, result, gradient),
                      AppSpacing.verticalGapXL,
                      _buildSummarySection(
                        context,
                        result,
                        gradient,
                        dateFormat,
                      ),
                      AppSpacing.verticalGapXL,
                      _buildResultsList(context, result),
                      AppSpacing.verticalGapXXL,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AnalysisResult result,
    List<Color> gradient,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.arrow_back_rounded),
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
              ),
              AppSpacing.verticalGapMD,
              Row(
                children: [
                  GradientIcon(
                    icon: result.analysisType == AnalysisType.security
                        ? Icons.security_rounded
                        : Icons.show_chart_rounded,
                    size: 28,
                    gradient: gradient,
                    padding: EdgeInsets.zero,
                  ),
                  AppSpacing.horizontalGapMD,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.repositoryName,
                          style: AppTypography.headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () async {
                            await Clipboard.setData(
                              ClipboardData(text: result.repositoryUrl),
                            );
                            if (context.mounted) {
                              NotificationService.showSuccess(
                                context,
                                message: 'URL copied!',
                              );
                            }
                          },
                          child: Text(
                            result.repositoryUrl,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalGapLG,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showBadgeDialog(context),
                      icon: const Icon(Icons.verified_rounded, size: 16),
                      label: const Text('Get Badge'),
                    ),
                  ),
                  AppSpacing.horizontalGapMD,
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => ExportService().downloadReport(result),
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text('Export'),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            IconButton(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Back',
            ),
            AppSpacing.horizontalGapLG,
            GradientIcon(
              icon: result.analysisType == AnalysisType.security
                  ? Icons.security_rounded
                  : Icons.show_chart_rounded,
              size: 32,
              gradient: gradient,
              padding: AppSpacing.paddingSM,
            ),
            AppSpacing.horizontalGapMD,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.repositoryName,
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(text: result.repositoryUrl),
                      );
                      if (context.mounted) {
                        NotificationService.showSuccess(
                          context,
                          message: 'URL copied!',
                        );
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          result.repositoryUrl,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        AppSpacing.horizontalGapXS,
                        Icon(
                          Icons.copy_rounded,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _showBadgeDialog(context),
              icon: const Icon(Icons.verified_rounded, size: 18),
              label: const Text('Get Badge'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
            AppSpacing.horizontalGapMD,
            ElevatedButton.icon(
              onPressed: () => ExportService().downloadReport(result),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Export Report'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    AnalysisResult result,
    List<Color> gradient,
    DateFormat dateFormat,
  ) {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Analysis Summary',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildTag(
                result.analysisType.displayName,
                gradient.first.withValues(alpha: 0.1),
                gradient.first,
              ),
              AppSpacing.horizontalGapSM,
              _buildTag(
                dateFormat.format(result.timestamp),
                AppColors.backgroundTertiary,
                AppColors.textSecondary,
              ),
            ],
          ),
          AppSpacing.verticalGapLG,
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;

              if (isMobile) {
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      'Total Issues',
                      result.summary.total,
                      AppColors.textPrimary,
                      null,
                    ),
                    _buildStatCard(
                      'Critical',
                      result.summary.bySeverity?['critical'] ?? 0,
                      AppColors.severityCritical,
                      'critical',
                    ),
                    _buildStatCard(
                      'High',
                      result.summary.bySeverity?['high'] ?? 0,
                      AppColors.severityHigh,
                      'high',
                    ),
                    _buildStatCard(
                      'Medium',
                      result.summary.bySeverity?['medium'] ?? 0,
                      AppColors.severityMedium,
                      'medium',
                    ),
                    _buildStatCard(
                      'Low',
                      result.summary.bySeverity?['low'] ?? 0,
                      AppColors.severityLow,
                      'low',
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total',
                      result.summary.total,
                      AppColors.textPrimary,
                      null,
                    ),
                  ),
                  AppSpacing.horizontalGapMD,
                  Expanded(
                    child: _buildStatCard(
                      'Critical',
                      result.summary.bySeverity?['critical'] ?? 0,
                      AppColors.severityCritical,
                      'critical',
                    ),
                  ),
                  AppSpacing.horizontalGapMD,
                  Expanded(
                    child: _buildStatCard(
                      'High',
                      result.summary.bySeverity?['high'] ?? 0,
                      AppColors.severityHigh,
                      'high',
                    ),
                  ),
                  AppSpacing.horizontalGapMD,
                  Expanded(
                    child: _buildStatCard(
                      'Medium',
                      result.summary.bySeverity?['medium'] ?? 0,
                      AppColors.severityMedium,
                      'medium',
                    ),
                  ),
                  AppSpacing.horizontalGapMD,
                  Expanded(
                    child: _buildStatCard(
                      'Low',
                      result.summary.bySeverity?['low'] ?? 0,
                      AppColors.severityLow,
                      'low',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    int count,
    Color color,
    String? severity,
  ) {
    final isSelected =
        severity != null && _selectedSeverities.contains(severity);
    final isDisabled = count == 0;
    final isFilterable = !isDisabled && severity != null;

    return InkWell(
      onTap: isFilterable
          ? () {
              setState(() {
                if (_selectedSeverities.contains(severity)) {
                  _selectedSeverities.remove(severity);
                } else {
                  _selectedSeverities.add(severity);
                }
              });
            }
          : null,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: AppSpacing.paddingMD,
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : AppColors.backgroundTertiary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count.toString(),
              style: AppTypography.headlineMedium.copyWith(
                color: isDisabled ? AppColors.textMuted : color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, AnalysisResult result) {
    final filteredSecurityIssues = _selectedSeverities.isEmpty
        ? (result.securityIssues ?? [])
        : (result.securityIssues ?? [])
              .where(
                (issue) => _selectedSeverities.contains(issue.severity.value),
              )
              .toList();

    final filteredRecommendations = _selectedSeverities.isEmpty
        ? (result.monitoringRecommendations ?? [])
        : (result.monitoringRecommendations ?? [])
              .where((rec) => _selectedSeverities.contains(rec.severity.value))
              .toList();

    final totalItems = result.analysisType == AnalysisType.security
        ? result.securityIssues?.length ?? 0
        : result.monitoringRecommendations?.length ?? 0;

    final filteredCount = result.analysisType == AnalysisType.security
        ? filteredSecurityIssues.length
        : filteredRecommendations.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              result.analysisType == AnalysisType.security
                  ? 'Security Issues'
                  : 'Recommendations',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.horizontalGapSM,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '$filteredCount / $totalItems',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const Spacer(),
            if (_selectedSeverities.isNotEmpty)
              TextButton.icon(
                onPressed: () => setState(() => _selectedSeverities.clear()),
                icon: const Icon(Icons.clear_rounded, size: 14),
                label: const Text('Clear Filters'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        AppSpacing.verticalGapLG,
        if (filteredCount == 0)
          Center(
            child: Padding(
              padding: AppSpacing.paddingXXL,
              child: Column(
                children: [
                  Icon(
                    Icons.filter_list_off_rounded,
                    size: 48,
                    color: AppColors.textMuted,
                  ),
                  AppSpacing.verticalGapMD,
                  Text(
                    'No items match filters',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (result.analysisType == AnalysisType.security)
          ...filteredSecurityIssues.map(
            (issue) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: IssueCard(
                issue: issue,
                repositoryUrl: result.repositoryUrl,
                onValidate: _handleValidateSecurityIssue,
              ),
            ),
          )
        else
          ...filteredRecommendations.map(
            (recommendation) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: RecommendationCard(
                recommendation: recommendation,
                repositoryUrl: result.repositoryUrl,
                onValidate: _handleValidateMonitoringRecommendation,
              ),
            ),
          ),

        if (filteredCount > 0) ...[
          AppSpacing.verticalGapXXL,
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: FeedbackWidget(resultId: result.id),
            ),
          ),
        ],
      ],
    );
  }
}
