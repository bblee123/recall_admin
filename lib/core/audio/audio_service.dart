import 'package:flutter_soloud/flutter_soloud.dart';

class R2AudioPlayer {
  R2AudioPlayer._();

  static final R2AudioPlayer instance = R2AudioPlayer._();

  final SoLoud _soloud = SoLoud.instance;

  AudioSource? _source;
  SoundHandle? _handle;

  Future<void> init() async {
    if (!_soloud.isInitialized) {
      await _soloud.init();
    }
  }

  /// 播放 Cloudflare R2 音频
  Future<void> play(String url) async {
    await init();

    // 停止之前的声音
    await stop();

    try {
      final source = await _soloud.loadUrl(url);

      _source = source;

      _soloud.play(source);
    } catch (e) {
      _source = null;
      _handle = null;

      rethrow;
    }
  }

  /// 暂停
  void pause() {
    final handle = _handle;

    if (handle == null) return;

    _soloud.pauseSwitch(handle);
  }

  /// 继续 / 暂停切换
  void resume() {
    final handle = _handle;

    if (handle == null) return;

    _soloud.pauseSwitch(handle);
  }

  /// 停止
  Future<void> stop() async {
    final handle = _handle;

    if (handle != null) {
      await _soloud.stop(handle);
    }

    _handle = null;

    final source = _source;

    if (source != null) {
      await _soloud.disposeSource(source);
    }

    _source = null;
  }

  /// 释放
  Future<void> dispose() async {
    await stop();

    if (_soloud.isInitialized) {
      _soloud.deinit();
    }
  }
}
