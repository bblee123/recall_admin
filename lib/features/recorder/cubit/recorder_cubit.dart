import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:record/record.dart';

import '../service/audio_recorder_service.dart';
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

    /// 波形历史最大长度（超出丢弃最旧值）。
    int maxAmplitudeSamples = 240,
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
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: '开始录音失败：$e'));
    }
  }

  /// 停止录音。
  Future<void> stop() async {
    if (!state.isRecording) return;
    try {
      final path = await _service.stop();
      _stopwatch.stop();
      _ticker?.cancel();
      emit(state.copyWith(
        status: RecorderStatus.stopped,
        tempPath: path ?? state.tempPath,
        elapsed: _stopwatch.elapsed,
      ));
    } catch (e) {
      emit(state.copyWith(error: '停止录音失败：$e'));
    }
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
    try {
      // 用户在 UI 里显式选了目录时，优先落到该本地目录；否则用注入的
      // sink（默认落到资源库目录），最后兜底本地默认目录。
      final outputDir = state.options.outputDir;
      final sink = (outputDir != null && outputDir.isNotEmpty)
          ? LocalFileSink(directory: outputDir)
          : (_sink ?? LocalFileSink(directory: outputDir));
      final saved = await sink.save(File(tempPath), preferredName: preferredName);
      emit(state.copyWith(
        status: RecorderStatus.saved,
        savedPath: saved,
        busy: false,
      ));
      return saved;
    } catch (e) {
      emit(state.copyWith(busy: false, error: '保存失败：$e'));
      return null;
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
      await player.play();
      _startPlayTicker();
      emit(state.copyWith(
        playback: PlaybackStatus.playing,
        playbackDuration: duration,
        playbackPosition: Duration.zero,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: '播放失败：$e'));
    }
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
      playbackPosition: Duration.zero,
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
    _playTicker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final player = _player;
      if (player == null) return;
      // 自然播放结束：句柄失效。
      if (!player.isActive) {
        _playTicker?.cancel();
        emit(state.copyWith(
          playback: PlaybackStatus.stopped,
          playbackPosition: Duration.zero,
        ));
        return;
      }
      if (state.isPlaying) {
        emit(state.copyWith(playbackPosition: player.position()));
      }
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
