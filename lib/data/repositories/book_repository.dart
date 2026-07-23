import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../models/book.dart';
import 'repo_util.dart';

/// 书籍仓库（对照 api/admin/book.ts，管理端）。
class BookRepository {
  BookRepository(this._client);

  final DioClient _client;

  /// GET /admin/books?categoryId=
  Future<List<Book>> getBooks(String categoryId) {
    return guard(() async {
      final res = await _client.admin.get<dynamic>(
        '/admin/books',
        queryParameters: <String, dynamic>{'categoryId': categoryId},
      );
      throwIfBodyError(res.data);
      return asList(res.data)
          .map((e) => Book.fromJson(asMap(e)))
          .toList(growable: false);
    });
  }

  /// 序列化单元为后端期望的结构（title/description/order/wordIds/id?）。
  static String _encodeUnits(List<BookUnit> units) {
    final list = units.map((u) {
      final map = <String, dynamic>{
        'title': u.title,
        'description': u.description,
        'order': u.order,
        'wordIds': u.wordIds,
      };
      if ((u.id ?? '').isNotEmpty) map['id'] = u.id;
      return map;
    }).toList();
    return jsonEncode(list);
  }

  Future<FormData> _buildForm({
    required String title,
    required String subtitle,
    required String coverUrl,
    required bool isFree,
    required int order,
    required String categoryId,
    required List<BookUnit> units,
    File? coverFile,
  }) async {
    final map = <String, dynamic>{
      'title': title,
      'subtitle': subtitle,
      'coverUrl': coverUrl,
      'isFree': isFree ? 'true' : 'false',
      'order': order.toString(),
      'categoryId': categoryId,
      'units': _encodeUnits(units),
    };
    if (coverFile != null) {
      map['coverFile'] = await MultipartFile.fromFile(
        coverFile.path,
        filename: coverFile.uri.pathSegments.last,
      );
    }
    return FormData.fromMap(map);
  }

  /// POST /admin/books
  Future<void> createBook({
    required String title,
    required String subtitle,
    required String coverUrl,
    required bool isFree,
    required int order,
    required String categoryId,
    required List<BookUnit> units,
    required File coverFile,
  }) {
    return guard(() async {
      final form = await _buildForm(
        title: title,
        subtitle: subtitle,
        coverUrl: coverUrl,
        isFree: isFree,
        order: order,
        categoryId: categoryId,
        units: units,
        coverFile: coverFile,
      );
      final res = await _client.admin.post<dynamic>('/admin/books', data: form);
      throwIfBodyError(res.data);
    });
  }

  /// PATCH /admin/books/{id}
  Future<void> updateBook({
    required String id,
    required String title,
    required String subtitle,
    required String coverUrl,
    required bool isFree,
    required int order,
    required String categoryId,
    required List<BookUnit> units,
    File? coverFile,
  }) {
    return guard(() async {
      final form = await _buildForm(
        title: title,
        subtitle: subtitle,
        coverUrl: coverUrl,
        isFree: isFree,
        order: order,
        categoryId: categoryId,
        units: units,
        coverFile: coverFile,
      );
      final res = await _client.admin.patch<dynamic>(
        '/admin/books/$id',
        data: form,
      );
      throwIfBodyError(res.data);
    });
  }

  /// DELETE /admin/books/{id}
  Future<void> deleteBook(String id) {
    return guard(() async {
      final res = await _client.admin.delete<dynamic>('/admin/books/$id');
      throwIfBodyError(res.data);
    });
  }
}
