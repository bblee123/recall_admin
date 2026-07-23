import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/recommendation.dart';

part 'base_recommendation_state.freezed.dart';

/// 默认推荐页状态（对照 useRecommendationBase）。
@freezed
abstract class BaseRecommendationState with _$BaseRecommendationState {
  const factory BaseRecommendationState({
    @Default(true) bool loading,
    @Default(<BaseRecommendation>[]) List<BaseRecommendation> items,
    @Default('') String searchWord,
    String? error,
  }) = _BaseRecommendationState;
}
