import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/analysis_type.dart';
import '../models/analysis_mode.dart';
import '../providers/analysis_provider.dart';
import '../widgets/common/loading_animation.dart';

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
  ConsumerState<AnalysisLoadingPage> createState() => _AnalysisLoadingPageState();
}

class _AnalysisLoadingPageState extends ConsumerState<AnalysisLoadingPage> {
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
                  _getDisplayName(),
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Analysis Type Badge
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
                const SizedBox(height: 8),
                // Analysis Mode Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.analysisMode == AnalysisMode.staticCode
                        ? Colors.purple.shade900.withValues(alpha: 0.3)
                        : Colors.green.shade900.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.analysisMode == AnalysisMode.staticCode
                          ? Colors.purple.shade700
                          : Colors.green.shade700,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.analysisMode.icon,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.analysisMode.displayName,
                        style: TextStyle(
                          color: widget.analysisMode == AnalysisMode.staticCode
                              ? Colors.purple.shade300
                              : Colors.green.shade300,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
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
