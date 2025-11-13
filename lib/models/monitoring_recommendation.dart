import 'package:json_annotation/json_annotation.dart';
import 'severity.dart';
import 'validation_status.dart';
import 'validation_result.dart';

part 'monitoring_recommendation.g.dart';

@JsonSerializable()
class MonitoringRecommendation {
  final String id;
  final String title;
  final String category;
  @JsonKey(
    fromJson: _severityFromJson,
    toJson: _severityToJson,
  )
  final Severity severity;
  final String description;
  final String businessValue;
  final String claudeCodePrompt;
  final String? filePath;
  final int? lineNumber;
  @JsonKey(
    fromJson: _validationStatusFromJson,
    toJson: _validationStatusToJson,
  )
  final ValidationStatus validationStatus;
  final ValidationResult? validationResult;

  MonitoringRecommendation({
    required this.id,
    required this.title,
    required this.category,
    required this.severity,
    required this.description,
    required this.businessValue,
    required this.claudeCodePrompt,
    this.filePath,
    this.lineNumber,
    this.validationStatus = ValidationStatus.notStarted,
    this.validationResult,
  });

  factory MonitoringRecommendation.fromJson(Map<String, dynamic> json) =>
      _$MonitoringRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$MonitoringRecommendationToJson(this);

  MonitoringRecommendation copyWith({
    String? id,
    String? title,
    String? category,
    Severity? severity,
    String? description,
    String? businessValue,
    String? claudeCodePrompt,
    String? filePath,
    int? lineNumber,
    ValidationStatus? validationStatus,
    ValidationResult? validationResult,
  }) {
    return MonitoringRecommendation(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      businessValue: businessValue ?? this.businessValue,
      claudeCodePrompt: claudeCodePrompt ?? this.claudeCodePrompt,
      filePath: filePath ?? this.filePath,
      lineNumber: lineNumber ?? this.lineNumber,
      validationStatus: validationStatus ?? this.validationStatus,
      validationResult: validationResult ?? this.validationResult,
    );
  }

  static Severity _severityFromJson(String value) => Severity.fromString(value);
  static String _severityToJson(Severity severity) => severity.value;

  static ValidationStatus _validationStatusFromJson(String? value) {
    if (value == null) return ValidationStatus.notStarted;
    switch (value) {
      case 'notStarted':
        return ValidationStatus.notStarted;
      case 'validating':
        return ValidationStatus.validating;
      case 'passed':
        return ValidationStatus.passed;
      case 'failed':
        return ValidationStatus.failed;
      case 'error':
        return ValidationStatus.error;
      default:
        return ValidationStatus.notStarted;
    }
  }

  static String _validationStatusToJson(ValidationStatus status) {
    return status.toString().split('.').last;
  }
}
