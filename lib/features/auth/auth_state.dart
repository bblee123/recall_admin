import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/auth.dart';

part 'auth_state.freezed.dart';

/// 管理端登录状态（对照 Vue 项目 useAppStore.loginDialog + 登录流程）。
@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool loggedIn,
    @Default(false) bool submitting,
    @Default(false) bool dialogVisible,
    @Default('/') String redirectPath,
    String? error,
    UserInfo? user,
  }) = _AuthState;
}
