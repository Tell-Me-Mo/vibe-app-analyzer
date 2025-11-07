import 'package:json_annotation/json_annotation.dart';

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

  MonitoringRecommendation({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.businessValue,
    required this.claudeCodePrompt,
    this.filePath,
    this.lineNumber,
  });

  factory MonitoringRecommendation.fromJson(Map<String, dynamic> json) =>
      _$MonitoringRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$MonitoringRecommendationToJson(this);
}
