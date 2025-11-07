import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/analysis_type.dart';
import '../providers/history_provider.dart';
import '../data/demo_data.dart';
import '../widgets/landing/history_card.dart';
import '../utils/validators.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  final _urlController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _onAnalyze(AnalysisType analysisType) {
    final url = _urlController.text.trim();

    if (!Validators.isValidGitHubUrl(url)) {
      setState(() {
        _errorText = 'Please enter a valid GitHub repository URL';
      });
      return;
    }

    setState(() {
      _errorText = null;
    });

    context.go('/analyze', extra: {
      'url': url,
      'type': analysisType,
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);
    final allResults = [...DemoData.demoExamples, ...history];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  // Hero Section
                  _buildHeroSection(context),
                  const SizedBox(height: 56),

                  // Input Section
                  _buildInputSection(context),
                  const SizedBox(height: 80),

                  // History Section
                  if (allResults.isNotEmpty) _buildHistorySection(context, allResults),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Column(
      children: [
        // Icon with gradient background
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF60A5FA), Color(0xFF34D399)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF60A5FA).withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.analytics_outlined,
            size: 40,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          'App Analyzer',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: 40,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),

        // Subtitle
        Text(
          'Analyze your AI-generated apps for security & monitoring insights',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF94A3B8),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // URL Input
        TextField(
          controller: _urlController,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'https://github.com/username/repository',
            errorText: _errorText,
            prefixIcon: const Icon(Icons.link, size: 20),
            suffixIcon: _urlController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _urlController.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
          onChanged: (_) {
            if (_errorText != null) {
              setState(() {
                _errorText = null;
              });
            }
            setState(() {});
          },
        ),
        const SizedBox(height: 20),

        // Action Buttons
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 500) {
              // Desktop: side by side
              return Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      label: 'Analyze Security',
                      icon: Icons.security,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
                      ),
                      onPressed: () => _onAnalyze(AnalysisType.security),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      label: 'Analyze Monitoring',
                      icon: Icons.show_chart,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF34D399), Color(0xFF10B981)],
                      ),
                      onPressed: () => _onAnalyze(AnalysisType.monitoring),
                    ),
                  ),
                ],
              );
            } else {
              // Mobile: stacked
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildActionButton(
                    context,
                    label: 'Analyze Security',
                    icon: Icons.security,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
                    ),
                    onPressed: () => _onAnalyze(AnalysisType.security),
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    context,
                    label: 'Analyze Monitoring',
                    icon: Icons.show_chart,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF34D399), Color(0xFF10B981)],
                    ),
                    onPressed: () => _onAnalyze(AnalysisType.monitoring),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: const Color(0xFF0F172A)),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context, List allResults) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Analyses',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        ...allResults.map(
          (result) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: HistoryCard(
              result: result,
              onTap: () {
                context.go('/results/${result.id}');
              },
            ),
          ),
        ),
      ],
    );
  }
}
