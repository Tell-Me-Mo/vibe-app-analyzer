// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'validation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ValidationResult _$ValidationResultFromJson(Map<String, dynamic> json) =>
    ValidationResult(
      id: json['id'] as String,
      status: ValidationResult._statusFromJson(json['status'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      summary: json['summary'] as String?,
      details: json['details'] as String?,
      remainingIssues: (json['remainingIssues'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      recommendation: json['recommendation'] as String?,
    );

Map<String, dynamic> _$ValidationResultToJson(ValidationResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': ValidationResult._statusToJson(instance.status),
      'timestamp': instance.timestamp.toIso8601String(),
      'summary': instance.summary,
      'details': instance.details,
      'remainingIssues': instance.remainingIssues,
      'recommendation': instance.recommendation,
    };
