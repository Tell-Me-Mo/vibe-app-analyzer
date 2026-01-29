import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/security_issue.dart';
import '../../models/validation_status.dart';
import '../../services/notification_service.dart';
import '../common/severity_badge.dart';
import '../common/category_badge.dart';
import '../common/validation_status_badge.dart';
import '../common/validation_result_display.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';

class IssueCard extends StatefulWidget {
  final SecurityIssue issue;
  final String? repositoryUrl;
  final Function(SecurityIssue)? onValidate;

  const IssueCard({
    super.key,
    required this.issue,
    this.repositoryUrl,
    this.onValidate,
  });

  @override
  State<IssueCard> createState() => _IssueCardState();
}

class _IssueCardState extends State<IssueCard> {
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
                        widget.issue.description,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      AppSpacing.verticalGapLG,

                      // AI Risk Warning
                      Container(
                        padding: AppSpacing.paddingMD,
                        decoration: BoxDecoration(
                          color: AppColors.severityHigh.withValues(alpha: 0.08),
                          borderRadius: AppRadius.radiusMD,
                          border: Border.all(
                            color: AppColors.severityHigh.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.severityHigh,
                              size: 20,
                            ),
                            AppSpacing.horizontalGapMD,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AI Generation Risk',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.severityHigh,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.issue.aiGenerationRisk,
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
                                          text: widget.issue.claudeCodePrompt,
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
                                widget.issue.claudeCodePrompt,
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
                      if (widget.issue.validationResult != null) ...[
                        AppSpacing.verticalGapLG,
                        ValidationResultDisplay(
                          result: widget.issue.validationResult!,
                          onRevalidate: widget.onValidate != null
                              ? () => widget.onValidate!(widget.issue)
                              : null,
                          isValidating:
                              widget.issue.validationStatus ==
                              ValidationStatus.validating,
                        ),
                      ] else if (widget.onValidate != null) ...[
                        AppSpacing.verticalGapLG,
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed:
                                widget.issue.validationStatus ==
                                    ValidationStatus.validating
                                ? null
                                : () => widget.onValidate!(widget.issue),
                            icon:
                                widget.issue.validationStatus ==
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
                              widget.issue.validationStatus ==
                                      ValidationStatus.validating
                                  ? 'Validating...'
                                  : 'Validate Fix (1 credit)',
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
                widget.issue.title,
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
            SeverityBadge(severity: widget.issue.severity),
            CategoryBadge(category: widget.issue.category),
            if (widget.issue.validationStatus != ValidationStatus.notStarted)
              ValidationStatusBadge(status: widget.issue.validationStatus),
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
                widget.issue.title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  SeverityBadge(severity: widget.issue.severity),
                  AppSpacing.horizontalGapSM,
                  CategoryBadge(category: widget.issue.category),
                  if (widget.issue.validationStatus !=
                      ValidationStatus.notStarted) ...[
                    AppSpacing.horizontalGapSM,
                    ValidationStatusBadge(
                      status: widget.issue.validationStatus,
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
}
