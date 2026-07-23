/// 后端地址常量（对照 Vue 项目 .env.development）。
///
/// - [apiBaseUrl] 公开接口（文字/释义/词汇）。
/// - [adminBaseUrl] 管理端接口（分类/书籍/推荐/登录/刷新）。
/// - [r2BaseUrl] 图片资源展示域名（书籍封面/推荐配图）。
class Env {
  const Env._();

  static const String apiBaseUrl = 'http://127.0.0.1:3000';
  static const String adminBaseUrl = 'http://127.0.0.1:3004';
  static const String r2BaseUrl =
      'https://pub-f83f97baa906439497f5a72d8696712d.r2.dev';

  /// 拼接 R2 资源完整地址；已是 http(s) 直接返回。
  static String r2Url(String? key) {
    if (key == null || key.isEmpty) return '';
    if (key.startsWith('http://') || key.startsWith('https://')) return key;
    final normalized = key.startsWith('/') ? key.substring(1) : key;
    return '$r2BaseUrl/$normalized';
  }
}
