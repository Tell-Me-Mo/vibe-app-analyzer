import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/validation_result.dart';
import '../../models/validation_status.dart';

class ValidationResultDisplay extends StatelessWidget {
  final ValidationResult result;

  const ValidationResultDisplay({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(result.status),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(result.status),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status icon and timestamp
          Row(
            children: [
              Text(
                result.status.icon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusTitle(result.status),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getTextColor(result.status),
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Validated ${_formatTimestamp(result.timestamp)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
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
                  ),
            ),
          ],

          // Details
          if (result.details != null) ...[
            const SizedBox(height: 8),
            Text(
              result.details!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade300,
                  ),
            ),
          ],

          // Remaining Issues (if validation failed)
          if (result.remainingIssues != null && result.remainingIssues!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade900.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.shade700.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 16,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Remaining Issues',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade200,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...result.remainingIssues!.map((issue) => Padding(
                        padding: const EdgeInsets.only(bottom: 4, left: 22),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '•',
                              style: TextStyle(
                                color: Colors.red.shade300,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                issue,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade200,
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade900.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.shade700.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Colors.blue.shade300,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.recommendation!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade200,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
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
