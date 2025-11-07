// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monitoring_recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonitoringRecommendation _$MonitoringRecommendationFromJson(
        Map<String, dynamic> json) =>
    MonitoringRecommendation(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      businessValue: json['businessValue'] as String,
      claudeCodePrompt: json['claudeCodePrompt'] as String,
      filePath: json['filePath'] as String?,
      lineNumber: (json['lineNumber'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MonitoringRecommendationToJson(
        MonitoringRecommendation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'category': instance.category,
      'description': instance.description,
      'businessValue': instance.businessValue,
      'claudeCodePrompt': instance.claudeCodePrompt,
      'filePath': instance.filePath,
      'lineNumber': instance.lineNumber,
    };
