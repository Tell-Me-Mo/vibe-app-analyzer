import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/security_issue.dart';
import '../../models/validation_status.dart';
import '../common/severity_badge.dart';
import '../common/category_badge.dart';
import '../common/validation_status_badge.dart';
import '../common/validation_result_display.dart';

class IssueCard extends StatefulWidget {
  final SecurityIssue issue;
  final String? repositoryUrl;
  final Function(SecurityIssue)? onValidate;

  const IssueCard({
    super.key,
    required this.issue,
    this.repositoryUrl,
    this.onValidate,
  });

  @override
  State<IssueCard> createState() => _IssueCardState();
}

class _IssueCardState extends State<IssueCard> {
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
                    SeverityBadge(severity: widget.issue.severity),
                    const SizedBox(width: 8),
                    CategoryBadge(category: widget.issue.category),
                    if (widget.issue.validationStatus != ValidationStatus.notStarted) ...[
                      const SizedBox(width: 8),
                      ValidationStatusBadge(status: widget.issue.validationStatus),
                    ],
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.issue.title,
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
                      if (widget.issue.filePath != null) ...[
                        InkWell(
                          onTap: widget.repositoryUrl != null
                              ? () async {
                                  final url = '${widget.repositoryUrl}/blob/main/${widget.issue.filePath}${widget.issue.lineNumber != null ? '#L${widget.issue.lineNumber}' : ''}';
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
                                    '${widget.issue.filePath}${widget.issue.lineNumber != null ? ':${widget.issue.lineNumber}' : ''}',
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
                        widget.issue.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade900.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber, color: Colors.amber.shade400, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.issue.aiGenerationRisk,
                                style: TextStyle(
                                  color: Colors.amber.shade200,
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
                                    Clipboard.setData(ClipboardData(text: widget.issue.claudeCodePrompt));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Prompt copied to clipboard!'),
                                        duration: Duration(seconds: 2),
                                      ),
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
                              widget.issue.claudeCodePrompt,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Validate Fix Button
                      if (widget.onValidate != null) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: widget.issue.validationStatus == ValidationStatus.validating
                                ? null
                                : () => widget.onValidate!(widget.issue),
                            icon: widget.issue.validationStatus == ValidationStatus.validating
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.check_circle_outline, size: 18),
                            label: Text(
                              widget.issue.validationStatus == ValidationStatus.validating
                                  ? 'Validating Fix...'
                                  : widget.issue.validationStatus == ValidationStatus.notStarted
                                      ? 'Validate Fix (1 credit)'
                                      : 'Re-validate Fix (1 credit)',
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
                      if (widget.issue.validationResult != null) ...[
                        const SizedBox(height: 12),
                        ValidationResultDisplay(
                          result: widget.issue.validationResult!,
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
}
