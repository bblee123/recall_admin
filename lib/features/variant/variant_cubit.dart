import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/variant.dart';
import '../../data/repositories/variant_repository.dart';
import 'variant_state.dart';

/// 释义管理逻辑（对照 variant/index.vue + 各 hooks）。
class VariantCubit extends Cubit<VariantState> {
  VariantCubit(this._repository) : super(const VariantState());

  final VariantRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final res = await _repository.getVariants(
        page: state.page,
        limit: state.pageSize,
        searchText: state.searchText,
        type: state.audioType,
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

  void setAudioType(int type) {
    emit(state.copyWith(audioType: type, page: 1));
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

  void toggleSelect(int id, bool selected) {
    final next = Set<int>.from(state.selectedIds);
    if (selected) {
      next.add(id);
    } else {
      next.remove(id);
    }
    emit(state.copyWith(selectedIds: next));
  }

  void clearSelection() => emit(state.copyWith(selectedIds: <int>{}));

  Future<void> saveVariant(Variant variant, bool isCreate) async {
    if (isCreate) {
      await _repository.createVariant(variant);
    } else {
      await _repository.updateVariant(variant);
    }
    await load();
  }

  Future<void> uploadAudio(Variant variant, File file) async {
    await _repository.uploadAudio(
      file: file,
      variantId: variant.id,
      fileName: '${variant.charText}_${variant.pinyinRaw}.mp3',
    );
    await load();
  }

  Future<void> deleteAudio(Variant variant) async {
    await _repository.deleteAudio(variant.id);
    await load();
  }

  Future<void> generateAudio(Variant variant) async {
    await _repository.generateAudio(
      GenerateAudioRequest(
        text: variant.charText,
        variantId: variant.id,
        fileName: '${variant.charText}_${variant.pinyinRaw}',
        pinyinRaw: variant.pinyinRaw,
      ),
    );
  }

  /// 批量生成：逐条生成，间隔 1s（对照 batchGenerateAudio）。
  Future<void> batchGenerate() async {
    final selected =
        state.items.where((v) => state.selectedIds.contains(v.id)).toList();
    for (final row in selected) {
      await generateAudio(row);
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    await load();
  }
}
