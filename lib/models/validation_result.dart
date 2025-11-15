import 'package:json_annotation/json_annotation.dart';
import 'validation_status.dart';

part 'validation_result.g.dart';

@JsonSerializable()
class ValidationResult {
  final String id;
  @JsonKey(
    fromJson: _statusFromJson,
    toJson: _statusToJson,
  )
  final ValidationStatus status;
  final DateTime timestamp;
  final String? summary;
  final String? details;
  final List<String>? remainingIssues;
  final String? recommendation;

  ValidationResult({
    required this.id,
    required this.status,
    required this.timestamp,
    this.summary,
    this.details,
    this.remainingIssues,
    this.recommendation,
  });

  factory ValidationResult.fromJson(Map<String, dynamic> json) =>
      _$ValidationResultFromJson(json);

  Map<String, dynamic> toJson() => _$ValidationResultToJson(this);

  static ValidationStatus _statusFromJson(String value) {
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

  static String _statusToJson(ValidationStatus status) {
    return status.toString().split('.').last;
  }
}
