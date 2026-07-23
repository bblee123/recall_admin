import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../models/recommendation.dart';
import 'repo_util.dart';

/// 推荐仓库（对照 api/admin/recommendation.ts，管理端），含默认推荐与节日推荐。
class RecommendationRepository {
  RecommendationRepository(this._client);

  final DioClient _client;

  Future<MultipartFile> _file(File file) => MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
      );

  // ---------------- base ----------------

  /// GET /admin/recommendations/base
  Future<List<BaseRecommendation>> findAllBase() {
    return guard(() async {
      final res =
          await _client.admin.get<dynamic>('/admin/recommendations/base');
      throwIfBodyError(res.data);
      return asList(res.data)
          .map((e) => BaseRecommendation.fromJson(asMap(e)))
          .toList(growable: false);
    });
  }

  /// POST /admin/recommendations/base
  Future<void> createBase({
    required int dayIndex,
    int? wordId,
    required String wordText,
    required String textColor,
    required String season,
    required File file,
  }) {
    return guard(() async {
      final form = FormData.fromMap(<String, dynamic>{
        'dayIndex': dayIndex.toString(),
        'wordId': wordId?.toString() ?? '',
        'wordText': wordText,
        'textColor': textColor,
        'season': season,
        'file': await _file(file),
      });
      final res = await _client.admin.post<dynamic>(
        '/admin/recommendations/base',
        data: form,
      );
      throwIfBodyError(res.data);
    });
  }

  /// PUT /admin/recommendations/base/{dayIndex}
  Future<void> updateBase({
    required int dayIndex,
    int? wordId,
    required String wordText,
    required String textColor,
    required String season,
    File? file,
  }) {
    return guard(() async {
      final map = <String, dynamic>{
        'dayIndex': dayIndex.toString(),
        'wordId': wordId?.toString() ?? '',
        'wordText': wordText,
        'textColor': textColor,
        'season': season,
      };
      if (file != null) map['file'] = await _file(file);
      final res = await _client.admin.put<dynamic>(
        '/admin/recommendations/base/$dayIndex',
        data: FormData.fromMap(map),
      );
      throwIfBodyError(res.data);
    });
  }

  /// DELETE /admin/recommendations/base/{dayIndex}
  Future<void> removeBase(int dayIndex) {
    return guard(() async {
      final res = await _client.admin
          .delete<dynamic>('/admin/recommendations/base/$dayIndex');
      throwIfBodyError(res.data);
    });
  }

  // ---------------- event ----------------

  /// GET /admin/recommendations/event
  Future<List<EventRecommendation>> findAllEvent() {
    return guard(() async {
      final res =
          await _client.admin.get<dynamic>('/admin/recommendations/event');
      throwIfBodyError(res.data);
      return asList(res.data)
          .map((e) => EventRecommendation.fromJson(asMap(e)))
          .toList(growable: false);
    });
  }

  /// POST /admin/recommendations/event
  Future<void> createEvent({
    required String specificDate,
    int? wordId,
    required String wordText,
    required bool isActive,
    String? eventName,
    required File file,
  }) {
    return guard(() async {
      final form = FormData.fromMap(<String, dynamic>{
        'specificDate': specificDate,
        'wordId': wordId?.toString() ?? '',
        'wordText': wordText,
        'isActive': isActive.toString(),
        'eventName': eventName ?? '',
        'file': await _file(file),
      });
      final res = await _client.admin.post<dynamic>(
        '/admin/recommendations/event',
        data: form,
      );
      throwIfBodyError(res.data);
    });
  }

  /// PUT /admin/recommendations/event/{specificDate}
  Future<void> updateEvent({
    required String specificDate,
    int? wordId,
    required String wordText,
    required bool isActive,
    String? eventName,
    File? file,
    String? imageKey,
  }) {
    return guard(() async {
      final map = <String, dynamic>{
        'specificDate': specificDate,
        'wordId': wordId?.toString() ?? '',
        'wordText': wordText,
        'isActive': isActive.toString(),
        'eventName': eventName ?? '',
      };
      if (file != null) {
        map['file'] = await _file(file);
      } else if (imageKey != null && imageKey.isNotEmpty) {
        map['imageKey'] = imageKey;
      }
      final res = await _client.admin.put<dynamic>(
        '/admin/recommendations/event/$specificDate',
        data: FormData.fromMap(map),
      );
      throwIfBodyError(res.data);
    });
  }

  /// DELETE /admin/recommendations/event/{specificDate}
  Future<void> removeEvent(String specificDate) {
    return guard(() async {
      final res = await _client.admin
          .delete<dynamic>('/admin/recommendations/event/$specificDate');
      throwIfBodyError(res.data);
    });
  }
}
