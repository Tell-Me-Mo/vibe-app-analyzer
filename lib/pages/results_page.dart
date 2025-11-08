import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/analysis_result.dart';
import '../models/analysis_type.dart';
import '../models/security_issue.dart';
import '../models/monitoring_recommendation.dart';
import '../providers/history_provider.dart';
import '../providers/validation_provider.dart';
import '../data/demo_data.dart';
import '../widgets/results/issue_card.dart';
import '../widgets/results/recommendation_card.dart';
import '../widgets/common/app_button.dart';

class ResultsPage extends ConsumerWidget {
  final String resultId;

  const ResultsPage({super.key, required this.resultId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch history and validation state to rebuild when validation completes
    ref.watch(historyProvider);
    ref.watch(validationProvider);

    // Try to find result in history or demo data
    final result = _getResult(ref);

    if (result == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: const Center(
          child: Text('Analysis not found'),
        ),
      );
    }

    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: Text(result.repositoryName),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: result.analysisType == AnalysisType.security
                                ? [const Color(0xFF60A5FA), const Color(0xFF3B82F6)]
                                : [const Color(0xFF34D399), const Color(0xFF10B981)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: (result.analysisType == AnalysisType.security
                                      ? const Color(0xFF60A5FA)
                                      : const Color(0xFF34D399))
                                  .withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          result.analysisType == AnalysisType.security
                              ? Icons.security
                              : Icons.show_chart,
                          color: const Color(0xFF0F172A),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result.repositoryName,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: result.repositoryUrl),
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('URL copied to clipboard!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      result.repositoryUrl,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                            decoration: TextDecoration.underline,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.copy,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (result.analysisType == AnalysisType.security
                                  ? const Color(0xFF60A5FA)
                                  : const Color(0xFF34D399))
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (result.analysisType == AnalysisType.security
                                    ? const Color(0xFF60A5FA)
                                    : const Color(0xFF34D399))
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '${result.analysisType.displayName} Analysis',
                          style: TextStyle(
                            color: result.analysisType == AnalysisType.security
                                ? const Color(0xFF60A5FA)
                                : const Color(0xFF34D399),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(result.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Summary Card - Modern and Responsive
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth > 600;

                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF1E293B),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isDesktop ? 24 : 20),
                          child: isDesktop
                              ? _buildDesktopSummary(context, result)
                              : _buildMobileSummary(context, result),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Results - Non-collapsible sections, collapsible cards
                  if (result.securityIssues != null) ...[
                    Text(
                      'Security Issues (${result.securityIssues!.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ...result.securityIssues!.map((issue) => IssueCard(
                          issue: issue,
                          repositoryUrl: result.repositoryUrl,
                          onValidate: (SecurityIssue issueToValidate) {
                            _handleSecurityValidation(
                              context,
                              ref,
                              issueToValidate,
                              result,
                            );
                          },
                        )),
                    const SizedBox(height: 24),
                  ],

                  if (result.monitoringRecommendations != null) ...[
                    Text(
                      'Monitoring Recommendations (${result.monitoringRecommendations!.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ...result.monitoringRecommendations!
                        .map((rec) => RecommendationCard(
                              recommendation: rec,
                              repositoryUrl: result.repositoryUrl,
                              onValidate: (MonitoringRecommendation recToValidate) {
                                _handleMonitoringValidation(
                                  context,
                                  ref,
                                  recToValidate,
                                  result,
                                );
                              },
                            )),
                    const SizedBox(height: 24),
                  ],

                  const SizedBox(height: 32),

                  // Action Button
                  Center(
                    child: AppButton(
                      label: 'Analyze Another Repository',
                      icon: Icons.refresh,
                      onPressed: () => context.go('/'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AnalysisResult? _getResult(WidgetRef ref) {
    // Check demo data first
    final demoResult = DemoData.demoExamples.where((r) => r.id == resultId).firstOrNull;
    if (demoResult != null) return demoResult;

    // Check history
    return ref.watch(historyProvider.notifier).getById(resultId);
  }

  Widget _buildDesktopSummary(BuildContext context, AnalysisResult result) {
    if (result.summary.bySeverity != null) {
      return Row(
        children: [
          Expanded(
            child: _SummaryMetric(
              label: 'Total Issues',
              value: result.summary.total.toString(),
              color: Theme.of(context).colorScheme.primary,
              isLarge: true,
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SummaryMetric(
                  label: 'Critical',
                  value: result.summary.bySeverity!['critical']?.toString() ?? '0',
                  color: Colors.red.shade400,
                ),
                _SummaryMetric(
                  label: 'High',
                  value: result.summary.bySeverity!['high']?.toString() ?? '0',
                  color: Colors.orange.shade400,
                ),
                _SummaryMetric(
                  label: 'Medium',
                  value: result.summary.bySeverity!['medium']?.toString() ?? '0',
                  color: Colors.yellow.shade400,
                ),
                _SummaryMetric(
                  label: 'Low',
                  value: result.summary.bySeverity!['low']?.toString() ?? '0',
                  color: Colors.blue.shade400,
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: _SummaryMetric(
              label: 'Total Recommendations',
              value: result.summary.total.toString(),
              color: Theme.of(context).colorScheme.primary,
              isLarge: true,
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SummaryMetric(
                  label: 'Analytics',
                  value: result.summary.byCategory!['analytics']?.toString() ?? '0',
                  color: Colors.blue.shade400,
                ),
                _SummaryMetric(
                  label: 'Error Tracking',
                  value: result.summary.byCategory!['error_tracking']?.toString() ?? '0',
                  color: Colors.red.shade400,
                ),
                _SummaryMetric(
                  label: 'Business Metrics',
                  value: result.summary.byCategory!['business_metrics']?.toString() ?? '0',
                  color: Colors.teal.shade400,
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildMobileSummary(BuildContext context, AnalysisResult result) {
    if (result.summary.bySeverity != null) {
      return Column(
        children: [
          _SummaryMetric(
            label: 'Total Issues',
            value: result.summary.total.toString(),
            color: Theme.of(context).colorScheme.primary,
            isLarge: true,
          ),
          const SizedBox(height: 16),
          Divider(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SummaryMetric(
                label: 'Critical',
                value: result.summary.bySeverity!['critical']?.toString() ?? '0',
                color: Colors.red.shade400,
              ),
              _SummaryMetric(
                label: 'High',
                value: result.summary.bySeverity!['high']?.toString() ?? '0',
                color: Colors.orange.shade400,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SummaryMetric(
                label: 'Medium',
                value: result.summary.bySeverity!['medium']?.toString() ?? '0',
                color: Colors.yellow.shade400,
              ),
              _SummaryMetric(
                label: 'Low',
                value: result.summary.bySeverity!['low']?.toString() ?? '0',
                color: Colors.blue.shade400,
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _SummaryMetric(
            label: 'Total Recommendations',
            value: result.summary.total.toString(),
            color: Theme.of(context).colorScheme.primary,
            isLarge: true,
          ),
          const SizedBox(height: 16),
          Divider(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SummaryMetric(
                label: 'Analytics',
                value: result.summary.byCategory!['analytics']?.toString() ?? '0',
                color: Colors.blue.shade400,
              ),
              _SummaryMetric(
                label: 'Error Tracking',
                value: result.summary.byCategory!['error_tracking']?.toString() ?? '0',
                color: Colors.red.shade400,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SummaryMetric(
            label: 'Business Metrics',
            value: result.summary.byCategory!['business_metrics']?.toString() ?? '0',
            color: Colors.teal.shade400,
          ),
        ],
      );
    }
  }

  void _handleSecurityValidation(
    BuildContext context,
    WidgetRef ref,
    SecurityIssue issue,
    AnalysisResult result,
  ) {
    ref.read(validationProvider.notifier).validateSecurityFix(
          context: context,
          resultId: result.id,
          issue: issue,
          repositoryUrl: result.repositoryUrl,
          repositoryName: result.repositoryName,
          onInsufficientCredits: () {
            _showInsufficientCreditsDialog(context);
          },
        );
  }

  void _handleMonitoringValidation(
    BuildContext context,
    WidgetRef ref,
    MonitoringRecommendation recommendation,
    AnalysisResult result,
  ) {
    ref.read(validationProvider.notifier).validateMonitoringImplementation(
          context: context,
          resultId: result.id,
          recommendation: recommendation,
          repositoryUrl: result.repositoryUrl,
          repositoryName: result.repositoryName,
          onInsufficientCredits: () {
            _showInsufficientCreditsDialog(context);
          },
        );
  }

  void _showInsufficientCreditsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 8),
            Text('Insufficient Credits'),
          ],
        ),
        content: const Text(
          'You need 1 credit to validate a fix or implementation. Would you like to purchase more credits?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go('/credits');
            },
            child: const Text('Buy Credits'),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isLarge;

  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.color,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 40 : 28,
            fontWeight: FontWeight.bold,
            color: color,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: isLarge ? 13 : 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
