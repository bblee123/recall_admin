import '../../core/network/dio_client.dart';
import '../models/category.dart';
import 'repo_util.dart';

/// 书籍分类仓库（对照 api/admin/categorie.ts，管理端）。
class CategoryRepository {
  CategoryRepository(this._client);

  final DioClient _client;

  /// GET /admin/categories
  Future<List<Category>> getCategories() {
    return guard(() async {
      final res = await _client.admin.get<dynamic>('/admin/categories');
      throwIfBodyError(res.data);
      return asList(res.data)
          .map((e) => Category.fromJson(asMap(e)))
          .toList(growable: false);
    });
  }

  /// POST /admin/categories
  Future<void> createCategory({
    required String name,
    required String slug,
    int? order,
  }) {
    return guard(() async {
      final res = await _client.admin.post<dynamic>(
        '/admin/categories',
        data: <String, dynamic>{
          'name': name,
          'slug': slug,
          'order': ?order,
        },
      );
      throwIfBodyError(res.data);
    });
  }

  /// DELETE /admin/categories/{id}
  Future<void> deleteCategory(String id) {
    return guard(() async {
      final res = await _client.admin.delete<dynamic>('/admin/categories/$id');
      throwIfBodyError(res.data);
    });
  }
}
