import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Modern gradient icon with glow effect
class GradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final List<Color>? gradient;
  final bool showGlow;
  final EdgeInsetsGeometry? padding;

  const GradientIcon({
    super.key,
    required this.icon,
    this.size = 48,
    this.gradient,
    this.showGlow = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = gradient ?? AppColors.gradientPrimary;

    return Container(
      padding: padding ?? AppSpacing.paddingLG,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: showGlow
            ? AppElevation.glowLG(gradientColors.first)
            : null,
      ),
      child: Icon(
        icon,
        size: size,
        color: AppColors.textPrimary,
      ),
    );
  }
}

/// Gradient border icon container
class GradientBorderIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final List<Color>? gradient;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;

  const GradientBorderIcon({
    super.key,
    required this.icon,
    this.size = 48,
    this.gradient,
    this.borderWidth = 2,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = gradient ?? AppColors.gradientPrimary;

    return Container(
      padding: padding ?? AppSpacing.paddingLG,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        padding: AppSpacing.paddingLG,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.backgroundTertiary,
        ),
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Icon(
            icon,
            size: size,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
