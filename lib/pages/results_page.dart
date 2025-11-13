import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/analysis_result.dart';
import '../models/analysis_type.dart';
import '../models/analysis_mode.dart';
import '../models/security_issue.dart';
import '../models/monitoring_recommendation.dart';
import '../providers/history_provider.dart';
import '../providers/validation_provider.dart';
import '../services/notification_service.dart';
import '../services/analytics_service.dart';
import '../data/demo_data.dart';
import '../widgets/results/issue_card.dart';
import '../widgets/results/recommendation_card.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/common/gradient_icon.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  AnalysisResult? _getResult(WidgetRef ref) {
    print('🔍 [RESULTS PAGE] Looking for result with ID: ${widget.resultId}');
    final history = ref.read(historyProvider);
    print('🔍 [RESULTS PAGE] History size: ${history.length}');

    if (history.isNotEmpty) {
      print('🔍 [RESULTS PAGE] History IDs: ${history.map((r) => r.id).toList()}');
    }

    // Try to find in history first
    for (final result in history) {
      if (result.id == widget.resultId) {
        print('🔍 [RESULTS PAGE] ✅ Found result in history!');
        return result;
      }
    }

    print('🔍 [RESULTS PAGE] Not found in history, checking demo data...');
    // Then try demo data
    for (final result in DemoData.demoExamples) {
      if (result.id == widget.resultId) {
        print('🔍 [RESULTS PAGE] ✅ Found result in demo data!');
        return result;
      }
    }

    print('🔍 [RESULTS PAGE] ❌ Result not found anywhere!');
    return null;
  }

  Future<void> _handleValidateSecurityIssue(SecurityIssue issue) async {
    final result = _getResult(ref);
    if (result == null || !mounted) return;

    // Track validation initiation
    await AnalyticsService().logEvent(
      name: 'validation_initiated',
      parameters: {
        'validation_type': 'security_issue',
        'severity': issue.severity,
        'issue_title': issue.title,
      },
    );

    // Extract repository name from URL
    final repositoryName = result.repositoryUrl?.split('/').last.replaceAll('.git', '') ?? 'Unknown';

    await ref.read(validationProvider.notifier).validateSecurityFix(
          context: context,
          resultId: result.id,
          issue: issue,
          repositoryUrl: result.repositoryUrl ?? '',
          repositoryName: repositoryName,
          onInsufficientCredits: () {
            if (!mounted) return;
            NotificationService.showWarning(
              context,
              title: 'Insufficient Credits',
              message: 'Please purchase more credits to validate fixes.',
            );
            // Track insufficient credits during validation
            AnalyticsService().logEvent(
              name: 'validation_insufficient_credits',
              parameters: {
                'validation_type': 'security_issue',
              },
            );
          },
        );
  }

  Future<void> _handleValidateMonitoringRecommendation(MonitoringRecommendation recommendation) async {
    final result = _getResult(ref);
    if (result == null || !mounted) return;

    // Track validation initiation
    await AnalyticsService().logEvent(
      name: 'validation_initiated',
      parameters: {
        'validation_type': 'monitoring_recommendation',
        'category': recommendation.category,
        'recommendation_title': recommendation.title,
      },
    );

    // Extract repository name from URL
    final repositoryName = result.repositoryUrl?.split('/').last.replaceAll('.git', '') ?? 'Unknown';

    await ref.read(validationProvider.notifier).validateMonitoringImplementation(
          context: context,
          resultId: result.id,
          recommendation: recommendation,
          repositoryUrl: result.repositoryUrl ?? '',
          repositoryName: repositoryName,
          onInsufficientCredits: () {
            if (!mounted) return;
            NotificationService.showWarning(
              context,
              title: 'Insufficient Credits',
              message: 'Please purchase more credits to validate implementations.',
            );
            // Track insufficient credits during validation
            AnalyticsService().logEvent(
              name: 'validation_insufficient_credits',
              parameters: {
                'validation_type': 'monitoring_recommendation',
              },
            );
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    // Watch history and validation state to rebuild when validation completes
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
                size: 80,
                color: AppColors.textMuted,
              ),
              AppSpacing.verticalGapXL,
              Text(
                'Analysis not found',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              AppSpacing.verticalGapXL,
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
      body: Stack(
        children: [
          // Background gradient
          _buildBackgroundGradient(),

          SafeArea(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingXXL,
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
                          // Header with back button
                          _buildModernHeader(context, result, gradient),
                          AppSpacing.verticalGapHuge,

                          // Summary
                          _buildModernSummary(context, result, gradient, dateFormat),
                          AppSpacing.verticalGapHuge,

                          // Results
                          _buildResultsList(context, result),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              AppColors.primaryBlue.withValues(alpha: 0.06),
              AppColors.backgroundPrimary.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(
    BuildContext context,
    AnalysisResult result,
    List<Color> gradient,
  ) {
    return Row(
      children: [
        // Back button
        IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back_rounded),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceGlass.withValues(alpha: 0.6),
          ),
        ),
        AppSpacing.horizontalGapLG,

        // Gradient icon with glow
        GradientIcon(
          icon: result.analysisType == AnalysisType.security
              ? Icons.security_rounded
              : Icons.show_chart_rounded,
          size: 32,
          gradient: gradient,
          padding: AppSpacing.paddingLG,
        ),
        AppSpacing.horizontalGapLG,

        // Title and URL
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.repositoryName,
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.verticalGapSM,

              // Copyable URL
              InkWell(
                onTap: () async {
                  await Clipboard.setData(
                    ClipboardData(text: result.repositoryUrl),
                  );
                  if (context.mounted) {
                    NotificationService.showSuccess(
                      context,
                      message: 'Repository URL copied to clipboard!',
                    );
                  }
                },
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        result.repositoryUrl,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primaryBlue,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppSpacing.horizontalGapSM,
                    Icon(
                      Icons.copy_rounded,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernSummary(
    BuildContext context,
    AnalysisResult result,
    List<Color> gradient,
    DateFormat dateFormat,
  ) {
    return GlassCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compact header - responsive layout
              if (isMobile) ...[
                // Mobile: Stack vertically
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: gradient,
                          ).createShader(bounds),
                          child: const Icon(
                            Icons.analytics_rounded,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                        AppSpacing.horizontalGapSM,
                        Text(
                          'Analysis Summary',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalGapSM,
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _buildCompactBadge(
                          result.analysisType.displayName,
                          gradient.first,
                          Icons.shield_rounded,
                        ),
                        _buildCompactBadge(
                          result.analysisMode.shortLabel,
                          result.analysisMode == AnalysisMode.staticCode
                              ? AppColors.primaryPurple
                              : AppColors.success,
                          result.analysisMode == AnalysisMode.staticCode
                              ? Icons.code_rounded
                              : Icons.apps_rounded,
                        ),
                        _buildCompactBadge(
                          dateFormat.format(result.timestamp),
                          AppColors.textTertiary,
                          Icons.access_time_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ] else ...[
                // Desktop: Horizontal layout
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: gradient,
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.analytics_rounded,
                        color: AppColors.textPrimary,
                        size: 22,
                      ),
                    ),
                    AppSpacing.horizontalGapMD,
                    Text(
                      'Analysis Summary',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _buildCompactBadge(
                          result.analysisType.displayName,
                          gradient.first,
                          Icons.shield_rounded,
                        ),
                        _buildCompactBadge(
                          result.analysisMode.shortLabel,
                          result.analysisMode == AnalysisMode.staticCode
                              ? AppColors.primaryPurple
                              : AppColors.success,
                          result.analysisMode == AnalysisMode.staticCode
                              ? Icons.code_rounded
                              : Icons.apps_rounded,
                        ),
                        _buildCompactBadge(
                          dateFormat.format(result.timestamp),
                          AppColors.textTertiary,
                          Icons.access_time_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
              AppSpacing.verticalGapXL,

              // Summary stats - responsive grid
              _buildStatsGrid(result, isMobile),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(AnalysisResult result, bool isMobile) {
    if (isMobile) {
      // Mobile: Horizontal scrollable chips - super compact
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildCompactStatChip(
              'Total',
              result.summary.total,
              AppColors.textPrimary,
              null,
              result,
            ),
            const SizedBox(width: 8),
            _buildCompactStatChip(
              'Critical',
              result.summary.bySeverity?['critical'] ?? 0,
              AppColors.severityCritical,
              'critical',
              result,
            ),
            const SizedBox(width: 8),
            _buildCompactStatChip(
              'High',
              result.summary.bySeverity?['high'] ?? 0,
              AppColors.severityHigh,
              'high',
              result,
            ),
            const SizedBox(width: 8),
            _buildCompactStatChip(
              'Medium',
              result.summary.bySeverity?['medium'] ?? 0,
              AppColors.severityMedium,
              'medium',
              result,
            ),
            const SizedBox(width: 8),
            _buildCompactStatChip(
              'Low',
              result.summary.bySeverity?['low'] ?? 0,
              AppColors.severityLow,
              'low',
              result,
            ),
          ],
        ),
      );
    }

    // Desktop: All in one row or 3-2 grid based on width
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        return isWide
            ? Row(
                children: [
                  Expanded(
                    child: _buildFilterableStatCard(
                      'Total',
                      result.summary.total,
                      AppColors.textPrimary,
                      null,
                      result,
                    ),
                  ),
                  AppSpacing.horizontalGapMD,
                  Expanded(
                    child: _buildFilterableStatCard(
                      'Critical',
                      result.summary.bySeverity?['critical'] ?? 0,
                      AppColors.severityCritical,
                      'critical',
                      result,
                    ),
                  ),
                  AppSpacing.horizontalGapMD,
                  Expanded(
                    child: _buildFilterableStatCard(
                      'High',
                      result.summary.bySeverity?['high'] ?? 0,
                      AppColors.severityHigh,
                      'high',
                      result,
                    ),
                  ),
                  AppSpacing.horizontalGapMD,
                  Expanded(
                    child: _buildFilterableStatCard(
                      'Medium',
                      result.summary.bySeverity?['medium'] ?? 0,
                      AppColors.severityMedium,
                      'medium',
                      result,
                    ),
                  ),
                  AppSpacing.horizontalGapMD,
                  Expanded(
                    child: _buildFilterableStatCard(
                      'Low',
                      result.summary.bySeverity?['low'] ?? 0,
                      AppColors.severityLow,
                      'low',
                      result,
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildFilterableStatCard(
                          'Total',
                          result.summary.total,
                          AppColors.textPrimary,
                          null,
                          result,
                        ),
                      ),
                      AppSpacing.horizontalGapMD,
                      Expanded(
                        child: _buildFilterableStatCard(
                          'Critical',
                          result.summary.bySeverity?['critical'] ?? 0,
                          AppColors.severityCritical,
                          'critical',
                          result,
                        ),
                      ),
                      AppSpacing.horizontalGapMD,
                      Expanded(
                        child: _buildFilterableStatCard(
                          'High',
                          result.summary.bySeverity?['high'] ?? 0,
                          AppColors.severityHigh,
                          'high',
                          result,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalGapMD,
                  Row(
                    children: [
                      Expanded(
                        child: _buildFilterableStatCard(
                          'Medium',
                          result.summary.bySeverity?['medium'] ?? 0,
                          AppColors.severityMedium,
                          'medium',
                          result,
                        ),
                      ),
                      AppSpacing.horizontalGapMD,
                      Expanded(
                        child: _buildFilterableStatCard(
                          'Low',
                          result.summary.bySeverity?['low'] ?? 0,
                          AppColors.severityLow,
                          'low',
                          result,
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              );
      },
    );
  }

  Widget _buildCompactBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          AppSpacing.horizontalGapXS,
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // Compact stat chip for mobile - minimal, modern style
  Widget _buildCompactStatChip(
    String label,
    int count,
    Color color,
    String? severity,
    AnalysisResult result,
  ) {
    final isSelected = severity != null && _selectedSeverities.contains(severity);
    final isDisabled = count == 0;
    final isFilterable = result.analysisType == AnalysisType.security && !isDisabled;

    return InkWell(
      onTap: !isFilterable ? null : () {
        setState(() {
          if (severity == null) {
            _selectedSeverities.clear();
          } else {
            if (_selectedSeverities.contains(severity)) {
              _selectedSeverities.remove(severity);
            } else {
              _selectedSeverities.add(severity);
            }
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : color.withValues(alpha: 0.25),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: AppTypography.titleLarge.copyWith(
                color: isDisabled ? color.withValues(alpha: 0.3) : color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isDisabled
                    ? AppColors.textTertiary.withValues(alpha: 0.4)
                    : AppColors.textTertiary,
                fontWeight: FontWeight.w500,
                fontSize: 10,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterableStatCard(
    String label,
    int count,
    Color color,
    String? severity,
    AnalysisResult result,
  ) {
    final isSelected = severity != null && _selectedSeverities.contains(severity);
    final isDisabled = count == 0;
    // Only enable filtering for security analysis
    final isFilterable = result.analysisType == AnalysisType.security && !isDisabled;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 150;

        return InkWell(
          onTap: !isFilterable ? null : () {
            setState(() {
              if (severity == null) {
                // "Total" clears all filters
                _selectedSeverities.clear();
              } else {
                if (_selectedSeverities.contains(severity)) {
                  _selectedSeverities.remove(severity);
                } else {
                  _selectedSeverities.add(severity);
                }
              }
            });
          },
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? AppSpacing.sm : AppSpacing.md,
              vertical: isMobile ? AppSpacing.sm : AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.2)
                  : color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected
                    ? color.withValues(alpha: 0.5)
                    : color.withValues(alpha: 0.15),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$count',
                  style: AppTypography.headlineMedium.copyWith(
                    color: isDisabled ? color.withValues(alpha: 0.3) : color,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 20 : 24,
                  ),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: isDisabled
                        ? AppColors.textTertiary.withValues(alpha: 0.4)
                        : AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 10 : 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultsList(BuildContext context, AnalysisResult result) {
    // Filter issues based on selected severities (only for security analysis)
    final filteredSecurityIssues = _selectedSeverities.isEmpty
        ? (result.securityIssues ?? [])
        : (result.securityIssues ?? [])
            .where((issue) => _selectedSeverities.contains(issue.severity.value))
            .toList();

    // Monitoring recommendations don't have severity, so no filtering
    final filteredRecommendations = result.monitoringRecommendations ?? [];

    final totalItems = result.analysisType == AnalysisType.security
        ? result.securityIssues?.length ?? 0
        : result.monitoringRecommendations?.length ?? 0;

    final filteredCount = result.analysisType == AnalysisType.security
        ? filteredSecurityIssues.length
        : filteredRecommendations.length;

    final showingFiltered = _selectedSeverities.isNotEmpty &&
                            result.analysisType == AnalysisType.security;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title with gradient accent and filter info
        Row(
          children: [
            Container(
              width: 4,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: result.analysisType == AnalysisType.security
                      ? AppColors.gradientSecurity
                      : AppColors.gradientMonitoring,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AppSpacing.horizontalGapMD,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.analysisType == AnalysisType.security
                        ? 'Security Issues'
                        : 'Recommendations',
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 20,
                    ),
                  ),
                  if (showingFiltered) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Showing $filteredCount of $totalItems',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Clear filters button
            if (showingFiltered)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedSeverities.clear();
                  });
                },
                icon: const Icon(Icons.clear_rounded, size: 16),
                label: const Text('Clear filters'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  textStyle: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        AppSpacing.verticalGapXL,

        // List of filtered issues/recommendations
        if (filteredCount == 0)
          Center(
            child: Padding(
              padding: AppSpacing.paddingXXL,
              child: Column(
                children: [
                  Icon(
                    Icons.filter_alt_off_rounded,
                    size: 48,
                    color: AppColors.textTertiary.withValues(alpha: 0.5),
                  ),
                  AppSpacing.verticalGapMD,
                  Text(
                    'No items match the selected filters',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (result.analysisType == AnalysisType.security)
          ...filteredSecurityIssues.map(
            (issue) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
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
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: RecommendationCard(
                recommendation: recommendation,
                repositoryUrl: result.repositoryUrl,
                onValidate: _handleValidateMonitoringRecommendation,
              ),
            ),
          ),
      ],
    );
  }
}
