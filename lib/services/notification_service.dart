import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

/// Type of notification to display
enum NotificationType {
  success,
  error,
  warning,
  info,
}

/// Centralized notification service for displaying toast notifications
/// Follows modern UI/UX best practices with responsive design
class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  /// Active overlay entries for managing multiple notifications
  final List<OverlayEntry> _activeNotifications = [];

  /// Show a success notification
  static void showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    _instance._showNotification(
      context,
      type: NotificationType.success,
      message: message,
      title: title,
      duration: duration,
      onTap: onTap,
    );
  }

  /// Show an error notification
  static void showError(
    BuildContext context, {
    required String message,
    String? title,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    _instance._showNotification(
      context,
      type: NotificationType.error,
      message: message,
      title: title,
      duration: duration,
      onTap: onTap,
    );
  }

  /// Show a warning notification
  static void showWarning(
    BuildContext context, {
    required String message,
    String? title,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    _instance._showNotification(
      context,
      type: NotificationType.warning,
      message: message,
      title: title,
      duration: duration,
      onTap: onTap,
    );
  }

  /// Show an info notification
  static void showInfo(
    BuildContext context, {
    required String message,
    String? title,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    _instance._showNotification(
      context,
      type: NotificationType.info,
      message: message,
      title: title,
      duration: duration,
      onTap: onTap,
    );
  }

  /// Internal method to show notification
  void _showNotification(
    BuildContext context, {
    required NotificationType type,
    required String message,
    String? title,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    // Calculate duration based on message length (best practice)
    final Duration calculatedDuration = duration ?? _calculateDuration(message);

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _NotificationToast(
        type: type,
        message: message,
        title: title,
        onDismiss: () {
          overlayEntry.remove();
          _activeNotifications.remove(overlayEntry);
        },
        onTap: onTap,
      ),
    );

    _activeNotifications.add(overlayEntry);
    overlay.insert(overlayEntry);

    // Auto-dismiss after duration
    Future.delayed(calculatedDuration, () {
      if (_activeNotifications.contains(overlayEntry)) {
        overlayEntry.remove();
        _activeNotifications.remove(overlayEntry);
      }
    });

    // Update positions of all notifications
    _updateNotificationPositions();
  }

  /// Calculate duration based on message length
  /// Up to 10 words: 4000ms + 1000ms buffer
  /// 10-20 words: 6000ms
  /// 20+ words or with action: no timeout (returns 30 seconds as maximum)
  Duration _calculateDuration(String message) {
    final wordCount = message.split(' ').length;

    if (wordCount <= 10) {
      return const Duration(milliseconds: 5000);
    } else if (wordCount <= 20) {
      return const Duration(milliseconds: 6000);
    } else {
      // For longer messages, use a longer duration but still auto-dismiss
      return const Duration(seconds: 8);
    }
  }

  /// Update positions of all active notifications
  void _updateNotificationPositions() {
    // Notifications will stack vertically with proper spacing
    // This is handled by the widget itself
  }

  /// Dismiss all active notifications
  static void dismissAll() {
    for (final entry in _instance._activeNotifications) {
      entry.remove();
    }
    _instance._activeNotifications.clear();
  }
}

/// Internal widget for displaying notification toast
class _NotificationToast extends StatefulWidget {
  final NotificationType type;
  final String message;
  final String? title;
  final VoidCallback onDismiss;
  final VoidCallback? onTap;

  const _NotificationToast({
    required this.type,
    required this.message,
    required this.onDismiss,
    this.title,
    this.onTap,
  });

  @override
  State<_NotificationToast> createState() => _NotificationToastState();
}

class _NotificationToastState extends State<_NotificationToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    // Position: top-center for desktop, top-center for mobile
    return Positioned(
      top: AppSpacing.xl,
      left: isDesktop ? null : AppSpacing.lg,
      right: AppSpacing.lg,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Align(
              alignment: isDesktop ? Alignment.topCenter : Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 420 : double.infinity,
                  minWidth: isDesktop ? 360 : double.infinity,
                ),
                child: _buildNotificationContent(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationContent(BuildContext context) {
    final config = _getNotificationConfig(widget.type);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: AppSpacing.horizontalMD,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppRadius.radiusLG,
          border: Border.all(
            color: config.borderColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: config.glowColor.withValues(alpha: 0.2),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
            const BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 16,
              spreadRadius: 0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.radiusLG,
          child: Stack(
            children: [
              // Gradient accent bar on the left
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: config.gradientColors,
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.lg + AppSpacing.xs,
                  right: AppSpacing.lg,
                  top: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: AppSpacing.paddingSM,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: config.gradientColors,
                        ),
                        borderRadius: AppRadius.radiusMD,
                      ),
                      child: Icon(
                        config.icon,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),

                    AppSpacing.horizontalGapMD,

                    // Text content
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.title != null) ...[
                            Text(
                              widget.title!,
                              style: AppTypography.labelLarge.copyWith(
                                decoration: TextDecoration.none,
                              ),
                            ),
                            AppSpacing.verticalGapXS,
                          ],
                          Text(
                            widget.message,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              decoration: TextDecoration.none,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    AppSpacing.horizontalGapSM,

                    // Close button
                    GestureDetector(
                      onTap: _dismiss,
                      child: Container(
                        padding: AppSpacing.paddingXS,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHover,
                          borderRadius: AppRadius.radiusSM,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _NotificationConfig _getNotificationConfig(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return _NotificationConfig(
          icon: Icons.check_circle_rounded,
          gradientColors: AppColors.gradientSuccess,
          borderColor: AppColors.success,
          glowColor: AppColors.success,
        );
      case NotificationType.error:
        return _NotificationConfig(
          icon: Icons.error_rounded,
          gradientColors: AppColors.gradientError,
          borderColor: AppColors.error,
          glowColor: AppColors.error,
        );
      case NotificationType.warning:
        return _NotificationConfig(
          icon: Icons.warning_rounded,
          gradientColors: AppColors.gradientWarning,
          borderColor: AppColors.warning,
          glowColor: AppColors.warning,
        );
      case NotificationType.info:
        return _NotificationConfig(
          icon: Icons.info_rounded,
          gradientColors: AppColors.gradientPrimary,
          borderColor: AppColors.primaryBlue,
          glowColor: AppColors.primaryBlue,
        );
    }
  }
}

/// Configuration for notification appearance
class _NotificationConfig {
  final IconData icon;
  final List<Color> gradientColors;
  final Color borderColor;
  final Color glowColor;

  const _NotificationConfig({
    required this.icon,
    required this.gradientColors,
    required this.borderColor,
    required this.glowColor,
  });
}
