import '../../core/network/dio_client.dart';
import '../models/word.dart';
import 'repo_util.dart';

/// 词汇仓库（对照 api/word.ts）。
class WordRepository {
  WordRepository(this._client);

  final DioClient _client;

  /// GET /word
  Future<WordListResponse> getWords({
    int page = 1,
    int limit = 10,
    String searchText = '',
    int searchType = 1,
  }) {
    return guard(() async {
      final res = await _client.public.get<dynamic>(
        '/word',
        queryParameters: <String, dynamic>{
          'page': page,
          'limit': limit,
          'text': searchText,
          'searchType': searchType,
        },
      );
      throwIfBodyError(res.data);
      return WordListResponse.fromJson(asMap(res.data));
    });
  }

  /// POST /word
  Future<void> createWord(Word word) {
    return guard(() async {
      final res = await _client.public.post<dynamic>('/word', data: word.toJson());
      throwIfBodyError(res.data);
    });
  }

  /// PUT /word
  Future<void> updateWord(Word word) {
    return guard(() async {
      final res = await _client.public.put<dynamic>('/word', data: word.toJson());
      throwIfBodyError(res.data);
    });
  }

  /// DELETE /word/{id}
  Future<void> deleteWord(int id) {
    return guard(() async {
      final res = await _client.public.delete<dynamic>('/word/$id');
      throwIfBodyError(res.data);
    });
  }

  /// POST /word/find_words —— 按 text（字符或 id 数组）批量查词。
  Future<List<Word>> searchWords(List<dynamic> text) {
    return guard(() async {
      final res = await _client.public.post<dynamic>(
        '/word/find_words',
        data: <String, dynamic>{'text': text},
      );
      throwIfBodyError(res.data);
      return asList(res.data)
          .map((e) => Word.fromJson(asMap(e)))
          .toList(growable: false);
    });
  }
}
