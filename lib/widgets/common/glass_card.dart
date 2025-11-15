import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Modern glass morphism card with blur effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final bool blurEnabled;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.shadows,
    this.onTap,
    this.blurEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ?? AppSpacing.paddingXXL,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceGlass.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.xl),
        border: Border.all(
          color: borderColor ?? AppColors.borderSubtle,
          width: borderWidth ?? 1,
        ),
        boxShadow: shadows ?? AppElevation.cardShadow,
      ),
      child: child,
    );

    if (!blurEnabled) {
      return onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.xl),
              child: content,
            )
          : content;
    }

    final blurContent = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.xl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: content,
      ),
    );

    return onTap != null
        ? InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.xl),
            child: blurContent,
          )
        : blurContent;
  }
}
