import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/analysis_type.dart';
import '../providers/analysis_provider.dart';
import '../widgets/common/loading_animation.dart';

class AnalysisLoadingPage extends ConsumerStatefulWidget {
  final String repositoryUrl;
  final AnalysisType analysisType;

  const AnalysisLoadingPage({
    super.key,
    required this.repositoryUrl,
    required this.analysisType,
  });

  @override
  ConsumerState<AnalysisLoadingPage> createState() => _AnalysisLoadingPageState();
}

class _AnalysisLoadingPageState extends ConsumerState<AnalysisLoadingPage> {
  @override
  void initState() {
    super.initState();
    // Start analysis when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analysisProvider.notifier).analyzeRepository(
            repositoryUrl: widget.repositoryUrl,
            analysisType: widget.analysisType,
          );
    });
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
            title: const Text('Analysis Failed'),
            content: Text(analysisState.error!),
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

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingAnimation(
                  progress: analysisState.progress,
                  message: analysisState.progressMessage,
                ),
                const SizedBox(height: 32),
                Text(
                  'Analyzing ${widget.repositoryUrl.split('/').last}',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: widget.analysisType == AnalysisType.security
                        ? Colors.red.shade900.withValues(alpha: 0.3)
                        : Colors.blue.shade900.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.analysisType.displayName} Analysis',
                    style: TextStyle(
                      color: widget.analysisType == AnalysisType.security
                          ? Colors.red.shade400
                          : Colors.blue.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
