import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:record/record.dart';

import '../service/audio_recorder_service.dart';
import '../service/audio_trimmer.dart';
import '../service/pcm_waveform.dart';
import '../service/recorder_options.dart';
import '../service/recorder_player_service.dart';
import '../service/recorder_sink.dart';
import 'recorder_state.dart';

/// 录音逻辑：驱动 [AudioRecorderService]，维护时长/波形/状态，
/// 并通过 [RecorderSink] 转存。UI 只读该 Cubit，不直接碰录音库。
class RecorderCubit extends Cubit<RecorderState> {
  RecorderCubit({
    required AudioRecorderService service,
    RecorderSink? sink,
    RecorderPlayerService? player,
    RecorderOptions initialOptions = const RecorderOptions(),

    /// 波形采样间隔。
    Duration amplitudeInterval = const Duration(milliseconds: 100),

    /// 实时波形历史最大长度（超出丢弃最旧值）。
    ///
    /// 默认约 30 分钟，实际等同于不截断，便于录音中横向回看全程。
    int maxAmplitudeSamples = 18000,
  })  : _service = service,
        _sink = sink,
        _player = player,
        _amplitudeInterval = amplitudeInterval,
        _maxAmplitudeSamples = maxAmplitudeSamples,
        super(RecorderState(options: initialOptions));

  final AudioRecorderService _service;
  final RecorderSink? _sink;
  final RecorderPlayerService? _player;
  final Duration _amplitudeInterval;
  final int _maxAmplitudeSamples;

  /// 振幅归一化下限（dBFS），低于此视为静音。
  static const double _dbFloor = -50.0;

  StreamSubscription<RecordState>? _stateSub;
  StreamSubscription<Amplitude>? _ampSub;
  Timer? _ticker;
  Timer? _playTicker;
  final Stopwatch _stopwatch = Stopwatch();

  /// 初始化：权限、设备列表、监听状态与振幅、配置回调。
  Future<void> init() async {
    try {
      final granted = await _service.hasPermission();
      emit(state.copyWith(hasPermission: granted));

      await _refreshDevices();

      await _service.setOnConfigChanged((config) {
        emit(state.copyWith(effectiveSampleRate: config.sampleRate));
      });

      _stateSub = _service.onStateChanged().listen((rs) {
        if (rs == RecordState.stop && state.status == RecorderStatus.recording) {
          _onStoppedExternally();
        }
      });

      _ampSub =
          _service.onAmplitudeChanged(_amplitudeInterval).listen(_onAmplitude);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _refreshDevices() async {
    try {
      final devices = await _service.listInputDevices();
      emit(state.copyWith(devices: devices));
    } catch (_) {
      // 枚举失败不阻断录音（回退系统默认设备）。
    }
  }

  /// 重新拉取设备列表（例如插拔 USB 后）。
  Future<void> refreshDevices() => _refreshDevices();

  /// 空格键触发：录音中则停止，否则开始。
  Future<void> toggle() async {
    if (state.isRecording) {
      await stop();
    } else {
      await start();
    }
  }

  /// 开始录音（会清空上一段未保存的录音）。
  Future<void> start() async {
    if (state.isRecording) return;
    if (state.hasPermission == false) {
      final granted = await _service.hasPermission();
      emit(state.copyWith(hasPermission: granted));
      if (!granted) {
        emit(state.copyWith(error: '没有麦克风权限'));
        return;
      }
    }
    await _stopPreviewInternal();
    try {
      final tempPath = await _service.start(state.options);
      _stopwatch
        ..reset()
        ..start();
      _startTicker();
      emit(state.copyWith(
        status: RecorderStatus.recording,
        tempPath: tempPath,
        savedPath: null,
        elapsed: Duration.zero,
        amplitudes: const <double>[],
        playback: PlaybackStatus.stopped,
        playbackPosition: Duration.zero,
        playbackDuration: Duration.zero,
        waveform: null,
        analyzing: false,
        trimStart: null,
        trimEnd: null,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: '开始录音失败：$e'));
    }
  }

  /// 停止录音，并解析波形以支持裁切。
  Future<void> stop() async {
    if (!state.isRecording) return;
    try {
      final path = await _service.stop();
      _stopwatch.stop();
      _ticker?.cancel();
      final finalPath = path ?? state.tempPath;
      emit(state.copyWith(
        status: RecorderStatus.stopped,
        tempPath: finalPath,
        elapsed: _stopwatch.elapsed,
      ));
      if (finalPath != null) {
        await _analyzeWaveform(finalPath);
      }
    } catch (e) {
      emit(state.copyWith(error: '停止录音失败：$e'));
    }
  }

  /// 从录音文件解码完整包络，作为裁切与播放头的依据。
  ///
  /// 实时振幅流只有 10 点/秒且会丢弃旧值，精度不足以定位裁切点。
  Future<void> _analyzeWaveform(String path) async {
    if (!state.options.codec.supportsTrim) {
      // 压缩格式不解析，仅保留试听能力。
      emit(state.copyWith(waveform: null, analyzing: false));
      return;
    }
    emit(state.copyWith(analyzing: true, error: null));
    try {
      final waveform = await PcmWaveform.build(
        path,
        fallbackSampleRate: state.effectiveSampleRate ?? state.options.sampleRate.hz,
        fallbackChannels: state.options.numChannels,
      );
      if (isClosed) return;
      emit(state.copyWith(
        waveform: waveform,
        analyzing: false,
        trimStart: Duration.zero,
        trimEnd: waveform.duration,
        playbackDuration: waveform.duration,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(analyzing: false, error: '波形解析失败：$e'));
    }
  }

  /// 设置裁切起点（自动钳制，保证不越过终点且区间不过短）。
  void setTrimStart(Duration value) {
    if (!state.canTrim) return;
    final maxStart = state.effectiveTrimEnd - AudioTrimmer.minDuration;
    final clamped = _clampDuration(value, Duration.zero, maxStart);
    emit(state.copyWith(trimStart: clamped));
    if (state.playbackPosition < clamped) {
      seekPreview(clamped);
    }
  }

  /// 设置裁切终点。
  void setTrimEnd(Duration value) {
    if (!state.canTrim) return;
    final minEnd = state.effectiveTrimStart + AudioTrimmer.minDuration;
    final clamped = _clampDuration(value, minEnd, state.audioDuration);
    emit(state.copyWith(trimEnd: clamped));
    if (state.playbackPosition > clamped) {
      seekPreview(clamped);
    }
  }

  /// 还原为全长（取消裁切）。
  void resetTrim() {
    if (!state.canTrim) return;
    emit(state.copyWith(
      trimStart: Duration.zero,
      trimEnd: state.audioDuration,
    ));
  }

  /// 设置波形横向缩放（每秒像素数）。
  void setZoom(double pxPerSecond) {
    emit(state.copyWith(pxPerSecond: pxPerSecond.clamp(_minZoom, _maxZoom)));
  }

  static const double _minZoom = 20;
  static const double _maxZoom = 2000;

  static Duration _clampDuration(Duration v, Duration min, Duration max) {
    if (max < min) return min;
    if (v < min) return min;
    if (v > max) return max;
    return v;
  }

  /// 重置：取消/丢弃当前录音，回到空闲。
  Future<void> reset() async {
    try {
      if (state.isRecording) {
        await _service.cancel();
      }
    } catch (_) {
      // 忽略取消异常。
    }
    await _stopPreviewInternal();
    _stopwatch
      ..stop()
      ..reset();
    _ticker?.cancel();
    emit(state.copyWith(
      status: RecorderStatus.idle,
      elapsed: Duration.zero,
      amplitudes: const <double>[],
      tempPath: null,
      savedPath: null,
      playback: PlaybackStatus.stopped,
      playbackPosition: Duration.zero,
      playbackDuration: Duration.zero,
      waveform: null,
      analyzing: false,
      trimStart: null,
      trimEnd: null,
      error: null,
    ));
  }

  /// 保存当前录音到最终位置，返回保存路径。
  Future<String?> save({String? preferredName}) async {
    final tempPath = state.tempPath;
    if (state.status != RecorderStatus.stopped || tempPath == null) {
      return null;
    }
    emit(state.copyWith(busy: true, error: null));
    String? trimmedPath;
    try {
      await _stopPreviewInternal();

      // 有裁切时先写出裁切片段，只有它会被转存。
      final waveform = state.waveform;
      final sourcePath = (state.hasTrim && waveform != null)
          ? trimmedPath = await AudioTrimmer.trim(
              sourcePath: tempPath,
              waveform: waveform,
              start: state.effectiveTrimStart,
              end: state.effectiveTrimEnd,
            )
          : tempPath;

      // 用户在 UI 里显式选了目录时，优先落到该本地目录；否则用注入的
      // sink（默认落到资源库目录），最后兜底本地默认目录。
      final outputDir = state.options.outputDir;
      final sink = (outputDir != null && outputDir.isNotEmpty)
          ? LocalFileSink(directory: outputDir)
          : (_sink ?? LocalFileSink(directory: outputDir));
      final saved =
          await sink.save(File(sourcePath), preferredName: preferredName);
      emit(state.copyWith(
        status: RecorderStatus.saved,
        savedPath: saved,
        busy: false,
      ));
      return saved;
    } catch (e) {
      emit(state.copyWith(busy: false, error: '保存失败：$e'));
      return null;
    } finally {
      await _deleteQuietly(trimmedPath);
    }
  }

  Future<void> _deleteQuietly(String? path) async {
    if (path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // 临时文件清理失败不影响保存结果。
    }
  }

  /// 更新配置（录音中不允许改，避免中途变更）。
  void updateOptions(RecorderOptions options) {
    if (state.isRecording) return;
    emit(state.copyWith(options: options));
  }

  /// 播放预览：暂停中则恢复，否则从头播放。
  Future<void> playPreview() async {
    final player = _player;
    final path = state.tempPath;
    if (player == null || path == null || !state.hasPreview) return;

    if (state.isPaused) {
      player.resume();
      _startPlayTicker();
      emit(state.copyWith(playback: PlaybackStatus.playing));
      return;
    }
    if (state.isPlaying) return;

    try {
      final duration = await player.load(path);
      // 从裁切起点起播，让试听结果与最终保存内容一致。
      final from = state.canTrim ? state.effectiveTrimStart : Duration.zero;
      await player.playFrom(from);
      _startPlayTicker();
      emit(state.copyWith(
        playback: PlaybackStatus.playing,
        playbackDuration: duration,
        playbackPosition: from,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: '播放失败：$e'));
    }
  }

  /// 将播放头移动到指定位置（未在播放时只更新标记位置）。
  void seekPreview(Duration position) {
    final clamped = _clampDuration(
      position,
      Duration.zero,
      state.audioDuration,
    );
    if (state.isPlaying || state.isPaused) {
      _player?.seek(clamped);
    }
    emit(state.copyWith(playbackPosition: clamped));
  }

  /// 暂停预览。
  void pausePreview() {
    if (!state.isPlaying) return;
    _player?.pause();
    _playTicker?.cancel();
    emit(state.copyWith(playback: PlaybackStatus.paused));
  }

  /// 停止预览（回到起点）。
  Future<void> stopPreview() async {
    await _stopPreviewInternal();
    emit(state.copyWith(
      playback: PlaybackStatus.stopped,
      playbackPosition: state.canTrim ? state.effectiveTrimStart : Duration.zero,
    ));
  }

  Future<void> _stopPreviewInternal() async {
    _playTicker?.cancel();
    try {
      await _player?.stop();
    } catch (_) {
      // 忽略停止异常。
    }
  }

  void _startPlayTicker() {
    _playTicker?.cancel();
    // 30ms 刷新让播放头移动足够顺滑。
    _playTicker = Timer.periodic(const Duration(milliseconds: 30), (_) {
      final player = _player;
      if (player == null) return;
      final resetTo =
          state.canTrim ? state.effectiveTrimStart : Duration.zero;
      // 自然播放结束：句柄失效。
      if (!player.isActive) {
        _playTicker?.cancel();
        emit(state.copyWith(
          playback: PlaybackStatus.stopped,
          playbackPosition: resetTo,
        ));
        return;
      }
      if (!state.isPlaying) return;

      final position = player.position();
      // 到达裁切终点即停，避免试听到会被裁掉的尾部。
      if (state.canTrim && position >= state.effectiveTrimEnd) {
        _playTicker?.cancel();
        unawaited(_stopPreviewInternal());
        emit(state.copyWith(
          playback: PlaybackStatus.stopped,
          playbackPosition: resetTo,
        ));
        return;
      }
      emit(state.copyWith(playbackPosition: position));
    });
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (state.status == RecorderStatus.recording) {
        emit(state.copyWith(elapsed: _stopwatch.elapsed));
      }
    });
  }

  void _onAmplitude(Amplitude amp) {
    if (state.status != RecorderStatus.recording) return;
    final normalized = _normalize(amp.current);
    final next = List<double>.of(state.amplitudes)..add(normalized);
    if (next.length > _maxAmplitudeSamples) {
      next.removeRange(0, next.length - _maxAmplitudeSamples);
    }
    emit(state.copyWith(amplitudes: next));
  }

  /// dBFS -> 0..1。
  double _normalize(double dbfs) {
    if (dbfs.isNaN || dbfs.isInfinite) return 0;
    if (dbfs >= 0) return 1;
    if (dbfs <= _dbFloor) return 0;
    return (dbfs - _dbFloor) / (0 - _dbFloor);
  }

  void _onStoppedExternally() {
    _stopwatch.stop();
    _ticker?.cancel();
    emit(state.copyWith(
      status: RecorderStatus.stopped,
      elapsed: _stopwatch.elapsed,
    ));
  }

  @override
  Future<void> close() async {
    await _stateSub?.cancel();
    await _ampSub?.cancel();
    _ticker?.cancel();
    _playTicker?.cancel();
    await _player?.release();
    await _service.setOnConfigChanged(null);
    return super.close();
  }
}
