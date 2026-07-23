import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/character.dart';

part 'home_state.freezed.dart';

/// 文字查询页状态（对照 Home.vue）。
@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default(false) bool loading,
    CharItem? char,
    String? error,
    @Default(false) bool mergeMeanings,
    int? activeVariantId,
  }) = _HomeState;
}
