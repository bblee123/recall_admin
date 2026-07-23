import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/category.dart';

part 'category_state.freezed.dart';

/// 书籍分类页状态（对照 admin-categories/index.vue）。
@freezed
abstract class CategoryState with _$CategoryState {
  const factory CategoryState({
    @Default(true) bool loading,
    @Default(<Category>[]) List<Category> items,
    String? error,
  }) = _CategoryState;
}
