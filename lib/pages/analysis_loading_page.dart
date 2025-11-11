import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/analysis_type.dart';
import '../models/analysis_mode.dart';
import '../providers/analysis_provider.dart';
import '../widgets/common/loading_animation.dart';
import '../widgets/common/glass_card.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

class AnalysisLoadingPage extends ConsumerStatefulWidget {
  final String url;
  final AnalysisType analysisType;
  final AnalysisMode analysisMode;

  const AnalysisLoadingPage({
    super.key,
    required this.url,
    required this.analysisType,
    required this.analysisMode,
  });

  @override
  ConsumerState<AnalysisLoadingPage> createState() =>
      _AnalysisLoadingPageState();
}

class _AnalysisLoadingPageState
    extends ConsumerState<AnalysisLoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for badges
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start analysis when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analysisProvider.notifier).analyze(
            url: widget.url,
            analysisType: widget.analysisType,
            analysisMode: widget.analysisMode,
          );
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analysisState = ref.watch(analysisProvider);

    // Navigate to results when complete
    ref.listen(analysisProvider, (previous, next) {
      if (!next.isLoading && next.result != null) {
        context.go('/results/${next.result!.id}');
      }
    });

    // Show error dialog if analysis fails
    if (analysisState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Analysis Failed',
              style: AppTypography.headlineSmall,
            ),
            content: Text(
              analysisState.error!,
              style: AppTypography.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  ref.read(analysisProvider.notifier).reset();
                  context.go('/');
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        );
      });
    }

    final isSecurityAnalysis = widget.analysisType == AnalysisType.security;
    final gradient = isSecurityAnalysis
        ? AppColors.gradientSecurity
        : AppColors.gradientMonitoring;

    return Scaffold(
      body: Stack(
        children: [
          // Animated background gradient
          _buildAnimatedBackground(gradient),

          SafeArea(
            child: Center(
              child: Padding(
                padding: AppSpacing.paddingXXL,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Loading animation
                      LoadingAnimation(
                        progress: analysisState.progress,
                        message: analysisState.progressMessage,
                      ),
                      AppSpacing.verticalGapHuge,

                      // Repository/App name
                      Text(
                        _getDisplayName(),
                        style: AppTypography.headlineMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.verticalGapXL,

                      // Badges card
                      GlassCard(
                        padding: AppSpacing.paddingXL,
                        child: Column(
                          children: [
                            // Analysis Type Badge
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: _buildAnalysisTypeBadge(gradient),
                            ),
                            AppSpacing.verticalGapMD,

                            // Analysis Mode Badge
                            _buildAnalysisModeBadge(),
                          ],
                        ),
                      ),
                      AppSpacing.verticalGapXL,

                      // Progress text
                      if (analysisState.progressMessage != null)
                        Text(
                          analysisState.progressMessage!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(List<Color> gradient) {
    return AnimatedContainer(
      duration: const Duration(seconds: 3),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            gradient.first.withValues(alpha: 0.15),
            AppColors.backgroundPrimary.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisTypeBadge(List<Color> gradient) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient.map((c) => c.withValues(alpha: 0.2)).toList(),
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          width: 2,
          color: gradient.first.withValues(alpha: 0.5),
        ),
        boxShadow: AppElevation.glowMD(gradient.first),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: gradient,
            ).createShader(bounds),
            child: Icon(
              widget.analysisType == AnalysisType.security
                  ? Icons.security_rounded
                  : Icons.show_chart_rounded,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
          AppSpacing.horizontalGapMD,
          Text(
            '${widget.analysisType.displayName} Analysis',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: gradient.first,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisModeBadge() {
    final isStaticCode = widget.analysisMode == AnalysisMode.staticCode;
    final color = isStaticCode ? AppColors.primaryPurple : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.analysisMode.icon,
            style: AppTypography.titleMedium,
          ),
          AppSpacing.horizontalGapMD,
          Text(
            widget.analysisMode.displayName,
            style: AppTypography.bodyLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayName() {
    if (widget.analysisMode == AnalysisMode.staticCode) {
      // Extract repository name from GitHub URL
      return 'Analyzing ${widget.url.split('/').last.replaceAll('.git', '')}';
    } else {
      // Extract domain from app URL
      try {
        final uri = Uri.parse(widget.url);
        return 'Analyzing ${uri.host}';
      } catch (e) {
        return 'Analyzing Application';
      }
    }
  }
}
