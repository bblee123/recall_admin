import '../../core/network/dio_client.dart';
import '../models/auth.dart';
import 'repo_util.dart';

/// 管理端登录仓库（对照 api/admin/auth.ts）。
class AuthRepository {
  AuthRepository(this._client);

  final DioClient _client;

  /// POST /admin/auth/login
  Future<LoginResponse> login(LoginRequest request) {
    return guard(() async {
      final res = await _client.admin.post<dynamic>(
        '/admin/auth/login',
        data: request.toJson(),
      );
      throwIfBodyError(res.data);
      return LoginResponse.fromJson(asMap(res.data));
    });
  }
}
