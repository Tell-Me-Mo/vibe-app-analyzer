import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/analysis_type.dart';
import '../models/analysis_mode.dart';
import '../providers/analysis_provider.dart';
import '../widgets/common/loading_animation.dart';
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
    extends ConsumerState<AnalysisLoadingPage> {
  @override
  void initState() {
    super.initState();

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
  Widget build(BuildContext context) {
    final analysisState = ref.watch(analysisProvider);

    // Navigate to results when complete
    ref.listen(analysisProvider, (previous, next) {
      if (!next.isLoading && next.result != null) {
        print('🚀 [NAVIGATION] Navigating to results/${next.result!.id}');
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
                      // Loading animation (no message - moved to bottom)
                      LoadingAnimation(
                        progress: analysisState.progress,
                        message: null,
                      ),
                      const SizedBox(height: 48),

                      // Repository/App name with enhanced styling
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 600),
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          _getDisplayName(),
                          style: AppTypography.headlineLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Progress text at bottom with animation
                      if (analysisState.progressMessage != null)
                        TweenAnimationBuilder<double>(
                          key: ValueKey(analysisState.progressMessage),
                          duration: const Duration(milliseconds: 400),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: child,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceGlass.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: gradient.first.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      gradient.first,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    analysisState.progressMessage!,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
