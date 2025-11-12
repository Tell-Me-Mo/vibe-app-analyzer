import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import 'gradient_button.dart';

class AuthButton extends ConsumerWidget {
  const AuthButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🔴 [AUTH BUTTON] Building AuthButton widget');
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final authService = ref.watch(authServiceProvider);

    return userProfileAsync.when(
      data: (profile) {
        // User is not authenticated
        if (profile == null) {
          return _buildLoginButton(context);
        }

        // Check if user is anonymous (guest)
        if (authService.isAnonymous) {
          return _buildGuestButton(context);
        }

        // Show profile button for authenticated users
        return _buildProfileButton(context, profile);
      },
      loading: () => _buildLoadingButton(context),
      error: (error, stackTrace) => _buildLoginButton(context),
    );
  }

  Widget _buildLoadingButton(BuildContext context) {
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

  Widget _buildGuestButton(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/auth'),
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
            color: AppColors.borderDefault,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_outline_rounded,
              size: 18,
              color: AppColors.textTertiary,
            ),
            AppSpacing.horizontalGapSM,
            Text(
              'Guest',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return GradientButton(
      text: 'Sign In',
      icon: Icons.login_rounded,
      onPressed: () => context.go('/auth'),
      height: 44,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context, dynamic profile) {
    return InkWell(
      onTap: () => context.go('/profile'),
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
            color: AppColors.primaryBlue.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: AppElevation.glowSM(AppColors.primaryBlue),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar with gradient border
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: AppColors.gradientPrimary,
                ),
              ),
              padding: const EdgeInsets.all(2),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.backgroundTertiary,
                backgroundImage: profile.photoUrl != null
                    ? NetworkImage(profile.photoUrl!)
                    : null,
                child: profile.photoUrl == null
                    ? ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: AppColors.gradientPrimary,
                        ).createShader(bounds),
                        child: Text(
                          _getInitials(profile),
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
            AppSpacing.horizontalGapSM,
            Text(
              _getDisplayName(profile),
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(dynamic profile) {
    // Try display name first
    if (profile.displayName != null && profile.displayName!.isNotEmpty) {
      return profile.displayName!.substring(0, 1).toUpperCase();
    }

    // Try email if not empty
    if (profile.email.isNotEmpty) {
      return profile.email.substring(0, 1).toUpperCase();
    }

    // Fallback to 'G' for Guest
    return 'G';
  }

  String _getDisplayName(dynamic profile) {
    // Try display name first
    if (profile.displayName != null && profile.displayName!.isNotEmpty) {
      return profile.displayName!;
    }

    // Try email username if email is not empty
    if (profile.email.isNotEmpty) {
      return profile.email.split('@')[0];
    }

    // Fallback to 'Guest'
    return 'Guest';
  }
}
