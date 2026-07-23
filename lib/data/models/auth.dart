import 'package:json_annotation/json_annotation.dart';

part 'auth.g.dart';

/// 登录请求（对照 authType.d.ts LoginRequest）。
@JsonSerializable()
class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
    required this.deviceName,
    required this.deviceId,
  });

  final String email;
  final String password;
  final String deviceName;
  final String deviceId;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

/// 登录用户信息（对照 authType.d.ts UserInfo）。
@JsonSerializable()
class UserInfo {
  const UserInfo({
    required this.id,
    required this.email,
    this.nickname = '',
    this.avatarUrl = '',
  });

  final int id;
  final String email;
  final String nickname;
  final String avatarUrl;

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}

/// 登录返回（对照 authType.d.ts LoginResponse）。
@JsonSerializable(explicitToJson: true)
class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn,
    this.user,
  });

  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  @JsonKey(name: 'expires_in')
  final String? expiresIn;

  final UserInfo? user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
