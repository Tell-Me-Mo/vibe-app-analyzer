import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Card with hover and tap animations
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final List<BoxShadow>? shadows;
  final bool enableHoverEffect;
  final bool enableScaleEffect;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.shadows,
    this.enableHoverEffect = true,
    this.enableScaleEffect = true,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enableScaleEffect) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enableScaleEffect) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enableScaleEffect) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: widget.onTap != null ? _handleTapDown : null,
        onTapUp: widget.onTap != null ? _handleTapUp : null,
        onTapCancel: _handleTapCancel,
        child: ScaleTransition(
          scale: widget.enableScaleEffect ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: widget.margin,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? AppRadius.xl),
              border: Border.all(
                color: widget.enableHoverEffect && _isHovered
                    ? AppColors.borderDefault
                    : AppColors.borderSubtle,
                width: 1,
              ),
              boxShadow: widget.enableHoverEffect && _isHovered
                  ? AppElevation.cardShadowHover
                  : (widget.shadows ?? AppElevation.cardShadow),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(widget.borderRadius ?? AppRadius.xl),
                child: Container(
                  padding: widget.padding ?? AppSpacing.paddingXXL,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
