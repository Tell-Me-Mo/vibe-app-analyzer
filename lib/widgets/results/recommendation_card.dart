import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/monitoring_recommendation.dart';
import '../../models/validation_status.dart';
import '../../services/notification_service.dart';
import '../common/severity_badge.dart';
import '../common/category_badge.dart';
import '../common/validation_status_badge.dart';
import '../common/validation_result_display.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';

class RecommendationCard extends StatefulWidget {
  final MonitoringRecommendation recommendation;
  final String? repositoryUrl;
  final Function(MonitoringRecommendation)? onValidate;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.repositoryUrl,
    this.onValidate,
  });

  @override
  State<RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<RecommendationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Container(
          margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundTertiary,
            borderRadius: AppRadius.radiusLG,
            border: Border.all(color: AppColors.borderSubtle, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                  bottom: Radius.circular(_isExpanded ? 0 : AppRadius.lg),
                ),
                child: Padding(
                  padding: AppSpacing.paddingLG,
                  child: isMobile
                      ? _buildMobileHeader(context)
                      : _buildDesktopHeader(context),
                ),
              ),
              if (_isExpanded) ...[
                const Divider(height: 1, color: AppColors.borderSubtle),
                Padding(
                  padding: AppSpacing.paddingLG,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      Text(
                        widget.recommendation.description,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      AppSpacing.verticalGapLG,

                      // Business Value
                      Container(
                        padding: AppSpacing.paddingMD,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.08),
                          borderRadius: AppRadius.radiusMD,
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.trending_up_rounded,
                              color: AppColors.success,
                              size: 20,
                            ),
                            AppSpacing.horizontalGapMD,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Business Value',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.recommendation.businessValue,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.verticalGapLG,

                      // Claude Code Prompt
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSecondary,
                          borderRadius: AppRadius.radiusMD,
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundPrimary,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(7),
                                ),
                                border: const Border(
                                  bottom: BorderSide(
                                    color: AppColors.borderSubtle,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.terminal_rounded,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Claude Code Prompt',
                                        style: AppTypography.labelSmall
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text: widget
                                              .recommendation
                                              .claudeCodePrompt,
                                        ),
                                      );
                                      NotificationService.showSuccess(
                                        context,
                                        message: 'Prompt copied!',
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(4),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.copy_rounded,
                                            size: 14,
                                            color: AppColors.primaryBlue,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Copy',
                                            style: AppTypography.labelSmall
                                                .copyWith(
                                                  color: AppColors.primaryBlue,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Content
                            Padding(
                              padding: AppSpacing.paddingMD,
                              child: Text(
                                widget.recommendation.claudeCodePrompt,
                                style: AppTypography.monoMedium.copyWith(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Validation
                      if (widget.recommendation.validationResult != null) ...[
                        AppSpacing.verticalGapLG,
                        ValidationResultDisplay(
                          result: widget.recommendation.validationResult!,
                          onRevalidate: widget.onValidate != null
                              ? () => widget.onValidate!(widget.recommendation)
                              : null,
                          isValidating:
                              widget.recommendation.validationStatus ==
                              ValidationStatus.validating,
                        ),
                      ] else if (widget.onValidate != null) ...[
                        AppSpacing.verticalGapLG,
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed:
                                widget.recommendation.validationStatus ==
                                    ValidationStatus.validating
                                ? null
                                : () =>
                                      widget.onValidate!(widget.recommendation),
                            icon:
                                widget.recommendation.validationStatus ==
                                    ValidationStatus.validating
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 18,
                                  ),
                            label: Text(
                              widget.recommendation.validationStatus ==
                                      ValidationStatus.validating
                                  ? 'Validating...'
                                  : 'Validate Implementation (1 credit)',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.recommendation.title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
        AppSpacing.verticalGapSM,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SeverityBadge(severity: widget.recommendation.severity),
            CategoryBadge(
              category: widget.recommendation.category,
              color: _getCategoryColor(widget.recommendation.category),
            ),
            if (widget.recommendation.validationStatus !=
                ValidationStatus.notStarted)
              ValidationStatusBadge(
                status: widget.recommendation.validationStatus,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.recommendation.title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  SeverityBadge(severity: widget.recommendation.severity),
                  AppSpacing.horizontalGapSM,
                  CategoryBadge(
                    category: widget.recommendation.category,
                    color: _getCategoryColor(widget.recommendation.category),
                  ),
                  if (widget.recommendation.validationStatus !=
                      ValidationStatus.notStarted) ...[
                    AppSpacing.horizontalGapSM,
                    ValidationStatusBadge(
                      status: widget.recommendation.validationStatus,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          _isExpanded
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
          color: AppColors.textTertiary,
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'analytics':
        return Colors.blue.shade400;
      case 'error_tracking':
        return Colors.red.shade400;
      case 'business_metrics':
        return Colors.purple.shade400;
      default:
        return Colors.grey.shade400;
    }
  }
}
