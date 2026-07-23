import 'package:json_annotation/json_annotation.dart';

part 'recommendation.g.dart';

/// 默认推荐（对照 recommendation.ts BaseRecommendationRes）。
@JsonSerializable()
class BaseRecommendation {
  const BaseRecommendation({
    required this.dayIndex,
    this.wordId,
    this.wordText = '',
    this.imageKey = '',
    this.textColor = '#000000',
    this.season = 'Spring',
  });

  final int dayIndex;
  final int? wordId;
  final String wordText;
  final String imageKey;
  final String textColor;

  /// Spring | Summer | Autumn | Winter
  final String season;

  factory BaseRecommendation.fromJson(Map<String, dynamic> json) =>
      _$BaseRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$BaseRecommendationToJson(this);
}

/// 节日/活动推荐（对照 recommendation.ts EventRecommendationRes）。
@JsonSerializable()
class EventRecommendation {
  const EventRecommendation({
    required this.specificDate,
    this.wordId,
    this.wordText = '',
    this.imageKey = '',
    this.eventName,
    this.isActive = true,
  });

  final String specificDate;
  final int? wordId;
  final String wordText;
  final String imageKey;
  final String? eventName;
  final bool isActive;

  factory EventRecommendation.fromJson(Map<String, dynamic> json) =>
      _$EventRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$EventRecommendationToJson(this);
}

/// 季节可选值。
const List<String> kSeasons = <String>['Spring', 'Summer', 'Autumn', 'Winter'];
