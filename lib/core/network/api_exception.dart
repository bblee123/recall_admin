import 'package:dio/dio.dart';

/// 统一 API 异常，携带可读消息（对照 Vue 项目 ElMessage.error 的展示文案）。
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;

  /// 从后端返回体中解析错误消息（支持 message 为字符串或数组）。
  static String? messageFromData(dynamic data) {
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
      if (message is List && message.isNotEmpty) return message.join('，');
      final error = data['error'];
      if (error is String && error.isNotEmpty) return error;
    }
    return null;
  }

  /// 将 DioException 归一化为 ApiException。
  factory ApiException.fromDio(DioException e) {
    final fromBody = messageFromData(e.response?.data);
    final status = e.response?.statusCode;
    if (fromBody != null) {
      return ApiException(fromBody, statusCode: status);
    }
    final fallback = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        '请求超时，请检查网络或后端服务',
      DioExceptionType.connectionError => '无法连接后端服务（127.0.0.1）',
      _ => e.message ?? '请求失败',
    };
    return ApiException(fallback, statusCode: status);
  }
}
