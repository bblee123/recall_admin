import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/book.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/category_repository.dart';
import 'books_state.dart';

/// 书籍管理逻辑（对照 useBooks + useDialogHook）。
class BooksCubit extends Cubit<BooksState> {
  BooksCubit({
    required BookRepository bookRepository,
    required CategoryRepository categoryRepository,
    String? initialCategoryId,
  })  : _bookRepository = bookRepository,
        _categoryRepository = categoryRepository,
        super(BooksState(categoryId: initialCategoryId ?? ''));

  final BookRepository _bookRepository;
  final CategoryRepository _categoryRepository;

  Future<void> init() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final categories = await _categoryRepository.getCategories();
      var categoryId = state.categoryId;
      if (categoryId.isEmpty && categories.isNotEmpty) {
        categoryId = categories.first.id;
      }
      emit(state.copyWith(categories: categories, categoryId: categoryId));
      await loadBooks();
    } on ApiException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> selectCategory(String id) async {
    emit(state.copyWith(categoryId: id));
    await loadBooks();
  }

  Future<void> loadBooks() async {
    if (state.categoryId.isEmpty) {
      emit(state.copyWith(loading: false, books: const <Book>[]));
      return;
    }
    emit(state.copyWith(loading: true, error: null));
    try {
      final books = await _bookRepository.getBooks(state.categoryId);
      emit(state.copyWith(loading: false, books: books));
    } on ApiException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> createBook({
    required String title,
    required String subtitle,
    required bool isFree,
    required int order,
    required List<BookUnit> units,
    required File coverFile,
  }) async {
    await _bookRepository.createBook(
      title: title,
      subtitle: subtitle,
      coverUrl: '',
      isFree: isFree,
      order: order,
      categoryId: state.categoryId,
      units: units,
      coverFile: coverFile,
    );
    await loadBooks();
  }

  Future<void> updateBook({
    required String id,
    required String title,
    required String subtitle,
    required String coverUrl,
    required bool isFree,
    required int order,
    required List<BookUnit> units,
    File? coverFile,
  }) async {
    await _bookRepository.updateBook(
      id: id,
      title: title,
      subtitle: subtitle,
      coverUrl: coverUrl,
      isFree: isFree,
      order: order,
      categoryId: state.categoryId,
      units: units,
      coverFile: coverFile,
    );
    await loadBooks();
  }

  Future<void> deleteBook(String id) async {
    await _bookRepository.deleteBook(id);
    await loadBooks();
  }
}
