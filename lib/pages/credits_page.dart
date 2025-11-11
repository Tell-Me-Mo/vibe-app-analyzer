import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/credit_package.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import '../widgets/common/credits_indicator.dart';
import '../widgets/common/pricing_card.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/common/gradient_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

class CreditsPage extends ConsumerStatefulWidget {
  const CreditsPage({super.key});

  @override
  ConsumerState<CreditsPage> createState() => _CreditsPageState();
}

class _CreditsPageState extends ConsumerState<CreditsPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String? _errorMessage;
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

  Future<void> _handlePurchase(CreditPackage package) async {
    final authService = ref.read(authServiceProvider);

    // Check if user is signed in
    if (!authService.isSignedIn) {
      if (!mounted) return;
      final shouldSignIn = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Sign In Required',
            style: AppTypography.headlineSmall,
          ),
          content: Text(
            'You need to sign in to purchase credits. Your purchases will be synced across devices.',
            style: AppTypography.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            GradientButton(
              text: 'Sign In',
              onPressed: () => Navigator.of(context).pop(true),
              width: 120,
              height: 44,
            ),
          ],
        ),
      );

      if (shouldSignIn == true && mounted) {
        context.go('/auth');
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final paymentService = ref.read(paymentServiceProvider);

      // Initialize payment service with user ID
      await paymentService.initialize(authService.currentUser!.id);

      // Get available packages
      final packages = await paymentService.getAvailablePackages();

      // Find matching package
      final revenueCatPackage = packages.firstWhere(
        (p) => p.identifier.contains(package.id),
        orElse: () => packages.first,
      );

      // Purchase the package
      final success = await paymentService.purchasePackage(revenueCatPackage);

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.textPrimary,
                ),
                AppSpacing.horizontalGapMD,
                Text(
                  'Successfully purchased ${package.credits} credits!',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on PaymentException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Purchase failed. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          _buildBackgroundGradient(),

          SafeArea(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingXXL,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header with back button and credits
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => context.go('/'),
                              icon: const Icon(Icons.arrow_back_rounded),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.surfaceGlass,
                              ),
                            ),
                            const Spacer(),
                            const CreditsIndicator(),
                          ],
                        ),
                        AppSpacing.verticalGapHuge,

                        // Title section
                        _buildTitleSection(),
                        AppSpacing.verticalGapHuge,

                        // Error message
                        if (_errorMessage != null) ...[
                          _buildErrorMessage(_errorMessage!),
                          AppSpacing.verticalGapXXL,
                        ],

                        // Pricing cards grid
                        _buildPricingGrid(),
                        AppSpacing.verticalGapHuge,

                        // Info section
                        _buildInfoSection(),
                        AppSpacing.verticalGapHuge,
                      ],
                    ),
                  ),
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

  Widget _buildTitleSection() {
    return Column(
      children: [
        // Icon
        Container(
          padding: AppSpacing.paddingLG,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: AppColors.gradientPrimary,
            ),
            boxShadow: AppElevation.glowLG(AppColors.primaryBlue),
          ),
          child: const Icon(
            Icons.stars_rounded,
            size: 40,
            color: AppColors.textPrimary,
          ),
        ),
        AppSpacing.verticalGapXXL,

        // Title
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: AppColors.gradientPrimary,
          ).createShader(bounds),
          child: Text(
            'Get More Credits',
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        AppSpacing.verticalGapMD,

        // Subtitle
        Text(
          'Choose the perfect package for your needs',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return GlassCard(
      backgroundColor: AppColors.error.withValues(alpha: 0.1),
      borderColor: AppColors.error.withValues(alpha: 0.3),
      blurEnabled: false,
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.errorLight,
            size: 24,
          ),
          AppSpacing.horizontalGapMD,
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.errorLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 600
                ? 2
                : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            childAspectRatio: 0.75,
          ),
          itemCount: CreditPackages.all.length,
          itemBuilder: (context, index) {
            final package = CreditPackages.all[index];
            return PricingCard(
              package: package,
              onPurchase: () => _handlePurchase(package),
              isLoading: _isLoading,
            );
          },
        );
      },
    );
  }

  Widget _buildInfoSection() {
    return GlassCard(
      child: Column(
        children: [
          Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: AppColors.gradientSecondary,
              ),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),
          AppSpacing.verticalGapLG,
          Text(
            'Each analysis costs 5 credits',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalGapMD,
          Text(
            'Credits never expire and are synced across all your devices',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
