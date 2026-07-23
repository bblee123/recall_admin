import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/session_controller.dart';
import '../../core/storage/device_info.dart';
import '../../core/storage/token_storage.dart';
import '../../data/models/auth.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

/// 登录状态管理（Cubit 属于 bloc 库）。
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthRepository repository,
    required TokenStorage tokenStorage,
    required DeviceInfo deviceInfo,
    required SessionController session,
  })  : _repository = repository,
        _tokenStorage = tokenStorage,
        _deviceInfo = deviceInfo,
        _session = session,
        super(const AuthState()) {
    _session.addListener(_onSessionChanged);
    emit(state.copyWith(loggedIn: _tokenStorage.hasToken));
  }

  final AuthRepository _repository;
  final TokenStorage _tokenStorage;
  final DeviceInfo _deviceInfo;
  final SessionController _session;

  String get deviceId => _deviceInfo.getOrCreateDeviceId();
  String get deviceName => _deviceInfo.resolveDeviceName();

  void _onSessionChanged() {
    if (_session.loginRequested) {
      openDialog(_session.redirectPath);
    }
  }

  /// 打开登录弹窗（可携带登录后跳转路径）。
  void openDialog([String? path]) {
    emit(state.copyWith(
      dialogVisible: true,
      redirectPath: path ?? state.redirectPath,
      error: null,
    ));
  }

  void closeDialog() {
    emit(state.copyWith(dialogVisible: false, error: null));
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(submitting: true, error: null));
    try {
      final res = await _repository.login(
        LoginRequest(
          email: email,
          password: password,
          deviceName: deviceName,
          deviceId: deviceId,
        ),
      );
      await _tokenStorage.saveTokens(
        accessToken: res.accessToken,
        refreshToken: res.refreshToken,
      );
      _session.resolved();
      emit(state.copyWith(
        submitting: false,
        loggedIn: true,
        dialogVisible: false,
        user: res.user,
        error: null,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(submitting: false, error: e.message));
    } catch (e) {
      emit(state.copyWith(submitting: false, error: e.toString()));
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    emit(state.copyWith(loggedIn: false, user: null));
  }

  @override
  Future<void> close() {
    _session.removeListener(_onSessionChanged);
    return super.close();
  }
}
