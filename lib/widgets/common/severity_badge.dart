import 'package:flutter/material.dart';
import '../../models/severity.dart';

class SeverityBadge extends StatelessWidget {
  final Severity severity;

  const SeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: severity.color.withValues(alpha: 0.15),
        border: Border.all(
          color: severity.color.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        severity.displayName.toUpperCase(),
        style: TextStyle(
          color: severity.color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
