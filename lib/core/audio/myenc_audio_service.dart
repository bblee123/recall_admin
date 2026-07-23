import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// `.myenc` 加密音频服务（对照 Vue 项目 useMyencSound）。
///
/// 文件格式：首字节为 encryptedKey，realKey = encryptedKey ^ 0x97，
/// 其余字节逐个 XOR realKey 后即为原始 mp3。解密后用 flutter_soloud 内存播放。
class MyencAudioService {
  MyencAudioService(this._dio);

  final Dio _dio;

  /// 与前后端一致的混淆因子（非真实密钥）。
  static const int _mask = 0x97;

  bool _initialized = false;
  AudioSource? _current;

  /// 初始化 SoLoud 引擎（在 app 启动时调用一次）。
  Future<void> ensureInitialized() async {
    if (_initialized) return;
    if (!SoLoud.instance.isInitialized) {
      await SoLoud.instance.init();
    }
    _initialized = true;
  }

  /// 解密 .myenc 字节。
  static Uint8List decrypt(Uint8List bytes) {
    if (bytes.length < 2) {
      throw const FormatException('.myenc 文件过短');
    }
    final realKey = bytes[0] ^ _mask;
    final out = Uint8List(bytes.length - 1);
    for (var i = 1; i < bytes.length; i++) {
      out[i - 1] = bytes[i] ^ realKey;
    }
    return out;
  }

  /// 下载并播放加密音频 URL。
  Future<void> playEncryptedUrl(String url) async {
    await ensureInitialized();
    final res = await _dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    final data = Uint8List.fromList(res.data ?? const <int>[]);
    final decrypted = decrypt(data);

    await _disposeCurrent();
    // mode 需为可被识别的扩展名，解密后是 mp3。
    final source = await SoLoud.instance.loadMem(
      'myenc_${DateTime.now().microsecondsSinceEpoch}.mp3',
      decrypted,
    );
    _current = source;
    // play 返回 SoundHandle（同步扩展类型），无需 await。
    SoLoud.instance.play(source);
  }

  /// 停止当前播放并释放资源。
  Future<void> stop() async {
    await _disposeCurrent();
  }

  Future<void> _disposeCurrent() async {
    final current = _current;
    if (current != null) {
      try {
        await SoLoud.instance.disposeSource(current);
      } catch (_) {
        // 忽略重复释放
      }
      _current = null;
    }
  }

  void dispose() {
    _disposeCurrent();
  }
}
