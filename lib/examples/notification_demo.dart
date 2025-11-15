import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

/// Demo page to test the notification service
/// This file is for development/testing purposes only
class NotificationDemoPage extends StatelessWidget {
  const NotificationDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text('Notification Demo', style: AppTypography.titleLarge),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: AppSpacing.paddingXL,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Test Notification Service',
                  style: AppTypography.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                AppSpacing.verticalGapXXL,

                // Success notification
                ElevatedButton.icon(
                  onPressed: () {
                    NotificationService.showSuccess(
                      context,
                      title: 'Success',
                      message: 'Operation completed successfully!',
                    );
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Show Success'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: AppSpacing.verticalLG,
                  ),
                ),

                AppSpacing.verticalGapLG,

                // Error notification
                ElevatedButton.icon(
                  onPressed: () {
                    NotificationService.showError(
                      context,
                      title: 'Error',
                      message: 'Something went wrong. Please try again.',
                    );
                  },
                  icon: const Icon(Icons.error),
                  label: const Text('Show Error'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: AppSpacing.verticalLG,
                  ),
                ),

                AppSpacing.verticalGapLG,

                // Warning notification
                ElevatedButton.icon(
                  onPressed: () {
                    NotificationService.showWarning(
                      context,
                      title: 'Warning',
                      message: 'You are running low on credits. Please top up.',
                    );
                  },
                  icon: const Icon(Icons.warning),
                  label: const Text('Show Warning'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    padding: AppSpacing.verticalLG,
                  ),
                ),

                AppSpacing.verticalGapLG,

                // Info notification
                ElevatedButton.icon(
                  onPressed: () {
                    NotificationService.showInfo(
                      context,
                      title: 'Info',
                      message: 'New features are now available in the app!',
                    );
                  },
                  icon: const Icon(Icons.info),
                  label: const Text('Show Info'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    padding: AppSpacing.verticalLG,
                  ),
                ),

                AppSpacing.verticalGapLG,

                // Long message notification
                ElevatedButton.icon(
                  onPressed: () {
                    NotificationService.showSuccess(
                      context,
                      title: 'Long Message Test',
                      message: 'This is a longer message to test how the notification handles multiple lines of text. It should truncate properly and maintain good readability across different screen sizes.',
                    );
                  },
                  icon: const Icon(Icons.text_fields),
                  label: const Text('Show Long Message'),
                  style: ElevatedButton.styleFrom(
                    padding: AppSpacing.verticalLG,
                  ),
                ),

                AppSpacing.verticalGapLG,

                // No title notification
                ElevatedButton.icon(
                  onPressed: () {
                    NotificationService.showSuccess(
                      context,
                      message: 'Copied to clipboard!',
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Show No Title'),
                  style: ElevatedButton.styleFrom(
                    padding: AppSpacing.verticalLG,
                  ),
                ),

                AppSpacing.verticalGapXXL,

                OutlinedButton(
                  onPressed: () {
                    NotificationService.dismissAll();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: AppSpacing.verticalLG,
                  ),
                  child: const Text('Dismiss All Notifications'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
