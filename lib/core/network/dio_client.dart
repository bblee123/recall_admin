import 'package:dio/dio.dart';

import '../env.dart';
import '../storage/device_info.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';
import 'session_controller.dart';

/// 应用网络客户端：提供公开实例与管理端实例（对照 Vue 项目 utils/request.ts）。
class DioClient {
  DioClient({
    required TokenStorage tokenStorage,
    required DeviceInfo deviceInfo,
    required SessionController session,
  }) {
    public = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    admin = Dio(
      BaseOptions(
        baseUrl: Env.adminBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    admin.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        deviceInfo: deviceInfo,
        session: session,
      ),
    );
  }

  late final Dio public;
  late final Dio admin;
}
