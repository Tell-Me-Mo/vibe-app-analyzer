import 'package:flutter/material.dart';
import '../../services/analytics_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../common/glass_card.dart';

class FeedbackWidget extends StatefulWidget {
  final String resultId;

  const FeedbackWidget({super.key, required this.resultId});

  @override
  State<FeedbackWidget> createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  bool? _isPositive;
  bool _hasSubmitted = false;

  Future<void> _submitFeedback(bool isPositive) async {
    if (_hasSubmitted) return;

    setState(() {
      _isPositive = isPositive;
      _hasSubmitted = true;
    });

    await AnalyticsService().logFeedback(
      resultId: widget.resultId,
      isPositive: isPositive,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _hasSubmitted ? _buildThankYouMessage() : _buildFeedbackForm(),
        ),
      ),
    );
  }

  Widget _buildFeedbackForm() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Was this analysis helpful?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        AppSpacing.horizontalGapLG,
        _buildFeedbackButton(
          icon: Icons.thumb_up_rounded,
          label: 'Yes',
          color: AppColors.success,
          onTap: () => _submitFeedback(true),
        ),
        AppSpacing.horizontalGapMD,
        _buildFeedbackButton(
          icon: Icons.thumb_down_rounded,
          label: 'No',
          color: AppColors.error,
          onTap: () => _submitFeedback(false),
        ),
      ],
    );
  }

  Widget _buildThankYouMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
        AppSpacing.horizontalGapMD,
        Text(
          'Thanks for your feedback!',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusMD,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderSubtle),
          borderRadius: AppRadius.radiusMD,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
