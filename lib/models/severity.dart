import 'package:flutter/material.dart';

enum Severity {
  critical,
  high,
  medium,
  low;

  String get displayName {
    return name[0].toUpperCase() + name.substring(1);
  }

  Color get color {
    switch (this) {
      case Severity.critical:
        return Colors.red.shade400;
      case Severity.high:
        return Colors.orange.shade400;
      case Severity.medium:
        return Colors.yellow.shade400;
      case Severity.low:
        return Colors.blue.shade400;
    }
  }

  String get value {
    return name;
  }

  static Severity fromString(String value) {
    return Severity.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => Severity.low,
    );
  }
}
