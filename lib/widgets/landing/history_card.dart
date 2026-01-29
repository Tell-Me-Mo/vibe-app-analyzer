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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return AnimatedCard(
          onTap: onTap,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 14 : 16,
            vertical: isMobile ? 12 : 10,
          ),
          child: Row(
            children: [
              // Compact gradient icon
              Container(
                width: isMobile ? 44 : 40,
                height: isMobile ? 44 : 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: AppElevation.glowSM(gradient.first),
                ),
                child: Icon(
                  isSecurityAnalysis
                      ? Icons.security_rounded
                      : Icons.show_chart_rounded,
                  color: AppColors.textPrimary,
                  size: isMobile ? 22 : 20,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row with badges
                    Row(
                      children: [
                        if (result.isDemo) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.warning.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              'DEMO',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                                fontSize: 9,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            result.repositoryName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Badges and metadata row
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // Analysis Type Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradient.map((c) => c.withValues(alpha: 0.15)).toList(),
                            ),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: gradient.first.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            result.analysisType.displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: gradient.first,
                              fontSize: 10,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),

                        // Analysis Mode Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (result.analysisMode == AnalysisMode.staticCode
                                    ? AppColors.primaryPurple
                                    : AppColors.success)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
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
                                style: const TextStyle(fontSize: 10),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                result.analysisMode.shortLabel,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: result.analysisMode == AnalysisMode.staticCode
                                      ? AppColors.primaryPurple
                                      : AppColors.success,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Item count
                        Text(
                          '${result.summary.total} items',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),

                        // Separator
                        Text(
                          '•',
                          style: TextStyle(
                            color: AppColors.textDisabled,
                            fontSize: 11,
                          ),
                        ),

                        // Date
                        Text(
                          dateFormat.format(result.timestamp),
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Compact arrow icon
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textMuted,
              ),
            ],
          ),
        );
      },
    );
  }
}
