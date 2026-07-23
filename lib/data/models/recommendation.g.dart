// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseRecommendation _$BaseRecommendationFromJson(Map<String, dynamic> json) =>
    BaseRecommendation(
      dayIndex: (json['dayIndex'] as num).toInt(),
      wordId: (json['wordId'] as num?)?.toInt(),
      wordText: json['wordText'] as String? ?? '',
      imageKey: json['imageKey'] as String? ?? '',
      textColor: json['textColor'] as String? ?? '#000000',
      season: json['season'] as String? ?? 'Spring',
    );

Map<String, dynamic> _$BaseRecommendationToJson(BaseRecommendation instance) =>
    <String, dynamic>{
      'dayIndex': instance.dayIndex,
      'wordId': instance.wordId,
      'wordText': instance.wordText,
      'imageKey': instance.imageKey,
      'textColor': instance.textColor,
      'season': instance.season,
    };

EventRecommendation _$EventRecommendationFromJson(Map<String, dynamic> json) =>
    EventRecommendation(
      specificDate: json['specificDate'] as String,
      wordId: (json['wordId'] as num?)?.toInt(),
      wordText: json['wordText'] as String? ?? '',
      imageKey: json['imageKey'] as String? ?? '',
      eventName: json['eventName'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$EventRecommendationToJson(
  EventRecommendation instance,
) => <String, dynamic>{
  'specificDate': instance.specificDate,
  'wordId': instance.wordId,
  'wordText': instance.wordText,
  'imageKey': instance.imageKey,
  'eventName': instance.eventName,
  'isActive': instance.isActive,
};
