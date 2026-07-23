import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/variant.dart';
import '../../data/repositories/character_repository.dart';
import 'home_state.dart';

/// 文字查询逻辑（对照 Home.vue + getChar）。
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeState());

  final CharacterRepository _repository;

  Future<void> search(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    emit(state.copyWith(loading: true, error: null));
    try {
      final char = await _repository.getChar(trimmed);
      final firstId =
          char.variants.isNotEmpty ? char.variants.first.id : null;
      emit(state.copyWith(
        loading: false,
        char: char,
        activeVariantId: firstId,
        mergeMeanings: false,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void toggleMerge(bool merge) {
    final merged = mergedVariants(merge: merge);
    emit(state.copyWith(
      mergeMeanings: merge,
      activeVariantId: merged.isNotEmpty ? merged.first.id : null,
    ));
  }

  void setActive(int id) => emit(state.copyWith(activeVariantId: id));

  /// 合并多音释义（对照 Home.vue variants computed）。
  List<Variant> mergedVariants({bool? merge}) {
    final char = state.char;
    if (char == null) return const <Variant>[];
    final useMerge = merge ?? state.mergeMeanings;
    if (!useMerge) return char.variants;

    final map = <String, Variant>{};
    for (final v in char.variants) {
      final existing = map[v.pinyin];
      if (existing != null) {
        map[v.pinyin] =
            existing.copyWith(meaning: '${existing.meaning}&split& ${v.meaning}');
      } else {
        map[v.pinyin] = v;
      }
    }
    return map.values.toList(growable: false);
  }
}
