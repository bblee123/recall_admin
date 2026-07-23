import 'dart:async';

import 'package:dio/dio.dart';

import '../env.dart';
import '../storage/device_info.dart';
import '../storage/token_storage.dart';
import 'session_controller.dart';

/// 管理端请求拦截器（对照 Vue 项目 adminAlovaInstance）。
///
/// - 请求前注入 `Authorization: Bearer <admin_token>`。
/// - 命中 401 时单飞刷新 token 并重放请求；刷新失败清 token 并触发登录。
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.tokenStorage,
    required this.deviceInfo,
    required this.session,
  });

  final TokenStorage tokenStorage;
  final DeviceInfo deviceInfo;
  final SessionController session;

  /// 独立 Dio，用于刷新 token，避免走拦截器造成死循环。
  final Dio _refreshDio = Dio(BaseOptions(baseUrl: Env.adminBaseUrl));

  Completer<bool>? _refreshing;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenStorage.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final isUnauthorized = response?.statusCode == 401;
    final isRefreshCall =
        err.requestOptions.path.contains('/api/auth/refresh');

    if (!isUnauthorized || isRefreshCall) {
      return handler.next(err);
    }

    final refreshed = await _refreshToken();
    if (!refreshed) {
      await tokenStorage.clear();
      session.requireLogin();
      return handler.next(err);
    }

    // 用最新 token 重放原请求。
    try {
      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer ${tokenStorage.accessToken}';
      final clone = await _refreshDio.fetch<dynamic>(options);
      return handler.resolve(clone);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  /// 单飞刷新：并发 401 只触发一次刷新。
  Future<bool> _refreshToken() {
    final inFlight = _refreshing;
    if (inFlight != null) return inFlight.future;

    final completer = Completer<bool>();
    _refreshing = completer;

    () async {
      try {
        final res = await _refreshDio.post<Map<String, dynamic>>(
          '/api/auth/refresh',
          data: <String, dynamic>{
            'refreshToken': tokenStorage.refreshToken ?? '',
            'deviceId': deviceInfo.getOrCreateDeviceId(),
          },
        );
        final data = res.data ?? const <String, dynamic>{};
        final access = data['access_token'] as String?;
        final refresh = data['refresh_token'] as String?;
        if (access != null && access.isNotEmpty) {
          await tokenStorage.saveTokens(
            accessToken: access,
            refreshToken: refresh ?? tokenStorage.refreshToken ?? '',
          );
          completer.complete(true);
        } else {
          completer.complete(false);
        }
      } catch (_) {
        completer.complete(false);
      } finally {
        _refreshing = null;
      }
    }();

    return completer.future;
  }
}
