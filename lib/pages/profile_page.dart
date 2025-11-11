import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../widgets/common/credits_indicator.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/common/gradient_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          _buildBackgroundGradient(),

          SafeArea(
            child: userProfileAsync.when(
              data: (profile) {
                if (profile == null) {
                  // Not signed in, redirect to auth
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      context.go('/auth');
                    }
                  });
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  padding: AppSpacing.paddingXXL,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Back button
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () => context.go('/'),
                                icon: const Icon(Icons.arrow_back_rounded),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.surfaceGlass.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                            AppSpacing.verticalGapXXL,

                            // Profile header
                            _buildProfileHeader(profile),
                            AppSpacing.verticalGapHuge,

                            // Credits section
                            _buildCreditsSection(context),
                            AppSpacing.verticalGapXL,

                            // Account info
                            _buildAccountInfo(profile),
                            AppSpacing.verticalGapHuge,

                            // Sign out button
                            _buildSignOutButton(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryBlue,
                ),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: AppColors.error,
                    ),
                    AppSpacing.verticalGapXL,
                    Text(
                      'Error loading profile',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    AppSpacing.verticalGapMD,
                    Text(
                      error.toString(),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              AppColors.primaryBlue.withValues(alpha: 0.08),
              AppColors.backgroundPrimary.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic profile) {
    return Center(
      child: Column(
        children: [
          // Avatar with gradient border
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: AppColors.gradientPrimary,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: AppElevation.glowLG(AppColors.primaryBlue),
            ),
            padding: const EdgeInsets.all(4),
            child: CircleAvatar(
              radius: 56,
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
                        profile.displayName?.substring(0, 1).toUpperCase() ??
                            profile.email.substring(0, 1).toUpperCase(),
                        style: AppTypography.displayMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 48,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          AppSpacing.verticalGapXL,

          // Name
          Text(
            profile.displayName ?? 'User',
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.verticalGapSM,

          // Email
          Text(
            profile.email,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsSection(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Credits',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const CreditsIndicator(),
            ],
          ),
          AppSpacing.verticalGapXL,
          GradientButton(
            text: 'Buy More Credits',
            icon: Icons.add_shopping_cart_rounded,
            onPressed: () => context.go('/credits'),
            height: 56,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(dynamic profile) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: AppColors.gradientPrimary,
                ).createShader(bounds),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
              AppSpacing.horizontalGapMD,
              Text(
                'Account Information',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.verticalGapXL,

          _buildInfoRow(
            'Member since',
            _formatDate(profile.createdAt),
            Icons.calendar_today_rounded,
          ),
          AppSpacing.verticalGapLG,

          _buildInfoRow(
            'Account ID',
            profile.id.substring(0, 8).toUpperCase(),
            Icons.fingerprint_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: AppSpacing.paddingSM,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primaryBlue,
          ),
        ),
        AppSpacing.horizontalGapLG,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              AppSpacing.verticalGapXS,
              Text(
                value,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return GradientButton(
      text: 'Sign Out',
      icon: Icons.logout_rounded,
      gradient: AppColors.gradientError,
      onPressed: () async {
        await ref.read(authServiceProvider).signOut();
        if (context.mounted) {
          context.go('/');
        }
      },
      height: 56,
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
