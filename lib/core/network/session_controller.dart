import 'package:flutter/foundation.dart';

/// 会话事件中枢：token 刷新失败或访问受限时通知 UI 弹出登录框。
///
/// 对照 Vue 项目中 `useAppStore().openLoginDialog(path)` 的作用。
class SessionController extends ChangeNotifier {
  bool _loginRequested = false;
  String _redirectPath = '/';

  bool get loginRequested => _loginRequested;
  String get redirectPath => _redirectPath;

  /// 请求登录（可携带登录成功后要跳转的路径）。
  void requireLogin([String? path]) {
    if (path != null && path.isNotEmpty) {
      _redirectPath = path;
    }
    _loginRequested = true;
    notifyListeners();
  }

  /// 登录完成后复位。
  void resolved() {
    _loginRequested = false;
    notifyListeners();
  }
}
