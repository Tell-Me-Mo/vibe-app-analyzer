import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/monitoring_recommendation.dart';
import '../../models/validation_status.dart';
import '../../services/notification_service.dart';
import '../common/category_badge.dart';
import '../common/validation_status_badge.dart';
import '../common/validation_result_display.dart';

class RecommendationCard extends StatefulWidget {
  final MonitoringRecommendation recommendation;
  final String? repositoryUrl;
  final Function(MonitoringRecommendation)? onValidate;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.repositoryUrl,
    this.onValidate,
  });

  @override
  State<RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<RecommendationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1E293B),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    CategoryBadge(
                      category: widget.recommendation.category,
                      color: _getCategoryColor(widget.recommendation.category),
                    ),
                    if (widget.recommendation.validationStatus != ValidationStatus.notStarted) ...[
                      const SizedBox(width: 8),
                      ValidationStatusBadge(status: widget.recommendation.validationStatus),
                    ],
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.recommendation.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.recommendation.filePath != null) ...[
                        InkWell(
                          onTap: widget.repositoryUrl != null
                              ? () async {
                                  final url = '${widget.repositoryUrl}/blob/main/${widget.recommendation.filePath}${widget.recommendation.lineNumber != null ? '#L${widget.recommendation.lineNumber}' : ''}';
                                  final uri = Uri.parse(url);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                }
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.code, size: 14, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '${widget.recommendation.filePath}${widget.recommendation.lineNumber != null ? ':${widget.recommendation.lineNumber}' : ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.primary,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.open_in_new, size: 12, color: Theme.of(context).colorScheme.primary),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        widget.recommendation.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.shade900.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green.shade700.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.trending_up, color: Colors.green.shade400, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.recommendation.businessValue,
                                style: TextStyle(
                                  color: Colors.green.shade200,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Claude Code Prompt',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: widget.recommendation.claudeCodePrompt));
                                    NotificationService.showSuccess(
                                      context,
                                      message: 'Prompt copied to clipboard!',
                                    );
                                  },
                                  icon: const Icon(Icons.copy, size: 14),
                                  label: const Text('Copy', style: TextStyle(fontSize: 12)),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.recommendation.claudeCodePrompt,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Validate Implementation Button
                      if (widget.onValidate != null) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: widget.recommendation.validationStatus == ValidationStatus.validating
                                ? null
                                : () => widget.onValidate!(widget.recommendation),
                            icon: widget.recommendation.validationStatus == ValidationStatus.validating
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.check_circle_outline, size: 18),
                            label: Text(
                              widget.recommendation.validationStatus == ValidationStatus.validating
                                  ? 'Validating Implementation...'
                                  : widget.recommendation.validationStatus == ValidationStatus.notStarted
                                      ? 'Validate Implementation (1 credit)'
                                      : 'Re-validate Implementation (1 credit)',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                              foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                      // Validation Result Display
                      if (widget.recommendation.validationResult != null) ...[
                        const SizedBox(height: 12),
                        ValidationResultDisplay(
                          result: widget.recommendation.validationResult!,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'analytics':
        return Colors.blue.shade400;
      case 'error_tracking':
        return Colors.red.shade400;
      case 'business_metrics':
        return Colors.purple.shade400;
      default:
        return Colors.grey.shade400;
    }
  }
}
