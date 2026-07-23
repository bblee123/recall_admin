import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/recommendation.dart';
import '../../data/repositories/recommendation_repository.dart';
import 'base_recommendation_state.dart';

/// 默认推荐管理逻辑（对照 useRecommendationBase）。
class BaseRecommendationCubit extends Cubit<BaseRecommendationState> {
  BaseRecommendationCubit(this._repository)
      : super(const BaseRecommendationState());

  final RecommendationRepository _repository;

  List<BaseRecommendation> get filtered {
    final q = state.searchWord;
    if (q.isEmpty) return state.items;
    return state.items.where((e) => e.wordText.contains(q)).toList();
  }

  /// 新建时的默认 dayIndex：最大值 + 1。
  int get nextDayIndex {
    if (state.items.isEmpty) return 1;
    final max = state.items
        .map((e) => e.dayIndex)
        .reduce((a, b) => a > b ? a : b);
    return max + 1;
  }

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final items = await _repository.findAllBase();
      emit(state.copyWith(loading: false, items: items));
    } on ApiException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void setSearch(String q) => emit(state.copyWith(searchWord: q));

  Future<void> create({
    required int dayIndex,
    int? wordId,
    required String wordText,
    required String textColor,
    required String season,
    required File file,
  }) async {
    await _repository.createBase(
      dayIndex: dayIndex,
      wordId: wordId,
      wordText: wordText,
      textColor: textColor,
      season: season,
      file: file,
    );
    await load();
  }

  Future<void> update({
    required int dayIndex,
    int? wordId,
    required String wordText,
    required String textColor,
    required String season,
    File? file,
  }) async {
    await _repository.updateBase(
      dayIndex: dayIndex,
      wordId: wordId,
      wordText: wordText,
      textColor: textColor,
      season: season,
      file: file,
    );
    await load();
  }

  Future<void> remove(int dayIndex) async {
    await _repository.removeBase(dayIndex);
    await load();
  }
}
