import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/recommendation.dart';

part 'event_recommendation_state.freezed.dart';

/// 节日推荐页状态（对照 useRecommendationEvent）。
@freezed
abstract class EventRecommendationState with _$EventRecommendationState {
  const factory EventRecommendationState({
    @Default(true) bool loading,
    @Default(<EventRecommendation>[]) List<EventRecommendation> items,
    @Default('') String searchWord,
    String? error,
  }) = _EventRecommendationState;
}
