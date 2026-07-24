import 'package:flutter_soloud/flutter_soloud.dart';

/// 录音预览播放服务：用 `flutter_soloud` 播放本地录音文件。
///
/// 与 `MyencAudioService` 共用同一个 SoLoud 引擎实例（单例），
/// 只负责“预览刚录好的文件”，支持播放/暂停/恢复/停止与进度查询。
class RecorderPlayerService {
  AudioSource? _source;
  SoundHandle? _handle;
  String? _loadedPath;

  Future<void> _ensureInitialized() async {
    if (!SoLoud.instance.isInitialized) {
      await SoLoud.instance.init();
    }
  }

  /// 加载文件，返回总时长。重复路径会复用已加载资源。
  Future<Duration> load(String path) async {
    await _ensureInitialized();
    if (_loadedPath != path) {
      await _disposeSource();
      _source = await SoLoud.instance.loadFile(path);
      _loadedPath = path;
    }
    final source = _source;
    if (source == null) return Duration.zero;
    return SoLoud.instance.getLength(source);
  }

  /// 从头播放已加载的文件，返回句柄。
  Future<SoundHandle?> play() async {
    final source = _source;
    if (source == null) return null;
    await _stopHandle();
    _handle = SoLoud.instance.play(source);
    return _handle;
  }

  void pause() {
    final handle = _handle;
    if (handle != null) SoLoud.instance.setPause(handle, true);
  }

  void resume() {
    final handle = _handle;
    if (handle != null) SoLoud.instance.setPause(handle, false);
  }

  Future<void> stop() => _stopHandle();

  /// 当前播放位置。
  Duration position() {
    final handle = _handle;
    if (handle == null) return Duration.zero;
    if (!SoLoud.instance.getIsValidVoiceHandle(handle)) return Duration.zero;
    return SoLoud.instance.getPosition(handle);
  }

  /// 是否处于暂停态。
  bool get isPaused {
    final handle = _handle;
    if (handle == null) return false;
    if (!SoLoud.instance.getIsValidVoiceHandle(handle)) return false;
    return SoLoud.instance.getPause(handle);
  }

  /// 句柄是否仍有效（播放中或暂停中为 true，自然结束/停止后为 false）。
  bool get isActive {
    final handle = _handle;
    if (handle == null) return false;
    return SoLoud.instance.getIsValidVoiceHandle(handle);
  }

  Future<void> _stopHandle() async {
    final handle = _handle;
    if (handle != null) {
      try {
        await SoLoud.instance.stop(handle);
      } catch (_) {
        // 忽略无效句柄。
      }
      _handle = null;
    }
  }

  Future<void> _disposeSource() async {
    await _stopHandle();
    final source = _source;
    if (source != null) {
      try {
        await SoLoud.instance.disposeSource(source);
      } catch (_) {
        // 忽略重复释放。
      }
      _source = null;
      _loadedPath = null;
    }
  }

  /// 释放当前资源（切换录音或关闭时调用）。
  Future<void> release() => _disposeSource();

  void dispose() {
    _disposeSource();
  }
}
