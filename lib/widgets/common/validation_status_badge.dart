import 'package:flutter/material.dart';
import '../../models/validation_status.dart';

class ValidationStatusBadge extends StatelessWidget {
  final ValidationStatus status;

  const ValidationStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(status),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(status),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status.icon,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: _getTextColor(status),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(ValidationStatus status) {
    switch (status) {
      case ValidationStatus.notStarted:
        return Colors.grey.shade800.withValues(alpha: 0.3);
      case ValidationStatus.validating:
        return Colors.blue.shade900.withValues(alpha: 0.3);
      case ValidationStatus.passed:
        return Colors.green.shade900.withValues(alpha: 0.3);
      case ValidationStatus.failed:
        return Colors.red.shade900.withValues(alpha: 0.3);
      case ValidationStatus.error:
        return Colors.orange.shade900.withValues(alpha: 0.3);
    }
  }

  Color _getBorderColor(ValidationStatus status) {
    switch (status) {
      case ValidationStatus.notStarted:
        return Colors.grey.shade600.withValues(alpha: 0.5);
      case ValidationStatus.validating:
        return Colors.blue.shade400.withValues(alpha: 0.5);
      case ValidationStatus.passed:
        return Colors.green.shade400.withValues(alpha: 0.5);
      case ValidationStatus.failed:
        return Colors.red.shade400.withValues(alpha: 0.5);
      case ValidationStatus.error:
        return Colors.orange.shade400.withValues(alpha: 0.5);
    }
  }

  Color _getTextColor(ValidationStatus status) {
    switch (status) {
      case ValidationStatus.notStarted:
        return Colors.grey.shade300;
      case ValidationStatus.validating:
        return Colors.blue.shade200;
      case ValidationStatus.passed:
        return Colors.green.shade200;
      case ValidationStatus.failed:
        return Colors.red.shade200;
      case ValidationStatus.error:
        return Colors.orange.shade200;
    }
  }
}
