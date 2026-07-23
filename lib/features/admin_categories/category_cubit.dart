import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_exception.dart';
import '../../data/repositories/category_repository.dart';
import 'category_state.dart';

/// 书籍分类管理逻辑（对照 useTabsHook）。
class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit(this._repository) : super(const CategoryState());

  final CategoryRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final items = await _repository.getCategories();
      emit(state.copyWith(loading: false, items: items));
    } on ApiException catch (e) {
      emit(state.copyWith(loading: false, error: e.message));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  /// 新增/编辑均走创建接口（与原项目一致，后端无独立更新接口）。
  Future<void> saveCategory({required String name, required String slug}) async {
    await _repository.createCategory(name: name, slug: slug);
    await load();
  }

  Future<void> deleteCategory(String id) async {
    await _repository.deleteCategory(id);
    await load();
  }
}
