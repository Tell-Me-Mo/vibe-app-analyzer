import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/analysis_result.dart';
import '../../models/analysis_mode.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../common/animated_card.dart';

class HistoryCard extends StatelessWidget {
  final AnalysisResult result;
  final VoidCallback onTap;

  const HistoryCard({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, HH:mm');
    final isSecurityAnalysis = result.analysisType.displayName == 'Security';
    final gradient = isSecurityAnalysis
        ? AppColors.gradientSecurity
        : AppColors.gradientMonitoring;

    return AnimatedCard(
      onTap: onTap,
      padding: AppSpacing.paddingXL,
      child: Row(
        children: [
          // Modern gradient icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppElevation.glowSM(gradient.first),
            ),
            child: Icon(
              isSecurityAnalysis
                  ? Icons.security_rounded
                  : Icons.show_chart_rounded,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),
          AppSpacing.horizontalGapLG,

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row with DEMO badge
                Row(
                  children: [
                    if (result.isDemo) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'DEMO',
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      AppSpacing.horizontalGapSM,
                    ],
                    Expanded(
                      child: Text(
                        result.repositoryName,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalGapSM,

                // Badges and metadata row
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    // Analysis Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradient.map((c) => c.withValues(alpha: 0.15)).toList(),
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        border: Border.all(
                          color: gradient.first.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        result.analysisType.displayName,
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: gradient.first,
                        ),
                      ),
                    ),

                    // Analysis Mode Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: (result.analysisMode == AnalysisMode.staticCode
                                ? AppColors.primaryPurple
                                : AppColors.success)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        border: Border.all(
                          color: (result.analysisMode == AnalysisMode.staticCode
                                  ? AppColors.primaryPurple
                                  : AppColors.success)
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            result.analysisMode.icon,
                            style: AppTypography.labelSmall,
                          ),
                          AppSpacing.horizontalGapXS,
                          Text(
                            result.analysisMode.shortLabel,
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: result.analysisMode == AnalysisMode.staticCode
                                  ? AppColors.primaryPurple
                                  : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Item count
                    Text(
                      '${result.summary.total} items',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),

                    // Separator
                    Text(
                      '•',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textDisabled,
                      ),
                    ),

                    // Date
                    Text(
                      dateFormat.format(result.timestamp),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.horizontalGapMD,

          // Modern arrow icon
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}
