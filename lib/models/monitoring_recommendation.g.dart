// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monitoring_recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonitoringRecommendation _$MonitoringRecommendationFromJson(
  Map<String, dynamic> json,
) => MonitoringRecommendation(
  id: json['id'] as String,
  title: json['title'] as String,
  category: json['category'] as String,
  severity: MonitoringRecommendation._severityFromJson(
    json['severity'] as String,
  ),
  description: json['description'] as String,
  businessValue: json['businessValue'] as String,
  claudeCodePrompt: json['claudeCodePrompt'] as String,
  filePath: json['filePath'] as String?,
  lineNumber: (json['lineNumber'] as num?)?.toInt(),
  validationStatus: json['validationStatus'] == null
      ? ValidationStatus.notStarted
      : MonitoringRecommendation._validationStatusFromJson(
          json['validationStatus'] as String?,
        ),
  validationResult: json['validationResult'] == null
      ? null
      : ValidationResult.fromJson(
          json['validationResult'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$MonitoringRecommendationToJson(
  MonitoringRecommendation instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'category': instance.category,
  'severity': MonitoringRecommendation._severityToJson(instance.severity),
  'description': instance.description,
  'businessValue': instance.businessValue,
  'claudeCodePrompt': instance.claudeCodePrompt,
  'filePath': instance.filePath,
  'lineNumber': instance.lineNumber,
  'validationStatus': MonitoringRecommendation._validationStatusToJson(
    instance.validationStatus,
  ),
  'validationResult': instance.validationResult,
};
