import 'package:json_annotation/json_annotation.dart';
import 'analysis_type.dart';
import 'security_issue.dart';
import 'monitoring_recommendation.dart';

part 'analysis_result.g.dart';

@JsonSerializable()
class AnalysisResult {
  final String id;
  final String repositoryUrl;
  final String repositoryName;

  @JsonKey(
    fromJson: _analysisTypeFromJson,
    toJson: _analysisTypeToJson,
  )
  final AnalysisType analysisType;

  final DateTime timestamp;
  final AnalysisSummary summary;
  final List<SecurityIssue>? securityIssues;
  final List<MonitoringRecommendation>? monitoringRecommendations;
  final bool isDemo;

  AnalysisResult({
    required this.id,
    required this.repositoryUrl,
    required this.repositoryName,
    required this.analysisType,
    required this.timestamp,
    required this.summary,
    this.securityIssues,
    this.monitoringRecommendations,
    this.isDemo = false,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$AnalysisResultFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisResultToJson(this);

  static AnalysisType _analysisTypeFromJson(String value) {
    return AnalysisType.values.firstWhere((e) => e.name == value);
  }

  static String _analysisTypeToJson(AnalysisType type) => type.value;
}

@JsonSerializable()
class AnalysisSummary {
  final int total;
  final Map<String, int>? bySeverity;
  final Map<String, int>? byCategory;

  AnalysisSummary({
    required this.total,
    this.bySeverity,
    this.byCategory,
  });

  factory AnalysisSummary.fromJson(Map<String, dynamic> json) =>
      _$AnalysisSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisSummaryToJson(this);
}
