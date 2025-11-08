// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalysisResult _$AnalysisResultFromJson(Map<String, dynamic> json) =>
    AnalysisResult(
      id: json['id'] as String,
      repositoryUrl: json['repositoryUrl'] as String,
      repositoryName: json['repositoryName'] as String,
      analysisType:
          AnalysisResult._analysisTypeFromJson(json['analysisType'] as String),
      analysisMode: json['analysisMode'] == null
          ? AnalysisMode.staticCode
          : AnalysisResult._analysisModeFromJson(
              json['analysisMode'] as String?),
      timestamp: DateTime.parse(json['timestamp'] as String),
      summary:
          AnalysisSummary.fromJson(json['summary'] as Map<String, dynamic>),
      securityIssues: (json['securityIssues'] as List<dynamic>?)
          ?.map((e) => SecurityIssue.fromJson(e as Map<String, dynamic>))
          .toList(),
      monitoringRecommendations:
          (json['monitoringRecommendations'] as List<dynamic>?)
              ?.map((e) =>
                  MonitoringRecommendation.fromJson(e as Map<String, dynamic>))
              .toList(),
      isDemo: json['isDemo'] as bool? ?? false,
    );

Map<String, dynamic> _$AnalysisResultToJson(AnalysisResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'repositoryUrl': instance.repositoryUrl,
      'repositoryName': instance.repositoryName,
      'analysisType': AnalysisResult._analysisTypeToJson(instance.analysisType),
      'analysisMode': AnalysisResult._analysisModeToJson(instance.analysisMode),
      'timestamp': instance.timestamp.toIso8601String(),
      'summary': instance.summary,
      'securityIssues': instance.securityIssues,
      'monitoringRecommendations': instance.monitoringRecommendations,
      'isDemo': instance.isDemo,
    };

AnalysisSummary _$AnalysisSummaryFromJson(Map<String, dynamic> json) =>
    AnalysisSummary(
      total: (json['total'] as num).toInt(),
      bySeverity: (json['bySeverity'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      byCategory: (json['byCategory'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
    );

Map<String, dynamic> _$AnalysisSummaryToJson(AnalysisSummary instance) =>
    <String, dynamic>{
      'total': instance.total,
      'bySeverity': instance.bySeverity,
      'byCategory': instance.byCategory,
    };
