import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/book.dart';
import '../../data/models/category.dart';

part 'books_state.freezed.dart';

/// 书籍管理页状态（对照 admin-books/index.vue + useBooks）。
@freezed
abstract class BooksState with _$BooksState {
  const factory BooksState({
    @Default(true) bool loading,
    @Default(<Category>[]) List<Category> categories,
    @Default('') String categoryId,
    @Default(<Book>[]) List<Book> books,
    String? error,
  }) = _BooksState;
}
