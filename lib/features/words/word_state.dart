import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/word.dart';

part 'word_state.freezed.dart';

/// 词汇管理页状态（对照 words/index.vue）。
@freezed
abstract class WordState with _$WordState {
  const factory WordState({
    @Default(true) bool loading,
    @Default(<Word>[]) List<Word> items,
    @Default(0) int total,
    @Default(1) int page,
    @Default(20) int pageSize,
    // 1 精确 / 0 模糊
    @Default(1) int searchType,
    @Default('') String searchText,
    String? error,
  }) = _WordState;
}
