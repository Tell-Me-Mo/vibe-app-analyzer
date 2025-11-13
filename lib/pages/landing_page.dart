import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/analysis_type.dart';
import '../providers/history_provider.dart';
import '../data/demo_data.dart';
import '../widgets/landing/history_card.dart';
import '../widgets/common/welcome_popup.dart';
import '../widgets/common/credits_indicator.dart';
import '../widgets/common/auth_button.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/common/gradient_button.dart';
import '../widgets/common/gradient_icon.dart';
import '../utils/validators.dart';
import '../services/credits_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  final _urlController = TextEditingController();
  String? _errorText;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    // Show welcome popup on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final hasSeenWelcome = await CreditsService().hasSeenWelcome();
      if (!hasSeenWelcome && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const WelcomePopup(),
        );
      }
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onAnalyze(AnalysisType analysisType) async {
    final url = _urlController.text.trim();

    // Detect URL type
    final urlMode = Validators.detectUrlType(url);

    if (urlMode == null) {
      setState(() {
        _errorText = 'Please enter a valid GitHub repository or live app URL';
      });
      return;
    }

    // Check if user has enough credits
    final hasCredits = await CreditsService().hasEnoughCredits(5);
    if (!hasCredits) {
      if (mounted) {
        final shouldBuy = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Insufficient Credits',
              style: AppTypography.headlineSmall,
            ),
            content: Text(
              'You need 5 credits to run an analysis. Would you like to purchase more credits?',
              style: AppTypography.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              GradientButton(
                text: 'Buy Credits',
                onPressed: () => Navigator.of(context).pop(true),
                height: 44,
              ),
            ],
          ),
        );

        if (shouldBuy == true && mounted) {
          context.go('/credits');
        }
      }
      return;
    }

    setState(() {
      _errorText = null;
    });

    if (mounted) {
      context.go('/analyze', extra: {
        'url': url,
        'type': analysisType,
        'mode': urlMode,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🟣 [LANDING PAGE] Building LandingPage widget (hashCode: $hashCode)');

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          _buildBackgroundGradient(),

          // Main content
          SafeArea(
            child: Stack(
              children: [
                _MainContent(
                  key: const ValueKey('main_content'),
                  fadeAnimation: _fadeAnimation,
                  slideAnimation: _slideAnimation,
                  onAnalyze: _onAnalyze,
                  urlController: _urlController,
                  errorText: _errorText,
                  onUrlChanged: () {
                    if (_errorText != null) {
                      setState(() => _errorText = null);
                    }
                    setState(() {});
                  },
                  onClearUrl: () {
                    _urlController.clear();
                    setState(() {});
                  },
                ),

                // Top-right corner: credits and auth button (isolated to prevent page rebuilds)
                const Positioned(
                  key: ValueKey('top_right_indicators'),
                  top: AppSpacing.lg,
                  right: AppSpacing.lg,
                  child: _TopRightIndicators(),
                ),
              ],
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
}

/// Main content widget isolated from top-right indicators
class _MainContent extends StatefulWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Function(AnalysisType) onAnalyze;
  final TextEditingController urlController;
  final String? errorText;
  final VoidCallback onUrlChanged;
  final VoidCallback onClearUrl;

  const _MainContent({
    super.key,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.onAnalyze,
    required this.urlController,
    required this.errorText,
    required this.onUrlChanged,
    required this.onClearUrl,
  });

  @override
  State<_MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<_MainContent> {
  @override
  Widget build(BuildContext context) {
    debugPrint('🟢 [MAIN CONTENT] Building _MainContent widget');

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.huge,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: FadeTransition(
            opacity: widget.fadeAnimation,
            child: SlideTransition(
              position: widget.slideAnimation,
              child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
            ),
          ),
        ),
      ),
    );
  }

  // Mobile layout - entire page scrollable
  Widget _buildMobileLayout() {
    return Consumer(
      builder: (context, ref, child) {
        final history = ref.watch(historyProvider);
        final allResults = [...DemoData.demoExamples, ...history];
        // Sort by timestamp, most recent first
        allResults.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return SingleChildScrollView(
          child: Column(
            children: [
              // Hero Section
              _buildModernHeroSection(),
              AppSpacing.verticalGapGiant,

              // Input Section
              _buildModernInputSection(),
              const SizedBox(height: 100),

              // History Section
              if (allResults.isNotEmpty) _buildMobileHistorySection(allResults),
            ],
          ),
        );
      },
    );
  }

  // Desktop layout - fixed header with scrollable history
  Widget _buildDesktopLayout() {
    return Column(
      children: [
        // Hero Section
        _buildModernHeroSection(),
        AppSpacing.verticalGapGiant,

        // Input Section
        _buildModernInputSection(),
        const SizedBox(height: 100),

        // History Section - Use Consumer only for this part
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final history = ref.watch(historyProvider);
              final allResults = [...DemoData.demoExamples, ...history];
              // Sort by timestamp, most recent first
              allResults.sort((a, b) => b.timestamp.compareTo(a.timestamp));

              if (allResults.isEmpty) {
                return const SizedBox.shrink();
              }

              return _buildModernHistorySection(allResults);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModernHeroSection() {
    return Column(
      children: [
        // Animated gradient icon with glow
        Hero(
          tag: 'app_icon',
          child: GradientIcon(
            icon: Icons.analytics_rounded,
            size: 56,
            gradient: AppColors.gradientPrimary,
            padding: AppSpacing.paddingXXL,
          ),
        ),
        AppSpacing.verticalGapXXL,

        // Title with gradient text
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: AppColors.gradientPrimary,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'VibeCheck',
            style: AppTypography.displayMedium.copyWith(
              fontSize: 64,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        AppSpacing.verticalGapLG,

        // Subtitle
        Text(
          'Check the vibe of your AI-generated code',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.verticalGapMD,

        // Sub-subtitle
        Text(
          'Scan for security vulnerabilities & monitoring gaps',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildModernInputSection() {
    return GlassCard(
      padding: AppSpacing.paddingXXXL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // URL Input with modern styling
          TextField(
            controller: widget.urlController,
            style: AppTypography.bodyLarge,
            decoration: InputDecoration(
              hintText: 'https://github.com/user/repo or https://yourapp.com',
              errorText: widget.errorText,
              prefixIcon: Icon(
                Icons.link_rounded,
                color: AppColors.textTertiary,
              ),
              suffixIcon: widget.urlController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: widget.onClearUrl,
                    )
                  : null,
            ),
            onChanged: (_) => widget.onUrlChanged(),
          ),
          AppSpacing.verticalGapXXL,

          // Action Buttons - Responsive
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                // Desktop: side by side
                return Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        text: 'Analyze Security',
                        icon: Icons.security_rounded,
                        gradient: AppColors.gradientSecurity,
                        onPressed: () => widget.onAnalyze(AnalysisType.security),
                        height: 60,
                      ),
                    ),
                    AppSpacing.horizontalGapLG,
                    Expanded(
                      child: GradientButton(
                        text: 'Analyze Monitoring',
                        icon: Icons.show_chart_rounded,
                        gradient: AppColors.gradientMonitoring,
                        onPressed: () => widget.onAnalyze(AnalysisType.monitoring),
                        height: 60,
                      ),
                    ),
                  ],
                );
              } else {
                // Mobile: stacked
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GradientButton(
                      text: 'Analyze Security',
                      icon: Icons.security_rounded,
                      gradient: AppColors.gradientSecurity,
                      onPressed: () => widget.onAnalyze(AnalysisType.security),
                      height: 60,
                    ),
                    AppSpacing.verticalGapLG,
                    GradientButton(
                      text: 'Analyze Monitoring',
                      icon: Icons.show_chart_rounded,
                      gradient: AppColors.gradientMonitoring,
                      onPressed: () => widget.onAnalyze(AnalysisType.monitoring),
                      height: 60,
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Mobile history section - no Expanded, uses shrinkWrap
  Widget _buildMobileHistorySection(List allResults) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 4,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.gradientPrimary,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AppSpacing.horizontalGapMD,
            Text(
              'Recent Analyses',
              style: AppTypography.headlineMedium,
            ),
          ],
        ),
        AppSpacing.verticalGapXXL,

        // List - using shrinkWrap for mobile scrolling
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: allResults.length,
          itemBuilder: (context, index) {
            final result = allResults[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: HistoryCard(
                result: result,
                onTap: () => context.go('/results/${result.id}'),
              ),
            );
          },
        ),
      ],
    );
  }

  // Desktop history section - uses Expanded for scrollable area
  Widget _buildModernHistorySection(List allResults) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed header
        Row(
          children: [
            Container(
              width: 4,
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.gradientPrimary,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AppSpacing.horizontalGapMD,
            Text(
              'Recent Analyses',
              style: AppTypography.headlineMedium,
            ),
          ],
        ),
        AppSpacing.verticalGapXXL,

        // Scrollable list
        Expanded(
          child: ListView.builder(
            itemCount: allResults.length,
            itemBuilder: (context, index) {
              final result = allResults[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: HistoryCard(
                  result: result,
                  onTap: () => context.go('/results/${result.id}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Isolated widget for top-right indicators to prevent page rebuilds
class _TopRightIndicators extends StatefulWidget {
  const _TopRightIndicators();

  @override
  State<_TopRightIndicators> createState() => _TopRightIndicatorsState();
}

class _TopRightIndicatorsState extends State<_TopRightIndicators> {
  @override
  Widget build(BuildContext context) {
    debugPrint('🟤 [TOP RIGHT INDICATORS] Building _TopRightIndicators widget');
    return Row(
      children: [
        const CreditsIndicator(),
        AppSpacing.horizontalGapMD,
        const AuthButton(),
      ],
    );
  }
}
