import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/analytics_service.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/common/gradient_button.dart';
import '../widgets/common/gradient_icon.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authMethod = _isSignUp ? 'email_signup' : 'email_signin';

    try {
      final authService = ref.read(authServiceProvider);

      if (_isSignUp) {
        await authService.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim().isEmpty
              ? null
              : _nameController.text.trim(),
        );
        // Track successful sign up
        await AnalyticsService().logSignUp(method: authMethod);
      } else {
        await authService.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        // Track successful sign in
        await AnalyticsService().logLogin(method: authMethod);
      }

      // Set user ID for analytics
      final user = authService.currentUser;
      if (user != null) {
        await AnalyticsService().setUserId(user.id);
      }

      // Track auth completion
      await AnalyticsService().logEvent(
        name: 'auth_completed',
        parameters: {
          'auth_method': authMethod,
          'auth_type': _isSignUp ? 'signup' : 'signin',
        },
      );

      if (mounted) {
        context.go('/');
      }
    } on AuthException catch (e) {
      // Track auth error
      await AnalyticsService().logEvent(
        name: 'auth_error',
        parameters: {
          'auth_method': authMethod,
          'error_type': 'auth_exception',
          'error_message': e.message,
        },
      );

      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      // Track general auth error
      await AnalyticsService().logEvent(
        name: 'auth_error',
        parameters: {
          'auth_method': authMethod,
          'error_type': 'general',
          'error_message': e.toString(),
        },
      );

      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
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
            child: Center(
              child: SingleChildScrollView(
                padding: AppSpacing.paddingXXL,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
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

                          // Icon and title
                          _buildHeader(),
                          AppSpacing.verticalGapHuge,

                          // Auth form in glass card
                          GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Error message
                                if (_errorMessage != null) ...[
                                  _buildErrorMessage(_errorMessage!),
                                  AppSpacing.verticalGapXL,
                                ],

                                // Name field (sign up only)
                                if (_isSignUp) ...[
                                  TextField(
                                    controller: _nameController,
                                    style: AppTypography.bodyLarge,
                                    decoration: InputDecoration(
                                      labelText: 'Name (optional)',
                                      labelStyle: AppTypography.bodyMedium,
                                      prefixIcon: Icon(
                                        Icons.person_outline_rounded,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ),
                                  AppSpacing.verticalGapLG,
                                ],

                                // Email field
                                TextField(
                                  controller: _emailController,
                                  style: AppTypography.bodyLarge,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: AppTypography.bodyMedium,
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                AppSpacing.verticalGapLG,

                                // Password field
                                TextField(
                                  controller: _passwordController,
                                  style: AppTypography.bodyLarge,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: AppTypography.bodyMedium,
                                    prefixIcon: Icon(
                                      Icons.lock_outline_rounded,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                  obscureText: true,
                                ),
                                AppSpacing.verticalGapXXL,

                                // Submit button
                                GradientButton(
                                  text: _isSignUp ? 'Sign Up' : 'Sign In',
                                  icon: _isSignUp
                                      ? Icons.person_add_rounded
                                      : Icons.login_rounded,
                                  onPressed: _isLoading ? null : _handleEmailAuth,
                                  isLoading: _isLoading,
                                  height: 56,
                                ),
                                AppSpacing.verticalGapLG,

                                // Toggle sign up/sign in
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isSignUp = !_isSignUp;
                                      _errorMessage = null;
                                      _animationController.reset();
                                      _animationController.forward();
                                    });
                                  },
                                  child: Text(
                                    _isSignUp
                                        ? 'Already have an account? Sign In'
                                        : 'Don\'t have an account? Sign Up',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.w600,
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

  Widget _buildHeader() {
    return Column(
      children: [
        // Animated icon
        GradientIcon(
          icon: _isSignUp ? Icons.person_add_rounded : Icons.login_rounded,
          size: 40,
          gradient: AppColors.gradientPrimary,
          padding: AppSpacing.paddingXL,
        ),
        AppSpacing.verticalGapXL,

        // Title with gradient
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: AppColors.gradientPrimary,
          ).createShader(bounds),
          child: Text(
            _isSignUp ? 'Create Account' : 'Welcome Back',
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
          _isSignUp
              ? 'Sign up to save your credits and analysis history'
              : 'Sign in to access your account',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.errorLight,
            size: 20,
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
}
