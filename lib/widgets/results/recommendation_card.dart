import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Container(
          margin: EdgeInsets.only(bottom: isMobile ? 12 : 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(isMobile ? 12 : 10),
            border: Border.all(
              color: const Color(0xFF1E293B),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 14 : 16,
              vertical: isMobile ? 14 : 12,
            ),
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
                  child: isMobile
                      ? _buildMobileHeader(context)
                      : _buildDesktopHeader(context),
                ),
                if (_isExpanded) ...[
                  SizedBox(height: isMobile ? 10 : 12),
                  Padding(
                    padding: EdgeInsets.only(left: isMobile ? 0 : 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // Description with better typography
                      Text(
                        widget.recommendation.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          height: 1.5,
                          color: const Color(0xFFCBD5E1),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Business Value - more prominent
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade900.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.shade700.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.trending_up_rounded,
                              color: Colors.green.shade400,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Business Value',
                                    style: TextStyle(
                                      color: Colors.green.shade300,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.recommendation.businessValue,
                                    style: TextStyle(
                                      color: Colors.green.shade100,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Claude Code Prompt - cleaner design
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF334155),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with copy button
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(7),
                                  topRight: Radius.circular(7),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.code_rounded,
                                        size: 16,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Claude Code Prompt',
                                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context).colorScheme.primary,
                                              fontSize: 12,
                                            ),
                                      ),
                                    ],
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: widget.recommendation.claudeCodePrompt));
                                      NotificationService.showSuccess(
                                        context,
                                        message: 'Prompt copied to clipboard!',
                                      );
                                    },
                                    icon: const Icon(Icons.copy_rounded, size: 14),
                                    label: const Text('Copy', style: TextStyle(fontSize: 11)),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Prompt content
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                widget.recommendation.claudeCodePrompt,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  height: 1.5,
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Validation Result Display with button
                      if (widget.recommendation.validationResult != null) ...[
                        const SizedBox(height: 16),
                        ValidationResultDisplay(
                          result: widget.recommendation.validationResult!,
                          onRevalidate: widget.onValidate != null
                              ? () => widget.onValidate!(widget.recommendation)
                              : null,
                          isValidating: widget.recommendation.validationStatus == ValidationStatus.validating,
                        ),
                      ]
                      // Show button if no validation result yet
                      else if (widget.onValidate != null) ...[
                        const SizedBox(height: 16),
                        Align(
                          alignment: isMobile ? Alignment.center : Alignment.centerRight,
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
                                : const Icon(Icons.check_circle_outline_rounded, size: 16),
                            label: Text(
                              widget.recommendation.validationStatus == ValidationStatus.validating
                                  ? 'Validating Implementation...'
                                  : 'Validate Implementation (1 credit)',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              backgroundColor: const Color(0xFF0891B2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
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
      },
    );
  }

  // Mobile-first header: Vertical stacking for better readability
  Widget _buildMobileHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Expand icon + Title
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.recommendation.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Row 2: Badges in a compact wrap
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            CategoryBadge(
              category: widget.recommendation.category,
              color: _getCategoryColor(widget.recommendation.category),
            ),
            if (widget.recommendation.validationStatus != ValidationStatus.notStarted)
              ValidationStatusBadge(status: widget.recommendation.validationStatus),
          ],
        ),
      ],
    );
  }

  // Desktop header: Compact horizontal layout
  Widget _buildDesktopHeader(BuildContext context) {
    return Row(
      children: [
        // Expand icon
        Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
          color: Theme.of(context).colorScheme.primary,
          size: 18,
        ),
        const SizedBox(width: 10),

        // Badges - more compact
        CategoryBadge(
          category: widget.recommendation.category,
          color: _getCategoryColor(widget.recommendation.category),
        ),

        if (widget.recommendation.validationStatus != ValidationStatus.notStarted) ...[
          const SizedBox(width: 8),
          ValidationStatusBadge(status: widget.recommendation.validationStatus),
        ],

        const SizedBox(width: 12),

        // Title - more compact font
        Expanded(
          child: Text(
            widget.recommendation.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
