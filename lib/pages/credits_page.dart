import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/credit_package.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import '../services/credits_service.dart';
import '../services/notification_service.dart';
import '../services/analytics_service.dart';
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
  String? _purchasingPackageId; // Track which package is being purchased
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
    // Track begin checkout using Firebase standard event
    await AnalyticsService().logBeginCheckout(
      value: package.price,
      currency: 'USD',
    );

    // Track purchase initiation with custom event for detailed analytics
    await AnalyticsService().logEvent(
      name: 'purchase_initiated',
      parameters: {
        'package_id': package.id,
        'credits': package.credits,
        'price': package.price,
      },
    );

    final authService = ref.read(authServiceProvider);

    // Check if user is a guest (anonymous) or not signed in
    if (!authService.isSignedIn || authService.isAnonymous) {
      // Track auth requirement during purchase
      await AnalyticsService().logEvent(
        name: 'purchase_requires_auth',
        parameters: {
          'package_id': package.id,
          'is_anonymous': authService.isAnonymous ? 1 : 0,
        },
      );

      if (!mounted) return;
      final shouldSignIn = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Account Required',
            style: AppTypography.headlineSmall,
          ),
          content: Text(
            'You need to create an account or sign in to purchase credits. Your purchases will be synced across all your devices.',
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
      _purchasingPackageId = package.id;
      _errorMessage = null;
    });

    try {
      final paymentService = ref.read(paymentServiceProvider);

      // Initialize payment service with user ID
      await paymentService.initialize(authService.currentUser!.id);

      // Purchase the package directly (mock mode)
      final success = await paymentService.purchasePackage(package);

      if (success && mounted) {
        // Track successful purchase using Firebase standard event
        await AnalyticsService().logPurchase(
          transactionId: DateTime.now().millisecondsSinceEpoch.toString(),
          currency: 'USD',
          value: package.price,
        );

        // Also track custom purchase_completed event for detailed analytics
        await AnalyticsService().logEvent(
          name: 'purchase_completed',
          parameters: {
            'package_id': package.id,
            'credits': package.credits,
            'price': package.price,
          },
        );

        // Refresh the credits indicator by invalidating the credits provider
        ref.invalidate(creditsProvider);

        // Show success message
        NotificationService.showSuccess(
          context,
          title: 'Purchase Complete',
          message: 'Successfully purchased ${package.credits} credits!',
        );
      }
    } on PaymentException catch (e) {
      // Track payment error
      await AnalyticsService().logEvent(
        name: 'purchase_error',
        parameters: {
          'package_id': package.id,
          'error_type': 'payment_exception',
          'error_message': e.message,
        },
      );

      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      // Track general purchase error
      await AnalyticsService().logEvent(
        name: 'purchase_error',
        parameters: {
          'package_id': package.id,
          'error_type': 'general',
          'error_message': e.toString(),
        },
      );

      setState(() {
        _errorMessage = 'Purchase failed. Please try again.';
      });
    } finally {
      setState(() {
        _purchasingPackageId = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          _buildBackgroundGradient(),

          SafeArea(
            child: SingleChildScrollView(
              padding: isMobile
                ? AppSpacing.paddingLG  // 16px for mobile
                : AppSpacing.paddingXXL, // 24px for desktop
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
                        isMobile
                          ? AppSpacing.verticalGapXXL  // 24px for mobile
                          : AppSpacing.verticalGapHuge, // 40px for desktop

                        // Title section
                        _buildTitleSection(),
                        isMobile
                          ? AppSpacing.verticalGapXXL  // 24px for mobile
                          : AppSpacing.verticalGapHuge, // 40px for desktop

                        // Error message
                        if (_errorMessage != null) ...[
                          _buildErrorMessage(_errorMessage!),
                          isMobile
                            ? AppSpacing.verticalGapLG   // 16px for mobile
                            : AppSpacing.verticalGapXXL, // 24px for desktop
                        ],

                        // Pricing cards grid
                        _buildPricingGrid(),
                        isMobile
                          ? AppSpacing.verticalGapXXL  // 24px for mobile
                          : AppSpacing.verticalGapHuge, // 40px for desktop

                        // Info section
                        _buildInfoSection(),
                        isMobile
                          ? AppSpacing.verticalGapXXL  // 24px for mobile
                          : AppSpacing.verticalGapHuge, // 40px for desktop
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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        // Icon
        Container(
          padding: isMobile ? AppSpacing.paddingMD : AppSpacing.paddingLG,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: AppColors.gradientPrimary,
            ),
            boxShadow: AppElevation.glowLG(AppColors.primaryBlue),
          ),
          child: Icon(
            Icons.stars_rounded,
            size: isMobile ? 32 : 40,
            color: AppColors.textPrimary,
          ),
        ),
        isMobile ? AppSpacing.verticalGapLG : AppSpacing.verticalGapXXL,

        // Title
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: AppColors.gradientPrimary,
          ).createShader(bounds),
          child: Text(
            'Get More Credits',
            style: (isMobile
              ? AppTypography.headlineLarge
              : AppTypography.displaySmall).copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        isMobile ? AppSpacing.verticalGapSM : AppSpacing.verticalGapMD,

        // Subtitle
        Text(
          'Choose the perfect package for your needs',
          style: (isMobile
            ? AppTypography.bodyMedium
            : AppTypography.bodyLarge).copyWith(
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
        final isMobile = constraints.maxWidth < 600;

        // Mobile: Use Column for horizontal cards
        if (isMobile) {
          return Column(
            children: CreditPackages.all.map((package) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: package == CreditPackages.all.last ? 0 : AppSpacing.md,
                ),
                child: PricingCard(
                  package: package,
                  onPurchase: () => _handlePurchase(package),
                  isLoading: _purchasingPackageId == package.id,
                ),
              );
            }).toList(),
          );
        }

        // Desktop: Use GridView
        final crossAxisCount = constraints.maxWidth > 900 ? 4 : 2;

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
              isLoading: _purchasingPackageId == package.id,
            );
          },
        );
      },
    );
  }

  Widget _buildInfoSection() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return GlassCard(
      child: Column(
        children: [
          Container(
            padding: isMobile ? AppSpacing.paddingSM : AppSpacing.paddingMD,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: AppColors.gradientSecondary,
              ),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: AppColors.textPrimary,
              size: isMobile ? 24 : 28,
            ),
          ),
          isMobile ? AppSpacing.verticalGapMD : AppSpacing.verticalGapLG,
          Text(
            'Each analysis costs 5 credits',
            style: (isMobile
              ? AppTypography.titleSmall
              : AppTypography.titleMedium).copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          isMobile ? AppSpacing.verticalGapSM : AppSpacing.verticalGapMD,
          Text(
            'Credits never expire and are synced across all your devices',
            style: (isMobile
              ? AppTypography.bodySmall
              : AppTypography.bodyMedium).copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
