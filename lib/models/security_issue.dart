import 'package:json_annotation/json_annotation.dart';
import 'severity.dart';

part 'security_issue.g.dart';

@JsonSerializable()
class SecurityIssue {
  final String id;
  final String title;
  final String category;
  @JsonKey(
    fromJson: _severityFromJson,
    toJson: _severityToJson,
  )
  final Severity severity;
  final String description;
  final String aiGenerationRisk;
  final String claudeCodePrompt;
  final String? filePath;
  final int? lineNumber;

  SecurityIssue({
    required this.id,
    required this.title,
    required this.category,
    required this.severity,
    required this.description,
    required this.aiGenerationRisk,
    required this.claudeCodePrompt,
    this.filePath,
    this.lineNumber,
  });

  factory SecurityIssue.fromJson(Map<String, dynamic> json) =>
      _$SecurityIssueFromJson(json);

  Map<String, dynamic> toJson() => _$SecurityIssueToJson(this);

  static Severity _severityFromJson(String value) => Severity.fromString(value);
  static String _severityToJson(Severity severity) => severity.value;
}
