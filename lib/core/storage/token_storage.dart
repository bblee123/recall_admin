import 'package:shared_preferences/shared_preferences.dart';

/// 管理端 token 本地存储（对照 Vue 项目 localStorage 中的 admin_token / refresh_token）。
class TokenStorage {
  TokenStorage(this._prefs);

  final SharedPreferences _prefs;

  static const String adminTokenKey = 'admin_token';
  static const String refreshTokenKey = 'refresh_token';

  String? get accessToken => _prefs.getString(adminTokenKey);

  String? get refreshToken => _prefs.getString(refreshTokenKey);

  bool get hasToken => (accessToken ?? '').isNotEmpty;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _prefs.setString(adminTokenKey, accessToken);
    await _prefs.setString(refreshTokenKey, refreshToken);
  }

  Future<void> clear() async {
    await _prefs.remove(adminTokenKey);
    await _prefs.remove(refreshTokenKey);
  }
}
