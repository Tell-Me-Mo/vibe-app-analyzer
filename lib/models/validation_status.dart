enum ValidationStatus {
  notStarted,
  validating,
  passed,
  failed,
  error,
}

extension ValidationStatusExtension on ValidationStatus {
  String get displayName {
    switch (this) {
      case ValidationStatus.notStarted:
        return 'Not Validated';
      case ValidationStatus.validating:
        return 'Validating...';
      case ValidationStatus.passed:
        return 'Fix Validated';
      case ValidationStatus.failed:
        return 'Fix Failed';
      case ValidationStatus.error:
        return 'Validation Error';
    }
  }

  String get icon {
    switch (this) {
      case ValidationStatus.notStarted:
        return '⚪';
      case ValidationStatus.validating:
        return '🔄';
      case ValidationStatus.passed:
        return '✅';
      case ValidationStatus.failed:
        return '❌';
      case ValidationStatus.error:
        return '⚠️';
    }
  }
}
