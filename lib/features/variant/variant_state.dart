import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/variant.dart';

part 'variant_state.freezed.dart';

/// 释义管理页状态（对照 variant/index.vue）。
@freezed
abstract class VariantState with _$VariantState {
  const factory VariantState({
    @Default(true) bool loading,
    @Default(<Variant>[]) List<Variant> items,
    @Default(0) int total,
    @Default(1) int page,
    @Default(100) int pageSize,
    // 1 全部 / 2 已生成 / 3 未生成
    @Default(1) int audioType,
    @Default('') String searchText,
    @Default(<int>{}) Set<int> selectedIds,
    String? error,
  }) = _VariantState;
}
