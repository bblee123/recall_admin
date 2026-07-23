import 'package:dio/dio.dart';

import '../../core/network/api_exception.dart';

/// 统一包装网络调用：DioException -> ApiException，并检查返回体内嵌的 error 字段。
Future<T> guard<T>(Future<T> Function() run) async {
  try {
    return await run();
  } on DioException catch (e) {
    throw ApiException.fromDio(e);
  }
}

/// 部分接口即便 HTTP 200 也会在 body 里带 error/message，需主动校验。
void throwIfBodyError(dynamic data) {
  if (data is Map && data['error'] != null) {
    final msg = ApiException.messageFromData(data) ?? '请求失败';
    throw ApiException(msg);
  }
}

/// 安全地把返回体转换为 Map。
Map<String, dynamic> asMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return <String, dynamic>{};
}

/// 安全地把返回体转换为 List。
List<dynamic> asList(dynamic data) {
  if (data is List) return data;
  return const <dynamic>[];
}
