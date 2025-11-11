// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_issue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SecurityIssue _$SecurityIssueFromJson(Map<String, dynamic> json) =>
    SecurityIssue(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      severity: SecurityIssue._severityFromJson(json['severity'] as String),
      description: json['description'] as String,
      aiGenerationRisk: json['aiGenerationRisk'] as String,
      claudeCodePrompt: json['claudeCodePrompt'] as String,
      filePath: json['filePath'] as String?,
      lineNumber: (json['lineNumber'] as num?)?.toInt(),
      validationStatus: json['validationStatus'] == null
          ? ValidationStatus.notStarted
          : SecurityIssue._validationStatusFromJson(
              json['validationStatus'] as String?,
            ),
      validationResult: json['validationResult'] == null
          ? null
          : ValidationResult.fromJson(
              json['validationResult'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$SecurityIssueToJson(SecurityIssue instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'category': instance.category,
      'severity': SecurityIssue._severityToJson(instance.severity),
      'description': instance.description,
      'aiGenerationRisk': instance.aiGenerationRisk,
      'claudeCodePrompt': instance.claudeCodePrompt,
      'filePath': instance.filePath,
      'lineNumber': instance.lineNumber,
      'validationStatus': SecurityIssue._validationStatusToJson(
        instance.validationStatus,
      ),
      'validationResult': instance.validationResult,
    };
