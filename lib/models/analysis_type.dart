enum AnalysisType {
  security,
  monitoring;

  String get displayName {
    switch (this) {
      case AnalysisType.security:
        return 'Security';
      case AnalysisType.monitoring:
        return 'Monitoring';
    }
  }

  String get value {
    return name;
  }
}
