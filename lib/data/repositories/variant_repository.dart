import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../models/variant.dart';
import 'repo_util.dart';

/// 汉字释义仓库（对照 api/variant.ts）。
class VariantRepository {
  VariantRepository(this._client);

  final DioClient _client;

  /// GET /variant —— type: 0 全部 / 1 已生成 / 2 未生成（对照页面筛选）。
  Future<VariantListResponse> getVariants({
    int page = 1,
    int limit = 10,
    String searchText = '',
    required int type,
  }) {
    return guard(() async {
      final res = await _client.public.get<dynamic>(
        '/variant',
        queryParameters: <String, dynamic>{
          'page': page,
          'limit': limit,
          'char_text': searchText,
          'type': type,
        },
      );
      throwIfBodyError(res.data);
      return VariantListResponse.fromJson(asMap(res.data));
    });
  }

  /// POST /variant
  Future<void> createVariant(Variant variant) {
    return guard(() async {
      final res = await _client.public.post<dynamic>(
        '/variant',
        data: variant.toJson(),
      );
      throwIfBodyError(res.data);
    });
  }

  /// PUT /variant
  Future<void> updateVariant(Variant variant) {
    return guard(() async {
      final res = await _client.public.put<dynamic>(
        '/variant',
        data: variant.toJson(),
      );
      throwIfBodyError(res.data);
    });
  }

  /// POST /variant/upload-audio —— 上传 mp3 文件。
  Future<void> uploadAudio({
    required File file,
    required int variantId,
    required String fileName,
  }) {
    return guard(() async {
      final form = FormData.fromMap(<String, dynamic>{
        'variantId': variantId,
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'fileName': fileName,
      });
      final res = await _client.public.post<dynamic>(
        '/variant/upload-audio',
        data: form,
      );
      throwIfBodyError(res.data);
    });
  }

  /// DELETE /variant/audio/{id}
  Future<void> deleteAudio(int id) {
    return guard(() async {
      final res = await _client.public.delete<dynamic>('/variant/audio/$id');
      throwIfBodyError(res.data);
    });
  }

  /// POST /variant/generate-audio —— AI 生成音频。
  Future<void> generateAudio(GenerateAudioRequest req) {
    return guard(() async {
      final res = await _client.public.post<dynamic>(
        '/variant/generate-audio',
        data: req.toJson(),
      );
      throwIfBodyError(res.data);
    });
  }
}
