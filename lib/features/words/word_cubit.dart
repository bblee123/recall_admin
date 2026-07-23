import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/word.dart';
import '../../data/repositories/word_repository.dart';
import 'word_state.dart';

/// 词汇管理逻辑（对照 words/index.vue + wordDialogHooks）。
class WordCubit extends Cubit<WordState> {
  WordCubit(this._repository) : super(const WordState());

  final WordRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final res = await _repository.getWords(
        page: state.page,
        limit: state.pageSize,
        searchText: state.searchText,
        searchType: state.searchType,
      );
      emit(state.copyWith(
        loading: false,
        items: res.data,
        total: res.total,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void setSearchType(int type) {
    emit(state.copyWith(searchType: type, page: 1));
    load();
  }

  void setSearch(String text) => emit(state.copyWith(searchText: text));

  void searchNow() {
    emit(state.copyWith(page: 1));
    load();
  }

  void setPage(int page) {
    emit(state.copyWith(page: page));
    load();
  }

  void setPageSize(int size) {
    emit(state.copyWith(pageSize: size, page: 1));
    load();
  }

  Future<void> saveWord(Word word, bool isCreate) async {
    if (isCreate) {
      await _repository.createWord(word);
    } else {
      await _repository.updateWord(word);
    }
    await load();
  }

  Future<void> deleteWord(int id) async {
    await _repository.deleteWord(id);
    await load();
  }
}
