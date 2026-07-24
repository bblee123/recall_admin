import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:record/record.dart';

import '../service/recorder_options.dart';

part 'recorder_state.freezed.dart';

/// 录音会话阶段。
enum RecorderStatus {
  /// 空闲（未开始或已重置）。
  idle,

  /// 录制中。
  recording,

  /// 已停止，存在可保存的录音。
  stopped,

  /// 保存完成。
  saved,
}

/// 预览播放阶段。
enum PlaybackStatus {
  /// 停止（未播放）。
  stopped,

  /// 播放中。
  playing,

  /// 暂停。
  paused,
}

/// 录音模块状态（freezed，与 `books_state` 同模式）。
@freezed
abstract class RecorderState with _$RecorderState {
  const factory RecorderState({
    @Default(RecorderStatus.idle) RecorderStatus status,
    @Default(RecorderOptions()) RecorderOptions options,
    @Default(<InputDevice>[]) List<InputDevice> devices,

    /// 已录制时长。
    @Default(Duration.zero) Duration elapsed,

    /// 波形振幅历史（0..1，归一化后的当前电平序列）。
    @Default(<double>[]) List<double> amplitudes,

    /// 硬件实际生效的采样率（由 setOnConfigChanged 回报）。
    int? effectiveSampleRate,

    /// 正在录制的临时文件路径。
    String? tempPath,

    /// 保存后的最终路径 / URL。
    String? savedPath,

    /// 是否有麦克风权限（null 表示尚未检查）。
    bool? hasPermission,

    /// 是否正忙（保存中等）。
    @Default(false) bool busy,

    /// 预览播放阶段。
    @Default(PlaybackStatus.stopped) PlaybackStatus playback,

    /// 预览播放当前位置。
    @Default(Duration.zero) Duration playbackPosition,

    /// 预览录音总时长。
    @Default(Duration.zero) Duration playbackDuration,
    String? error,
  }) = _RecorderState;

  const RecorderState._();

  /// 是否正在录音。
  bool get isRecording => status == RecorderStatus.recording;

  /// 保存按钮是否可用：存在已停止的录音且不在忙碌中。
  bool get canSave =>
      (status == RecorderStatus.stopped) && tempPath != null && !busy;

  /// 重置按钮是否可用：非空闲即可清空。
  bool get canReset => status != RecorderStatus.idle;

  /// 是否存在可预览的录音（已停止/已保存且有文件）。
  bool get hasPreview =>
      (status == RecorderStatus.stopped || status == RecorderStatus.saved) &&
      tempPath != null;

  bool get isPlaying => playback == PlaybackStatus.playing;

  bool get isPaused => playback == PlaybackStatus.paused;
}
