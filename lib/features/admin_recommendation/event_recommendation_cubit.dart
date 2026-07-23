import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/recommendation.dart';
import '../../data/repositories/recommendation_repository.dart';
import 'event_recommendation_state.dart';

/// 节日推荐管理逻辑（对照 useRecommendationEvent）。
class EventRecommendationCubit extends Cubit<EventRecommendationState> {
  EventRecommendationCubit(this._repository)
      : super(const EventRecommendationState());

  final RecommendationRepository _repository;

  List<EventRecommendation> get filtered {
    final q = state.searchWord;
    if (q.isEmpty) return state.items;
    return state.items.where((e) => e.wordText.contains(q)).toList();
  }

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final items = await _repository.findAllEvent();
      emit(state.copyWith(loading: false, items: items));
    } on ApiException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void setSearch(String q) => emit(state.copyWith(searchWord: q));

  Future<void> create({
    required String specificDate,
    int? wordId,
    required String wordText,
    required bool isActive,
    String? eventName,
    required File file,
  }) async {
    await _repository.createEvent(
      specificDate: specificDate,
      wordId: wordId,
      wordText: wordText,
      isActive: isActive,
      eventName: eventName,
      file: file,
    );
    await load();
  }

  Future<void> update({
    required String specificDate,
    int? wordId,
    required String wordText,
    required bool isActive,
    String? eventName,
    File? file,
    String? imageKey,
  }) async {
    await _repository.updateEvent(
      specificDate: specificDate,
      wordId: wordId,
      wordText: wordText,
      isActive: isActive,
      eventName: eventName,
      file: file,
      imageKey: imageKey,
    );
    await load();
  }

  Future<void> remove(String specificDate) async {
    await _repository.removeEvent(specificDate);
    await load();
  }
}
