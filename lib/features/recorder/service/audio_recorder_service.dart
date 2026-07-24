import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'recorder_options.dart';

/// 录音服务：封装 `record` 的 [AudioRecorder]，与项目现有
/// `MyencAudioService` 同风格，供 Cubit / 各 widget 复用。
///
/// 只负责“采集到文件”这一步，产物落在临时/配置目录；上层再决定
/// 通过 `RecorderSink` 转存到最终位置（本地或将来云端）。
class AudioRecorderService {
  AudioRecorderService([AudioRecorder? recorder])
      : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

  /// 检查（并按需请求）麦克风权限。
  Future<bool> hasPermission() => _recorder.hasPermission();

  /// 枚举可用输入设备（macOS 支持）。
  Future<List<InputDevice>> listInputDevices() => _recorder.listInputDevices();

  /// 某编码器是否被当前平台支持。
  Future<bool> isEncoderSupported(AudioEncoder encoder) =>
      _recorder.isEncoderSupported(encoder);

  /// 录音状态流（record / pause / stop）。
  Stream<RecordState> onStateChanged() => _recorder.onStateChanged();

  /// 振幅流（dBFS），用于绘制波形。
  Stream<Amplitude> onAmplitudeChanged(Duration interval) =>
      _recorder.onAmplitudeChanged(interval);

  /// 当硬件/编码器调整了请求的配置时回调（例如实际采样率）。
  Future<void> setOnConfigChanged(void Function(RecordConfig config)? cb) =>
      _recorder.setOnConfigChanged(cb);

  Future<bool> isRecording() => _recorder.isRecording();

  Future<bool> isPaused() => _recorder.isPaused();

  /// 根据 [options] 开始录音，返回本次写入的临时文件路径。
  Future<String> start(RecorderOptions options) async {
    final device = await _resolveDevice(options.deviceId);
    final config = RecordConfig(
      encoder: options.codec.encoder,
      sampleRate: options.sampleRate.hz,
      numChannels: options.numChannels,
      bitRate: options.bitRate,
      device: device,
      autoGain: options.autoGain,
      echoCancel: options.echoCancel,
      noiseSuppress: options.noiseSuppress,
    );

    final path = await _buildTempPath(options);
    await _recorder.start(config, path: path);
    return path;
  }

  /// 停止录音，返回最终文件路径（可能为 null）。
  Future<String?> stop() => _recorder.stop();

  Future<void> pause() => _recorder.pause();

  Future<void> resume() => _recorder.resume();

  /// 取消并删除正在录制的临时文件。
  Future<void> cancel() => _recorder.cancel();

  void dispose() => _recorder.dispose();

  /// 将 deviceId 解析为 [InputDevice]；找不到或为 null 时返回 null（系统默认）。
  Future<InputDevice?> _resolveDevice(String? deviceId) async {
    if (deviceId == null || deviceId.isEmpty) return null;
    try {
      final devices = await _recorder.listInputDevices();
      for (final d in devices) {
        if (d.id == deviceId) return d;
      }
    } catch (_) {
      // 枚举失败则回退到系统默认设备。
    }
    return null;
  }

  /// 生成临时文件路径：`<tmp>/<prefix>_<timestamp>.<ext>`。
  Future<String> _buildTempPath(RecorderOptions options) async {
    final dir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final name = '${options.fileNamePrefix}_$ts.${options.codec.fileExtension}';
    return '${dir.path}${Platform.pathSeparator}$name';
  }
}
