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
import '../services/analytics_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _urlController = TextEditingController();
  String? _errorText;

  @override
  void initState() {
    super.initState();

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
      // Track validation failure
      await AnalyticsService().logEvent(
        name: 'url_validation_failed',
        parameters: {
          'url': url,
          'analysis_type': analysisType.toString(),
        },
      );
      return;
    }

    // Check if user has enough credits
    final hasCredits = await CreditsService().hasEnoughCredits(5);
    if (!hasCredits) {
      // Track insufficient credits
      await AnalyticsService().logEvent(
        name: 'insufficient_credits',
        parameters: {
          'analysis_type': analysisType.toString(),
          'url_mode': urlMode.toString(),
        },
      );

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

    // Track analysis initiation
    await AnalyticsService().logEvent(
      name: 'analysis_initiated',
      parameters: {
        'analysis_type': analysisType.toString(),
        'url_mode': urlMode.toString(),
        'is_github': urlMode.toString().contains('github'),
      },
    );

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

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      // Mobile drawer with credits and auth
      endDrawer: isMobile ? _buildMobileDrawer() : null,
      body: Stack(
        children: [
          // Animated gradient background
          _buildBackgroundGradient(),

          // Main content
          SafeArea(
            child: isMobile
                ? _MainContent(
                    key: const ValueKey('main_content'),
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
                  )
                : Stack(
                    children: [
                      _MainContent(
                        key: const ValueKey('main_content'),
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

                      // Top-right corner: credits and auth button (desktop only - isolated to prevent page rebuilds)
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

  // Mobile slide-out drawer with credits and auth
  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: AppColors.backgroundPrimary,
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingXXL,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menu',
                    style: AppTypography.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              AppSpacing.verticalGapXXL,

              // Credits indicator
              const CreditsIndicator(),
              AppSpacing.verticalGapLG,

              // Auth button
              const AuthButton(),

              const Spacer(),

              // Footer with app version or info
              Text(
                'VibeCheck v1.0',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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
  final Function(AnalysisType) onAnalyze;
  final TextEditingController urlController;
  final String? errorText;
  final VoidCallback onUrlChanged;
  final VoidCallback onClearUrl;

  const _MainContent({
    super.key,
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
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 0 : AppSpacing.xxl, // No horizontal padding on mobile
          vertical: isMobile ? 0 : AppSpacing.huge, // No vertical padding on mobile
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
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
              // Mobile header with menu icon
              _buildMobileHeader(),

              // Content with horizontal padding
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    AppSpacing.verticalGapXL,

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
              ),
            ],
          ),
        );
      },
    );
  }

  // Modern mobile header - minimalistic menu icon
  Widget _buildMobileHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.md,
        right: AppSpacing.md,
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceGlass.withValues(alpha: 0.5),
              borderRadius: AppRadius.radiusMD,
              border: Border.all(
                color: AppColors.borderSubtle,
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.menu_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
        ),
      ),
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
        // Gradient icon with glow
        GradientIcon(
          icon: Icons.analytics_rounded,
          size: 56,
          gradient: AppColors.gradientPrimary,
          padding: AppSpacing.paddingXXL,
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

    // Desktop only - horizontal layout
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CreditsIndicator(),
        AppSpacing.horizontalGapMD,
        const AuthButton(),
      ],
    );
  }
}
