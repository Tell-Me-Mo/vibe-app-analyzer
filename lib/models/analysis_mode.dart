/// Represents the mode of analysis being performed
enum AnalysisMode {
  /// Static code analysis from GitHub repository
  staticCode,

  /// Runtime analysis of deployed application
  runtime;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case AnalysisMode.staticCode:
        return 'Static Code';
      case AnalysisMode.runtime:
        return 'Runtime';
    }
  }

  /// Short label for compact UI
  String get shortLabel {
    switch (this) {
      case AnalysisMode.staticCode:
        return 'Code';
      case AnalysisMode.runtime:
        return 'Live';
    }
  }

  /// Icon for the analysis mode
  String get icon {
    switch (this) {
      case AnalysisMode.staticCode:
        return '📝';
      case AnalysisMode.runtime:
        return '🚀';
    }
  }

  /// Description of what this mode analyzes
  String get description {
    switch (this) {
      case AnalysisMode.staticCode:
        return 'Analyzes source code from GitHub repository';
      case AnalysisMode.runtime:
        return 'Analyzes deployed live application';
    }
  }

  /// Serialize to string for storage
  String toJson() => name;

  /// Deserialize from string
  static AnalysisMode fromJson(String value) {
    return AnalysisMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => AnalysisMode.staticCode,
    );
  }
}
