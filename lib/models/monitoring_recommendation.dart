import 'package:json_annotation/json_annotation.dart';
import 'validation_status.dart';
import 'validation_result.dart';

part 'monitoring_recommendation.g.dart';

@JsonSerializable()
class MonitoringRecommendation {
  final String id;
  final String title;
  final String category;
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
      description: description ?? this.description,
      businessValue: businessValue ?? this.businessValue,
      claudeCodePrompt: claudeCodePrompt ?? this.claudeCodePrompt,
      filePath: filePath ?? this.filePath,
      lineNumber: lineNumber ?? this.lineNumber,
      validationStatus: validationStatus ?? this.validationStatus,
      validationResult: validationResult ?? this.validationResult,
    );
  }

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
