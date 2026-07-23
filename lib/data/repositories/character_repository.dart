import '../../core/network/dio_client.dart';
import '../models/character.dart';
import 'repo_util.dart';

/// 单字查询仓库（对照 api/character.ts）。
class CharacterRepository {
  CharacterRepository(this._client);

  final DioClient _client;

  /// GET /character/{char}
  Future<CharItem> getChar(String char) {
    return guard(() async {
      final res = await _client.public.get<dynamic>('/character/$char');
      throwIfBodyError(res.data);
      return CharItem.fromJson(asMap(res.data));
    });
  }

  /// GET /character/search?text= —— 按文本批量查字（多音字元数据用）。
  Future<List<CharItem>> searchChars(String text) {
    return guard(() async {
      final res = await _client.public.get<dynamic>(
        '/character/search',
        queryParameters: <String, dynamic>{'text': text},
      );
      throwIfBodyError(res.data);
      return asList(res.data)
          .map((e) => CharItem.fromJson(asMap(e)))
          .toList(growable: false);
    });
  }
}
