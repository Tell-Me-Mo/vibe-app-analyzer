import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';

/// Modern gradient button with animations
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final List<Color>? gradient;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.height,
    this.padding,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.gradient ?? AppColors.gradientPrimary;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: isEnabled ? _handleTapDown : null,
        onTapUp: isEnabled ? _handleTapUp : null,
        onTapCancel: _handleTapCancel,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.width,
            height: widget.height ?? 56,
            decoration: widget.isOutlined
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      width: 2,
                      color: isEnabled
                          ? gradientColors.first
                          : AppColors.borderDefault,
                    ),
                    boxShadow: _isHovered && isEnabled
                        ? AppElevation.glowMD(gradientColors.first)
                        : null,
                  )
                : BoxDecoration(
                    gradient: LinearGradient(
                      colors: isEnabled
                          ? gradientColors
                          : [AppColors.surfaceGlass, AppColors.surfaceGlass],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: _isHovered && isEnabled
                        ? AppElevation.glowMD(gradientColors.first)
                        : AppElevation.cardShadow,
                  ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isEnabled ? widget.onPressed : null,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Container(
                  padding: widget.padding ??
                      EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                        // Only add vertical padding if no height is specified
                        vertical: widget.height == null ? AppSpacing.lg : 0,
                      ),
                  child: widget.isLoading
                      ? Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.isOutlined
                                    ? gradientColors.first
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                size: 20,
                                color: widget.isOutlined
                                    ? (isEnabled
                                        ? gradientColors.first
                                        : AppColors.textDisabled)
                                    : AppColors.textPrimary,
                              ),
                              AppSpacing.horizontalGapMD,
                            ],
                            Flexible(
                              child: Text(
                                widget.text,
                                style: AppTypography.buttonMedium.copyWith(
                                  color: widget.isOutlined
                                      ? (isEnabled
                                          ? gradientColors.first
                                          : AppColors.textDisabled)
                                      : AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
