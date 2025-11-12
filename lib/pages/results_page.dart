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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Insufficient credits. Please purchase more credits to validate fixes.'),
                duration: Duration(seconds: 3),
              ),
            );
          },
        );
  }

  Future<void> _handleValidateMonitoringRecommendation(MonitoringRecommendation recommendation) async {
    final result = _getResult(ref);
    if (result == null || !mounted) return;

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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Insufficient credits. Please purchase more credits to validate implementations.'),
                duration: Duration(seconds: 3),
              ),
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
                          // Back button
                          IconButton(
                            onPressed: () => context.go('/'),
                            icon: const Icon(Icons.arrow_back_rounded),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surfaceGlass.withValues(alpha: 0.6),
                            ),
                          ),
                          AppSpacing.verticalGapXXL,

                          // Header
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.textPrimary,
                            ),
                            AppSpacing.horizontalGapMD,
                            Text(
                              'URL copied to clipboard!',
                              style: AppTypography.bodyMedium,
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
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
                          decoration: TextDecoration.underline,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: gradient,
                ).createShader(bounds),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
              AppSpacing.horizontalGapMD,
              Text(
                'Analysis Summary',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapXL,

          // Badges row
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _buildBadge(
                result.analysisType.displayName,
                gradient.first,
                Icons.shield_rounded,
              ),
              _buildBadge(
                result.analysisMode.shortLabel,
                result.analysisMode == AnalysisMode.staticCode
                    ? AppColors.primaryPurple
                    : AppColors.success,
                result.analysisMode == AnalysisMode.staticCode
                    ? Icons.code_rounded
                    : Icons.apps_rounded,
              ),
              _buildBadge(
                dateFormat.format(result.timestamp),
                AppColors.textTertiary,
                Icons.access_time_rounded,
              ),
            ],
          ),
          AppSpacing.verticalGapXXL,

          // Summary stats - responsive grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return isWide
                  ? Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total',
                            result.summary.total,
                            AppColors.textPrimary,
                          ),
                        ),
                        AppSpacing.horizontalGapLG,
                        Expanded(
                          child: _buildStatCard(
                            'Critical',
                            result.summary.bySeverity?['critical'] ?? 0,
                            AppColors.severityCritical,
                          ),
                        ),
                        AppSpacing.horizontalGapLG,
                        Expanded(
                          child: _buildStatCard(
                            'High',
                            result.summary.bySeverity?['high'] ?? 0,
                            AppColors.severityHigh,
                          ),
                        ),
                        AppSpacing.horizontalGapLG,
                        Expanded(
                          child: _buildStatCard(
                            'Medium',
                            result.summary.bySeverity?['medium'] ?? 0,
                            AppColors.severityMedium,
                          ),
                        ),
                        AppSpacing.horizontalGapLG,
                        Expanded(
                          child: _buildStatCard(
                            'Low',
                            result.summary.bySeverity?['low'] ?? 0,
                            AppColors.severityLow,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total',
                                result.summary.total,
                                AppColors.textPrimary,
                              ),
                            ),
                            AppSpacing.horizontalGapMD,
                            Expanded(
                              child: _buildStatCard(
                                'Critical',
                                result.summary.bySeverity?['critical'] ?? 0,
                                AppColors.severityCritical,
                              ),
                            ),
                            AppSpacing.horizontalGapMD,
                            Expanded(
                              child: _buildStatCard(
                                'High',
                                result.summary.bySeverity?['high'] ?? 0,
                                AppColors.severityHigh,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.verticalGapMD,
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Medium',
                                result.summary.bySeverity?['medium'] ?? 0,
                                AppColors.severityMedium,
                              ),
                            ),
                            AppSpacing.horizontalGapMD,
                            Expanded(
                              child: _buildStatCard(
                                'Low',
                                result.summary.bySeverity?['low'] ?? 0,
                                AppColors.severityLow,
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          AppSpacing.horizontalGapSM,
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: AppTypography.headlineMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.verticalGapXS,
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, AnalysisResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title with gradient accent
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
            Text(
              result.analysisType == AnalysisType.security
                  ? 'Security Issues (${result.securityIssues?.length ?? 0})'
                  : 'Recommendations (${result.monitoringRecommendations?.length ?? 0})',
              style: AppTypography.headlineMedium,
            ),
          ],
        ),
        AppSpacing.verticalGapXXL,

        // List of issues/recommendations
        if (result.analysisType == AnalysisType.security)
          ...(result.securityIssues ?? []).map(
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
          ...(result.monitoringRecommendations ?? []).map(
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
