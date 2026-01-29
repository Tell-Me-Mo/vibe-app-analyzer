import 'package:flutter/material.dart';
import '../../models/credit_package.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import 'gradient_button.dart';
import 'animated_card.dart';

/// Modern pricing card for credit packages
class PricingCard extends StatelessWidget {
  final CreditPackage package;
  final VoidCallback onPurchase;
  final bool isLoading;

  const PricingCard({
    super.key,
    required this.package,
    required this.onPurchase,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Mobile-first compact layout
    if (isMobile) {
      return AnimatedCard(
        padding: AppSpacing.paddingLG,
        backgroundColor: package.isPopular
            ? AppColors.surfaceElevated
            : AppColors.backgroundTertiary,
        shadows: package.isPopular
            ? AppElevation.glowMD(AppColors.primaryBlue)
            : AppElevation.cardShadow,
        child: Row(
          children: [
            // Left side: Credits icon and count
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      AppColors.accentCyan,
                      AppColors.accentTeal,
                    ],
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.stars_rounded,
                    size: 32,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.verticalGapXS,
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      AppColors.accentCyan,
                      AppColors.accentTeal,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    '${package.credits}',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'credits',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            AppSpacing.horizontalGapLG,

            // Right side: Package info and button
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Package name with popular badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          package.name,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (package.isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppColors.gradientPrimary,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            'POPULAR',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                    ],
                  ),
                  AppSpacing.verticalGapXS,

                  // Description
                  Text(
                    package.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.verticalGapSM,

                  // Price and savings
                  Row(
                    children: [
                      Text(
                        package.priceDisplay,
                        style: AppTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (package.savings != null) ...[
                        AppSpacing.horizontalGapSM,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            '${package.savings}%',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.successLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  AppSpacing.verticalGapSM,

                  // Purchase button
                  GradientButton(
                    text: 'Purchase',
                    onPressed: isLoading ? null : onPurchase,
                    isLoading: isLoading,
                    gradient: package.isPopular
                        ? AppColors.gradientPrimary
                        : null,
                    isOutlined: !package.isPopular,
                    height: 40,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Desktop layout remains the same
    return AnimatedCard(
      padding: AppSpacing.paddingXXL,
      backgroundColor: package.isPopular
          ? AppColors.surfaceElevated
          : AppColors.backgroundTertiary,
      shadows: package.isPopular
          ? AppElevation.glowMD(AppColors.primaryBlue)
          : AppElevation.cardShadow,
      child: Stack(
        children: [
          // Popular badge
          if (package.isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.gradientPrimary,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  boxShadow: AppElevation.glowSM(AppColors.primaryBlue),
                ),
                child: Text(
                  'POPULAR',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Package name
              Text(
                package.name,
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.verticalGapSM,

              // Description
              Text(
                package.description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const Spacer(),

              // Credits display with icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        AppColors.accentCyan,
                        AppColors.accentTeal,
                      ],
                    ).createShader(bounds),
                    child: const Icon(
                      Icons.stars_rounded,
                      size: 40,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  AppSpacing.horizontalGapMD,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                AppColors.accentCyan,
                                AppColors.accentTeal,
                              ],
                            ).createShader(bounds),
                            child: Text(
                              '${package.credits}',
                              style: AppTypography.displaySmall.copyWith(
                                fontSize: 40,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          AppSpacing.horizontalGapXS,
                          Text(
                            'credits',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              AppSpacing.verticalGapXL,

              // Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    package.priceDisplay,
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (package.savings != null) ...[
                    AppSpacing.horizontalGapMD,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Save ${package.savings}%',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.successLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              AppSpacing.verticalGapXL,

              // Purchase button
              GradientButton(
                text: 'Purchase',
                onPressed: isLoading ? null : onPurchase,
                isLoading: isLoading,
                gradient: package.isPopular
                    ? AppColors.gradientPrimary
                    : null,
                isOutlined: !package.isPopular,
                height: 48,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
