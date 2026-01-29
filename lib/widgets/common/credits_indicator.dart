import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/credits_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';

class CreditsIndicator extends ConsumerWidget {
  const CreditsIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🟡 [CREDITS INDICATOR] Building CreditsIndicator widget');
    final creditsAsync = ref.watch(creditsProvider);

    return creditsAsync.when(
      data: (credits) => _buildModernIndicator(context, credits, isLoading: false),
      loading: () => _buildLoadingIndicator(context),
      error: (error, stackTrace) => _buildModernIndicator(context, 0, isLoading: false),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryBlue.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernIndicator(BuildContext context, int credits, {bool isLoading = false}) {
    // Determine color based on credits
    Color color;
    List<Color> gradient;
    if (credits >= 20) {
      color = AppColors.success;
      gradient = AppColors.gradientSuccess;
    } else if (credits >= 10) {
      color = AppColors.primaryBlue;
      gradient = AppColors.gradientPrimary;
    } else if (credits >= 5) {
      color = AppColors.warning;
      gradient = AppColors.gradientWarning;
    } else {
      color = AppColors.error;
      gradient = AppColors.gradientError;
    }

    return InkWell(
      onTap: () => context.go('/credits'),
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: color.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: AppElevation.glowSM(color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gradient icon
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: gradient,
              ).createShader(bounds),
              child: const Icon(
                Icons.stars_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            AppSpacing.horizontalGapSM,

            // Credits count with gradient
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: gradient,
              ).createShader(bounds),
              child: Text(
                '$credits',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            AppSpacing.horizontalGapXS,

            // "credits" text
            Text(
              'credits',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            AppSpacing.horizontalGapSM,

            // Add icon with subtle animation
            Icon(
              Icons.add_circle_outline_rounded,
              color: color.withValues(alpha: 0.6),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
