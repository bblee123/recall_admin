import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// 登录所需的设备信息（对照 Vue 项目 useDeviceInfo）。
///
/// deviceId 首次生成后持久化，保证同一设备标识稳定；deviceName 用可读描述。
class DeviceInfo {
  DeviceInfo(this._prefs);

  final SharedPreferences _prefs;

  static const String deviceIdKey = 'hanzi_tool_device_id';

  String getOrCreateDeviceId() {
    var id = _prefs.getString(deviceIdKey);
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      _prefs.setString(deviceIdKey, id);
    }
    return id;
  }

  String resolveDeviceName() {
    final os = Platform.operatingSystem;
    final version = Platform.operatingSystemVersion;
    return 'macOS · $os · Desktop ($version)';
  }
}
