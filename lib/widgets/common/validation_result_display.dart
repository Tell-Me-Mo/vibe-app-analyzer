import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/validation_result.dart';
import '../../models/validation_status.dart';

class ValidationResultDisplay extends StatelessWidget {
  final ValidationResult result;
  final VoidCallback? onRevalidate;
  final bool isValidating;

  const ValidationResultDisplay({
    super.key,
    required this.result,
    this.onRevalidate,
    this.isValidating = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _getBackgroundColor(result.status),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getBorderColor(result.status),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status icon and timestamp
              Row(
                children: [
                  Icon(
                    _getStatusIcon(result.status),
                    size: 20,
                    color: _getTextColor(result.status),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusTitle(result.status),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getTextColor(result.status),
                                fontSize: 14,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Validated ${_formatTimestamp(result.timestamp)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Summary
              if (result.summary != null) ...[
                const SizedBox(height: 12),
                Text(
                  result.summary!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        height: 1.5,
                        color: const Color(0xFFE2E8F0),
                      ),
                ),
              ],

              // Details
              if (result.details != null) ...[
                const SizedBox(height: 10),
                Text(
                  result.details!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFCBD5E1),
                        fontSize: 13,
                        height: 1.5,
                      ),
                ),
              ],

              // Remaining Issues (if validation failed)
              if (result.remainingIssues != null && result.remainingIssues!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.shade700.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 18,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Remaining Issues',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade200,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...result.remainingIssues!.map((issue) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '•',
                                  style: TextStyle(
                                    color: Colors.red.shade300,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    issue,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.red.shade100,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],

              // Recommendation (if validation failed)
              if (result.recommendation != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.shade700.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 18,
                        color: Colors.blue.shade300,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          result.recommendation!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade100,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Re-validate button (if callback provided)
              if (onRevalidate != null) ...[
                const SizedBox(height: 16),
                Align(
                  alignment: isMobile ? Alignment.center : Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: isValidating ? null : onRevalidate,
                    icon: isValidating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle_outline_rounded, size: 16),
                    label: Text(
                      isValidating ? 'Validating...' : 'Re-validate (1 credit)',
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
        );
      },
    );
  }

  IconData _getStatusIcon(ValidationStatus status) {
    switch (status) {
      case ValidationStatus.passed:
        return Icons.check_circle_rounded;
      case ValidationStatus.failed:
        return Icons.cancel_rounded;
      case ValidationStatus.error:
        return Icons.warning_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _getStatusTitle(ValidationStatus status) {
    switch (status) {
      case ValidationStatus.passed:
        return 'Validation Passed';
      case ValidationStatus.failed:
        return 'Validation Failed';
      case ValidationStatus.error:
        return 'Validation Error';
      default:
        return 'Validation Result';
    }
  }

  Color _getBackgroundColor(ValidationStatus status) {
    switch (status) {
      case ValidationStatus.passed:
        return Colors.green.shade900.withValues(alpha: 0.15);
      case ValidationStatus.failed:
        return Colors.red.shade900.withValues(alpha: 0.15);
      case ValidationStatus.error:
        return Colors.orange.shade900.withValues(alpha: 0.15);
      default:
        return Colors.grey.shade900.withValues(alpha: 0.15);
    }
  }

  Color _getBorderColor(ValidationStatus status) {
    switch (status) {
      case ValidationStatus.passed:
        return Colors.green.shade700.withValues(alpha: 0.5);
      case ValidationStatus.failed:
        return Colors.red.shade700.withValues(alpha: 0.5);
      case ValidationStatus.error:
        return Colors.orange.shade700.withValues(alpha: 0.5);
      default:
        return Colors.grey.shade700.withValues(alpha: 0.5);
    }
  }

  Color _getTextColor(ValidationStatus status) {
    switch (status) {
      case ValidationStatus.passed:
        return Colors.green.shade200;
      case ValidationStatus.failed:
        return Colors.red.shade200;
      case ValidationStatus.error:
        return Colors.orange.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(timestamp);
    }
  }
}
