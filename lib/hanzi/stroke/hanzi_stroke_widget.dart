part of '../hanzi_stroke.dart';

/// 汉字笔画绘制组件。
///
/// 支持：
/// - 整字/单笔动画播放
/// - 测验书写判定
/// - 错误提示与答对淡入
/// - 单笔/全笔颜色覆盖
class HanziStrokeWidget extends StatefulWidget {
  /// 创建笔画组件。
  ///
  /// 主要参数：
  /// - [data] 笔画数据（必填）
  /// - [size] 组件边长
  /// - [showMedians] 是否常驻显示中线
  /// - [controller] 外部控制器（可选）
  const HanziStrokeWidget({
    super.key,

    /// 汉字笔画数据（strokes / medians / radStrokes）。
    required this.data,

    /// 组件边长（正方形）。
    this.size = 320,

    /// 数据坐标基准尺寸，默认使用 HanziWriter 常见的 1024。
    this.baseSize = 1024,

    /// 画布内边距。
    this.padding = 20,

    /// 是否常驻显示所有中线（调试用）。
    this.showMedians = false,

    /// 普通笔画颜色。
    this.strokeColor = Colors.black,

    /// 部首笔画颜色（对 radStrokes 生效）；null 表示不区分。
    this.radicalColor,

    /// 高亮颜色（如 highlightStroke）。
    this.highlightColor = const Color(0xFFAAAAFF),

    /// 用户手写轨迹颜色。
    this.drawingColor = const Color(0xFF333333),

    /// 用户手写轨迹线宽。
    this.drawingWidth = 4.0,

    /// 是否启用动态线宽（压力优先，速度回退）。
    this.enableDynamicWidth = true,

    /// 动态线宽最小值；null 时根据 [drawingWidth] 自动推导。
    this.minDynamicWidth,

    /// 动态线宽最大值；null 时根据 [drawingWidth] 自动推导。
    this.maxDynamicWidth,

    /// 速度平滑系数（0~1，越大越灵敏）。
    this.velocitySmoothing = 0.16,

    /// 中线显示颜色（showMedians=true 时生效）。
    this.medianColor = Colors.red,

    /// 笔迹揭示笔刷宽度（null 使用内部默认）。
    this.revealBrushWidth,

    /// 背景色。
    this.backgroundColor = Colors.white,

    /// 轮廓层颜色（null 使用 strokeColor 的低透明度）。
    this.outlineColor,

    /// 是否显示轮廓层。
    this.showOutline = true,

    /// 是否显示主字形层。
    this.showCharacter = true,

    /// 外部控制器。
    this.controller,
  });

  final HanziStrokeData data;
  final double size;
  final double baseSize;
  final double padding;
  final bool showMedians;
  final Color strokeColor;
  final Color? radicalColor;
  final Color highlightColor;
  final Color drawingColor;
  final double drawingWidth;
  final bool enableDynamicWidth;
  final double? minDynamicWidth;
  final double? maxDynamicWidth;
  final double velocitySmoothing;
  final Color medianColor;
  final double? revealBrushWidth;
  final Color backgroundColor;
  final Color? outlineColor;
  final bool showOutline;
  final bool showCharacter;
  final HanziStrokeController? controller;

  @override
  State<HanziStrokeWidget> createState() => _HanziStrokeWidgetState();
}

/// 单条提示轨道运行态（错误提示/引导提示共用）。
class _QuizHintTrackState {
  int? strokeIndex;
  double sweepProgress = 0;
  double opacity = 0;
  Timer? phaseTimer;
  Timer? loopGapTimer;
}

class _HanziStrokeWidgetState extends State<HanziStrokeWidget>
    with SingleTickerProviderStateMixin
    implements _HanziStrokeControllerBinding {
  late final Ticker _ticker;
  final Stopwatch _frameWatch = Stopwatch();

  bool _isPlaying = false;
  bool _isFinished = false;
  bool _showOutline = true;
  bool _showCharacter = true;
  bool _loopCharacter = false;
  bool _quizActive = false;
  int _currentStrokeIndex = 0;
  int _quizStrokeIndex = 0;
  int _quizTotalMistakes = 0;
  int _quizMistakesOnStroke = 0;
  double _currentStrokeProgress = 0;
  int? _highlightStrokeIndex;
  final List<StrokeSample> _userStrokeSamples = <StrokeSample>[];
  int? _activePointer;
  Duration _strokeDuration = const Duration(milliseconds: 700);
  Duration _delayBetweenStrokes = Duration.zero;
  Duration _delayBetweenLoops = Duration.zero;
  Completer<void>? _animationCompleter;
  Timer? _delayTimer;
  Timer? _highlightClearTimer;
  int? _singleStrokeTarget;
  final _QuizHintTrackState _mistakeHintTrack = _QuizHintTrackState();
  final _QuizHintTrackState _guideHintTrack = _QuizHintTrackState();
  final Map<int, double> _quizCorrectStrokeOpacities = <int, double>{};
  final Map<int, Offset> _quizCorrectStrokeOffsets = <int, Offset>{};
  final Map<int, Timer> _quizCorrectStrokeMotionTimers = <int, Timer>{};
  final Map<int, Color> _strokeColorOverrides = <int, Color>{};
  _QuizConfig _quizConfig = const _QuizConfig();

  /// 当前字总笔画数。
  int get _strokeCount => widget.data.strokeCount;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _showOutline = widget.showOutline;
    _showCharacter = widget.showCharacter;
    _strokeDuration =
        widget.controller?.strokeAnimationDuration ?? _strokeDuration;
    _delayBetweenStrokes =
        widget.controller?.delayBetweenStrokes ?? Duration.zero;
    _delayBetweenLoops = widget.controller?.delayBetweenLoops ?? Duration.zero;
    widget.controller?._attach(this);
    _syncController();
  }

  @override
  void didUpdateWidget(covariant HanziStrokeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
      _strokeDuration =
          widget.controller?.strokeAnimationDuration ?? _strokeDuration;
    }
    if (oldWidget.showOutline != widget.showOutline) {
      _showOutline = widget.showOutline;
    }
    if (oldWidget.showCharacter != widget.showCharacter) {
      _showCharacter = widget.showCharacter;
    }
    if (!identical(oldWidget.data, widget.data)) {
      if (_strokeCount == 0) {
        _currentStrokeIndex = 0;
        _currentStrokeProgress = 0;
        _isFinished = false;
        _isPlaying = false;
        _ticker.stop();
      } else if (_currentStrokeIndex >= _strokeCount) {
        _currentStrokeIndex = _strokeCount - 1;
        _currentStrokeProgress = 1;
        _isFinished = true;
      }
    }
    _syncController();
  }

  void _onTick(Duration _) {
    if (!_frameWatch.isRunning) {
      _frameWatch
        ..reset()
        ..start();
      return;
    }
    final elapsedUs = _frameWatch.elapsedMicroseconds;
    _frameWatch
      ..reset()
      ..start();
    final totalUs = _strokeDuration.inMicroseconds;
    if (totalUs <= 0 || _strokeCount == 0) {
      pause();
      return;
    }

    final deltaProgress = elapsedUs / totalUs;
    if (deltaProgress <= 0) {
      return;
    }

    _currentStrokeProgress += deltaProgress;
    if (_singleStrokeTarget != null &&
        _currentStrokeIndex == _singleStrokeTarget &&
        _currentStrokeProgress >= 1) {
      _currentStrokeProgress = 1;
      if (_singleStrokeTarget == _strokeCount - 1) {
        _isFinished = true;
      }
      _finishRun();
      if (mounted) {
        setState(() {});
      }
      _syncController();
      return;
    }

    while (_currentStrokeProgress >= 1 && !_isFinished) {
      _currentStrokeProgress -= 1;
      _currentStrokeIndex += 1;
      if (_currentStrokeIndex >= _strokeCount) {
        if (_loopCharacter) {
          _restartLoopAfterDelay();
        } else {
          _currentStrokeIndex = _strokeCount - 1;
          _currentStrokeProgress = 1;
          _isFinished = true;
          _finishRun();
        }
        break;
      }
      if (_delayBetweenStrokes > Duration.zero) {
        _currentStrokeProgress = 0;
        _pauseForDelay(_delayBetweenStrokes);
        break;
      }
    }

    if (!mounted) return;
    setState(() {});
    _syncController();
  }

  void _finishRun() {
    _isPlaying = false;
    _ticker.stop();
    _frameWatch.stop();
    _delayTimer?.cancel();
    _delayTimer = null;
    _singleStrokeTarget = null;
    _animationCompleter?.complete();
    _animationCompleter = null;
  }

  Offset _toBaseSpace(Offset localPosition) {
    final drawSize = widget.size;
    final transform = _buildRenderTransform(
      drawSize: drawSize,
      padding: widget.padding,
      paths: widget.data.paths,
      fallbackSize: widget.baseSize,
    );
    final x = (localPosition.dx - transform.translateX) / transform.scale;
    final y = (transform.translateY - localPosition.dy) / transform.scale;
    return Offset(
      x.clamp(transform.bounds.left, transform.bounds.right),
      y.clamp(transform.bounds.top, transform.bounds.bottom),
    );
  }

  StrokeSample _toStrokeSample(PointerEvent event) {
    return StrokeSample(
      position: _toBaseSpace(event.localPosition),
      timeStamp: event.timeStamp,
      kind: event.kind,
      pressure: event.pressure,
      pressureMin: event.pressureMin,
      pressureMax: event.pressureMax,
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!_quizActive) return;
    if (_activePointer != null && _activePointer != event.pointer) return;
    _activePointer = event.pointer;
    _userStrokeSamples
      ..clear()
      ..add(_toStrokeSample(event));
    if (mounted) {
      setState(() {});
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_quizActive ||
        _activePointer != event.pointer ||
        _userStrokeSamples.isEmpty) {
      return;
    }
    _userStrokeSamples.add(_toStrokeSample(event));
    if (mounted) {
      setState(() {});
    }
  }

  void _finishPointerStroke(PointerEvent event) {
    if (_activePointer != event.pointer) return;
    _activePointer = null;
    if (!_quizActive) {
      _userStrokeSamples.clear();
      return;
    }
    _evaluateUserStroke();
    _userStrokeSamples.clear();
    if (mounted) {
      setState(() {});
    }
  }

  void _evaluateUserStroke() {
    if (_quizStrokeIndex >= _strokeCount) return;
    if (_userStrokeSamples.length < 2) return;

    final userPoints = _userStrokeSamples
        .map((sample) => sample.position)
        .toList(growable: false);

    final median = (_quizStrokeIndex < widget.data.medians.length)
        ? widget.data.medians[_quizStrokeIndex]
        : const <Offset>[];
    if (median.length < 2) return;

    final sampleCount = 24;
    final userSamples = _resamplePolyline(userPoints, sampleCount);
    final medianSamples = _resamplePolyline(median, sampleCount);
    if (userSamples.isEmpty || medianSamples.isEmpty) return;

    final averageDistance = _averagePairDistance(userSamples, medianSamples);
    final coverage = _coverageRatio(medianSamples, userSamples);

    // 书写方向校验：用户轨迹方向与标准中线方向夹角接近反向时判为反写。
    final userDir = userSamples.last - userSamples.first;
    final medianDir = medianSamples.last - medianSamples.first;
    final userDirNorm = _normalize(userDir);
    final medianDirNorm = _normalize(medianDir);
    final dot =
        userDirNorm.dx * medianDirNorm.dx + userDirNorm.dy * medianDirNorm.dy;
    final isBackwards = dot < -_quizConfig.backwardsDirectionThreshold;

    final startDistance = (userSamples.first - medianSamples.first).distance;
    final endDistance = (userSamples.last - medianSamples.last).distance;

    final threshold =
        _quizConfig.averageDistanceThreshold * _quizConfig.leniency;
    final coverageThreshold =
        (_quizConfig.coverageThreshold / _quizConfig.leniency).clamp(0.0, 1.0);
    final startThreshold =
        _quizConfig.startPointThreshold * _quizConfig.leniency;
    final endThreshold = _quizConfig.endPointThreshold * _quizConfig.leniency;
    final directionOk = _quizConfig.acceptBackwardsStrokes || !isBackwards;
    final isCorrect =
        averageDistance <= threshold &&
        coverage >= coverageThreshold &&
        startDistance <= startThreshold &&
        endDistance <= endThreshold &&
        directionOk;

    if (isCorrect) {
      _advanceQuizStroke(
        averageDistance: averageDistance,
        coverage: coverage,
        startDistance: startDistance,
        endDistance: endDistance,
        isBackwards: isBackwards,
      );
      return;
    }

    _quizTotalMistakes += 1;
    _quizMistakesOnStroke += 1;
    final strokeData = HanziQuizStrokeData(
      strokeNum: _quizStrokeIndex,
      mistakesOnStroke: _quizMistakesOnStroke,
      totalMistakes: _quizTotalMistakes,
      strokesRemaining: (_strokeCount - _quizStrokeIndex).clamp(
        0,
        _strokeCount,
      ),
      averageDistance: averageDistance,
      coverage: coverage,
      startDistance: startDistance,
      endDistance: endDistance,
      isBackwards: isBackwards,
    );
    _quizConfig.onMistake?.call(strokeData);

    if (_quizConfig.hintMode != HanziQuizHintMode.off &&
        _quizConfig.showHintAfterMisses != null &&
        _quizMistakesOnStroke >= _quizConfig.showHintAfterMisses!) {
      _startMistakeHint(_quizStrokeIndex);
      _quizConfig.onHintMistake?.call(strokeData);
    }

    if (_quizConfig.markStrokeCorrectAfterMisses != null &&
        _quizMistakesOnStroke >= _quizConfig.markStrokeCorrectAfterMisses!) {
      _advanceQuizStroke(
        averageDistance: averageDistance,
        coverage: coverage,
        startDistance: startDistance,
        endDistance: endDistance,
        isBackwards: isBackwards,
      );
    }
  }

  void _advanceQuizStroke({
    required double averageDistance,
    required double coverage,
    required double startDistance,
    required double endDistance,
    required bool isBackwards,
  }) {
    final currentStroke = _quizStrokeIndex.clamp(0, _strokeCount - 1);
    _animateQuizCorrectStrokeReveal(
      currentStroke,
      direction: _resolveQuizRevealDirection(currentStroke),
    );
    _quizConfig.onCorrectStroke?.call(
      HanziQuizStrokeData(
        strokeNum: currentStroke,
        mistakesOnStroke: _quizMistakesOnStroke,
        totalMistakes: _quizTotalMistakes,
        strokesRemaining: (_strokeCount - currentStroke - 1).clamp(
          0,
          _strokeCount,
        ),
        averageDistance: averageDistance,
        coverage: coverage,
        startDistance: startDistance,
        endDistance: endDistance,
        isBackwards: isBackwards,
      ),
    );

    _currentStrokeIndex = currentStroke;
    _currentStrokeProgress = 1.0;
    _quizStrokeIndex += 1;
    _quizMistakesOnStroke = 0;

    if (_quizStrokeIndex >= _strokeCount) {
      _quizActive = false;
      _isFinished = true;
      _stopAllHintTracks();
      _quizConfig.onComplete?.call(
        HanziQuizSummary(
          totalStrokes: _strokeCount,
          totalMistakes: _quizTotalMistakes,
        ),
      );
      if (mounted) {
        setState(() {});
      }
    } else {
      _currentStrokeIndex = _quizStrokeIndex;
      _currentStrokeProgress = 0;
      _syncGuideHintLoop();
    }
    _syncController();
  }

  List<Offset> _resamplePolyline(List<Offset> points, int count) {
    if (points.isEmpty || count <= 1) return points;
    final cumulative = List<double>.filled(points.length, 0);
    for (var i = 1; i < points.length; i++) {
      cumulative[i] = cumulative[i - 1] + (points[i] - points[i - 1]).distance;
    }
    final totalLength = cumulative.last;
    if (totalLength <= 0) {
      return List<Offset>.filled(count, points.first, growable: false);
    }

    final result = <Offset>[];
    for (var i = 0; i < count; i++) {
      final target = totalLength * (i / (count - 1));
      var segment = 1;
      while (segment < cumulative.length && cumulative[segment] < target) {
        segment++;
      }
      if (segment >= cumulative.length) {
        result.add(points.last);
        continue;
      }
      final prevDist = cumulative[segment - 1];
      final segDist = cumulative[segment] - prevDist;
      if (segDist <= 0) {
        result.add(points[segment]);
        continue;
      }
      final t = (target - prevDist) / segDist;
      result.add(Offset.lerp(points[segment - 1], points[segment], t)!);
    }
    return result;
  }

  double _averagePairDistance(List<Offset> left, List<Offset> right) {
    final n = left.length < right.length ? left.length : right.length;
    if (n == 0) return double.infinity;
    var sum = 0.0;
    for (var i = 0; i < n; i++) {
      sum += (left[i] - right[i]).distance;
    }
    return sum / n;
  }

  double _coverageRatio(List<Offset> median, List<Offset> user) {
    if (median.isEmpty || user.length < 2) return 0;
    final threshold =
        (_quizConfig.averageDistanceThreshold * _quizConfig.leniency).clamp(
          10.0,
          double.infinity,
        );
    var covered = 0;
    for (final p in median) {
      if (_distanceToPolyline(p, user) <= threshold) {
        covered += 1;
      }
    }
    return covered / median.length;
  }

  double _distanceToPolyline(Offset point, List<Offset> polyline) {
    var minDistance = double.infinity;
    for (var i = 1; i < polyline.length; i++) {
      final d = _distanceToSegment(point, polyline[i - 1], polyline[i]);
      if (d < minDistance) {
        minDistance = d;
      }
    }
    return minDistance;
  }

  double _distanceToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final ap = p - a;
    final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (len2 <= 0) return (p - a).distance;
    final t = ((ap.dx * ab.dx + ap.dy * ab.dy) / len2).clamp(0.0, 1.0);
    final proj = Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
    return (p - proj).distance;
  }

  Offset _normalize(Offset vector) {
    final length = vector.distance;
    if (length <= 1e-6) return Offset.zero;
    return Offset(vector.dx / length, vector.dy / length);
  }

  void _pauseForDelay(Duration delay) {
    _ticker.stop();
    _frameWatch.stop();
    _delayTimer?.cancel();
    _delayTimer = Timer(delay, () {
      if (!mounted || !_isPlaying || _isFinished) return;
      _frameWatch
        ..reset()
        ..start();
      _ticker.start();
      if (mounted) {
        setState(() {});
      }
      _syncController();
    });
  }

  void _restartLoopAfterDelay() {
    _currentStrokeIndex = 0;
    _currentStrokeProgress = 0;
    _isFinished = false;
    if (_delayBetweenLoops > Duration.zero) {
      _pauseForDelay(_delayBetweenLoops);
    }
  }

  int get _visibleStrokeCount {
    if (_strokeCount == 0) return 0;
    if (_isFinished) return _strokeCount;
    final partial = _currentStrokeProgress > 0 ? 1 : 0;
    return (_currentStrokeIndex + partial).clamp(0, _strokeCount);
  }

  /// 控制器状态同步，供外部 UI（进度文本、按钮状态）监听。
  void _syncController() {
    widget.controller?._updateState(
      isPlaying: _isPlaying,
      visibleStrokeCount: _visibleStrokeCount,
      totalStrokes: _strokeCount,
      currentStrokeProgress: _currentStrokeProgress.clamp(0.0, 1.0),
    );
  }

  /// 错误提示触发入口：每次触发仅播放一轮 FadeIn -> Sweep -> FadeOut。
  void _startMistakeHint(int strokeIndex) {
    _startHintTrack(
      track: _mistakeHintTrack,
      strokeIndex: strokeIndex,
      fadeIn: _quizConfig.mistakeHintFadeInDuration,
      sweep: _quizConfig.mistakeHintSweepDuration,
      fadeOut: _quizConfig.mistakeHintFadeOutDuration,
      loop: false,
      loopGap: Duration.zero,
    );
  }

  /// 引导轨道同步入口：在 startQuiz 与每次写对后调用，保持“当前目标笔持续循环提示”。
  void _syncGuideHintLoop() {
    if (!_quizActive ||
        _quizStrokeIndex >= _strokeCount ||
        _quizConfig.hintMode != HanziQuizHintMode.alwaysGuide) {
      _stopHintTrack(_guideHintTrack);
      return;
    }
    _startHintTrack(
      track: _guideHintTrack,
      strokeIndex: _quizStrokeIndex,
      fadeIn: _quizConfig.guideHintFadeInDuration,
      sweep: _quizConfig.guideHintSweepDuration,
      fadeOut: _quizConfig.guideHintFadeOutDuration,
      loop: true,
      loopGap: _quizConfig.guideHintLoopGapDuration,
    );
  }

  /// 可复用的提示轨道引擎：
  /// 统一驱动 FadeIn -> Sweep -> FadeOut，并按需进入循环播放。
  void _startHintTrack({
    required _QuizHintTrackState track,
    required int strokeIndex,
    required Duration fadeIn,
    required Duration sweep,
    required Duration fadeOut,
    required bool loop,
    required Duration loopGap,
  }) {
    if (_strokeCount == 0) return;
    final safeIndex = strokeIndex.clamp(0, _strokeCount - 1);
    _stopHintTrack(track);
    track.strokeIndex = safeIndex;
    track.sweepProgress = 0;
    track.opacity = 0;

    final fadeInUs = fadeIn.inMicroseconds.clamp(0, 1 << 31);
    final sweepUs = sweep.inMicroseconds.clamp(0, 1 << 31);
    final fadeOutUs = fadeOut.inMicroseconds.clamp(0, 1 << 31);
    final totalUs = fadeInUs + sweepUs + fadeOutUs;

    // 三段时长全为 0 时，直接设为完整态并结束，避免除零与空转定时器。
    if (totalUs <= 0) {
      track.sweepProgress = 1;
      track.opacity = 1;
      if (mounted) setState(() {});
      return;
    }

    final watch = Stopwatch()..start();
    track.phaseTimer = Timer.periodic(const Duration(milliseconds: 16), (
      timer,
    ) {
      final elapsedUs = watch.elapsedMicroseconds;

      if (elapsedUs <= fadeInUs && fadeInUs > 0) {
        track.opacity = (elapsedUs / fadeInUs).clamp(0.0, 1.0);
        track.sweepProgress = 0;
      } else if (elapsedUs <= fadeInUs + sweepUs && sweepUs > 0) {
        final sweepElapsed = elapsedUs - fadeInUs;
        track.opacity = 1;
        track.sweepProgress = (sweepElapsed / sweepUs).clamp(0.0, 1.0);
      } else {
        track.sweepProgress = 1;
        if (fadeOutUs > 0) {
          final fadeOutElapsed = (elapsedUs - fadeInUs - sweepUs).clamp(
            0,
            fadeOutUs,
          );
          track.opacity = (1 - fadeOutElapsed / fadeOutUs).clamp(0.0, 1.0);
        } else {
          track.opacity = 0;
        }
      }

      if (elapsedUs >= totalUs) {
        timer.cancel();
        track.phaseTimer = null;
        track.sweepProgress = 0;
        track.opacity = 0;
        track.strokeIndex = null;

        // 仅引导轨道进入循环，且只在 quiz 仍激活并指向同一目标笔时重播。
        if (loop && _quizActive && _quizStrokeIndex == safeIndex) {
          track.loopGapTimer = Timer(loopGap, () {
            if (!_quizActive || _quizStrokeIndex != safeIndex) return;
            _startHintTrack(
              track: track,
              strokeIndex: safeIndex,
              fadeIn: fadeIn,
              sweep: sweep,
              fadeOut: fadeOut,
              loop: loop,
              loopGap: loopGap,
            );
          });
        }
      }
      if (mounted) {
        setState(() {});
      }
    });
    if (mounted) {
      setState(() {});
    }
  }

  /// 停止单条提示轨道并清空显示态，供切笔/取消/销毁时统一调用。
  void _stopHintTrack(_QuizHintTrackState track) {
    track.phaseTimer?.cancel();
    track.phaseTimer = null;
    track.loopGapTimer?.cancel();
    track.loopGapTimer = null;
    track.strokeIndex = null;
    track.sweepProgress = 0;
    track.opacity = 0;
  }

  /// 停止所有提示轨道（错误提示 + 引导提示）。
  void _stopAllHintTracks() {
    _stopHintTrack(_mistakeHintTrack);
    _stopHintTrack(_guideHintTrack);
    // if (mounted) {
    //   // setState(() {});
    // }
  }

  Offset _resolveQuizRevealDirection(int strokeIndex) {
    if (_userStrokeSamples.length >= 2) {
      final direction =
          _userStrokeSamples.last.position -
          _userStrokeSamples[_userStrokeSamples.length - 2].position;
      if (direction.distance > 1e-6) return _normalize(direction);
    }
    return _resolveMedianDirection(strokeIndex);
  }

  Offset _resolveMedianDirection(int strokeIndex) {
    if (strokeIndex >= 0 && strokeIndex < widget.data.medians.length) {
      final median = widget.data.medians[strokeIndex];
      if (median.length >= 2) {
        final direction = median.last - median[median.length - 2];
        if (direction.distance > 1e-6) return _normalize(direction);
      }
    }
    return const Offset(1, 0);
  }

  void _animateQuizCorrectStrokeReveal(
    int strokeIndex, {
    required Offset direction,
  }) {
    final index = strokeIndex.clamp(0, _strokeCount - 1);
    _quizCorrectStrokeMotionTimers.remove(index)?.cancel();
    final motionDuration = _quizConfig.correctStrokeMotionDuration;
    final fadeDuration = _quizConfig.correctStrokeFadeDuration;
    final duration = _quizConfig.enableCorrectStrokeMotion
        ? (motionDuration > Duration.zero ? motionDuration : fadeDuration)
        : fadeDuration;
    if (duration <= Duration.zero) {
      _quizCorrectStrokeOpacities[index] = 1;
      _quizCorrectStrokeOffsets[index] = Offset.zero;
      if (mounted) setState(() {});
      return;
    }

    final unit = direction.distance <= 1e-6
        ? const Offset(1, 0)
        : _normalize(direction);
    final startOffset = _quizConfig.enableCorrectStrokeMotion
        ? Offset(
            unit.dx * _quizConfig.correctStrokeEnterOffset,
            unit.dy * _quizConfig.correctStrokeEnterOffset,
          )
        : Offset.zero;
    final springWindow = _quizConfig.correctStrokeSpringWindow.clamp(0.0, 1.0);
    final overshoot = _quizConfig.correctStrokeSpringOvershoot.clamp(0.0, 1.0);

    _quizCorrectStrokeOpacities[index] = 0;
    _quizCorrectStrokeOffsets[index] = startOffset;
    final totalUs = duration.inMicroseconds;
    final watch = Stopwatch()..start();
    final timer = Timer.periodic(const Duration(milliseconds: 16), (t) {
      final progress = (watch.elapsedMicroseconds / totalUs).clamp(0.0, 1.0);
      final motionDrivenOpacity = Curves.easeOutCubic.transform(
        progress.clamp(0.0, 1.0),
      );
      final fadeProgress = !_quizConfig.enableCorrectStrokeMotion
          ? (fadeDuration <= Duration.zero
                ? 1.0
                : (watch.elapsedMicroseconds / fadeDuration.inMicroseconds)
                      .clamp(0.0, 1.0))
          : motionDrivenOpacity;
      _quizCorrectStrokeOpacities[index] = fadeProgress;

      Offset nextOffset = Offset.zero;
      if (_quizConfig.enableCorrectStrokeMotion &&
          startOffset.distance > 1e-6) {
        final springAmount = overshoot.clamp(0.0, 1.0);
        final oscillations =
            (ui.lerpDouble(0.9, 2.2, springWindow) ?? 1.4) + springAmount * 0.8;
        final damping =
            (ui.lerpDouble(3.3, 1.1, springAmount) ?? 2.2) *
            (ui.lerpDouble(1.1, 0.85, springWindow) ?? 1.0);
        final omega = 2 * math.pi * oscillations;
        final raw = math.exp(-damping * progress) * math.cos(omega * progress);
        final endRaw = math.exp(-damping) * math.cos(omega);
        final denom = (1 - endRaw).abs() <= 1e-6 ? 1.0 : (1 - endRaw);
        final factor = (raw - endRaw) / denom;
        nextOffset = Offset(startOffset.dx * factor, startOffset.dy * factor);
      }
      _quizCorrectStrokeOffsets[index] = nextOffset;

      if (progress >= 1) {
        t.cancel();
        _quizCorrectStrokeMotionTimers.remove(index);
        _quizCorrectStrokeOpacities[index] = 1;
        _quizCorrectStrokeOffsets[index] = Offset.zero;
      }
      if (mounted) {
        setState(() {});
      }
    });
    _quizCorrectStrokeMotionTimers[index] = timer;
  }

  void _clearQuizCorrectStrokeFades() {
    for (final timer in _quizCorrectStrokeMotionTimers.values) {
      timer.cancel();
    }
    _quizCorrectStrokeMotionTimers.clear();
    _quizCorrectStrokeOpacities.clear();
    _quizCorrectStrokeOffsets.clear();
  }

  @override
  void hintNextStroke(int strokeNum) {
    if (!_quizActive ||
        _quizStrokeIndex >= _strokeCount ||
        _quizConfig.hintMode == HanziQuizHintMode.alwaysGuide) {
      _stopHintTrack(_guideHintTrack);
      return;
    }
    _startHintTrack(
      track: _guideHintTrack,
      strokeIndex: _quizStrokeIndex,
      fadeIn: _quizConfig.guideHintFadeInDuration,
      sweep: _quizConfig.guideHintSweepDuration,
      fadeOut: _quizConfig.guideHintFadeOutDuration,
      loop: false,
      loopGap: _quizConfig.guideHintLoopGapDuration,
    );
  }

  @override
  void play() {
    if (_strokeCount == 0) return;
    if (_isFinished) {
      _currentStrokeIndex = 0;
      _currentStrokeProgress = 0;
      _isFinished = false;
    }
    if (_isPlaying) return;
    _isPlaying = true;
    _frameWatch
      ..reset()
      ..start();
    _ticker.start();
    if (mounted) {
      setState(() {});
    }
    _syncController();
  }

  @override
  void pause() {
    if (!_isPlaying && !_ticker.isActive) {
      return;
    }
    _isPlaying = false;
    _ticker.stop();
    _frameWatch.stop();
    _delayTimer?.cancel();
    _delayTimer = null;
    _singleStrokeTarget = null;
    if (mounted) {
      setState(() {});
    }
    _syncController();
  }

  @override
  void reset() {
    _isPlaying = false;
    _isFinished = false;
    _currentStrokeIndex = 0;
    _currentStrokeProgress = 0;
    _ticker.stop();
    _frameWatch.stop();
    _delayTimer?.cancel();
    _delayTimer = null;
    _stopAllHintTracks();
    _clearQuizCorrectStrokeFades();
    _singleStrokeTarget = null;
    _loopCharacter = false;
    _animationCompleter?.complete();
    _animationCompleter = null;
    if (mounted) {
      setState(() {});
    }
    _syncController();
  }

  @override
  void nextStroke() {
    if (_strokeCount == 0) return;
    pause();
    if (_isFinished) return;

    if (_currentStrokeProgress >= 1) {
      if (_currentStrokeIndex >= _strokeCount - 1) {
        _isFinished = true;
        if (mounted) {
          setState(() {});
        }
        _syncController();
        return;
      }
      _currentStrokeIndex += 1;
      _currentStrokeProgress = 0;
    }

    _isFinished = false;
    _loopCharacter = false;
    _singleStrokeTarget = _currentStrokeIndex;
    _animationCompleter?.complete();
    _animationCompleter = Completer<void>();

    if (mounted) {
      setState(() {});
    }
    _syncController();
    play();
  }

  @override
  void previousStroke() {
    if (_strokeCount == 0) return;
    pause();
    if (_isFinished) {
      _isFinished = false;
      _currentStrokeIndex = _strokeCount - 1;
      _currentStrokeProgress = 0;
    } else if (_currentStrokeProgress > 0) {
      _currentStrokeProgress = 0;
    } else {
      _currentStrokeIndex = (_currentStrokeIndex - 1).clamp(
        0,
        _strokeCount - 1,
      );
      _currentStrokeProgress = 0;
    }
    if (mounted) {
      setState(() {});
    }
    _syncController();
  }

  @override
  void setStrokeAnimationDuration(Duration duration) {
    _strokeDuration = duration;
  }

  @override
  Future<void> animateCharacter() async {
    if (_strokeCount == 0) return;
    _loopCharacter = false;
    reset();
    _animationCompleter?.complete();
    _animationCompleter = Completer<void>();
    final future = _animationCompleter!.future;
    play();
    await future;
  }

  @override
  Future<void> animateStroke(int strokeNum) async {
    if (_strokeCount == 0) return;
    _loopCharacter = false;
    pause();
    final target = strokeNum.clamp(0, _strokeCount - 1);
    _isFinished = false;
    _currentStrokeIndex = target;
    _currentStrokeProgress = 0;
    _singleStrokeTarget = target;
    if (mounted) {
      setState(() {});
    }
    _syncController();
    _animationCompleter?.complete();
    _animationCompleter = Completer<void>();
    final future = _animationCompleter!.future;
    play();
    await future;
  }

  @override
  Future<void> animateCharacterLoop() async {
    if (_strokeCount == 0) return;
    reset();
    _loopCharacter = true;
    play();
  }

  @override
  Future<void> highlightStroke(int strokeNum, Duration duration) async {
    if (_strokeCount == 0) return;
    _highlightClearTimer?.cancel();
    _highlightStrokeIndex = strokeNum.clamp(0, _strokeCount - 1);
    if (mounted) {
      setState(() {});
    }
    final completer = Completer<void>();
    _highlightClearTimer = Timer(duration, () {
      _highlightStrokeIndex = null;
      if (mounted) {
        setState(() {});
      }
      completer.complete();
    });
    await completer.future;
  }

  @override
  void startQuiz(_QuizConfig config) {
    pause();
    _quizConfig = config;
    _quizActive = true;
    _quizStrokeIndex = 0;
    _quizTotalMistakes = 0;
    _quizMistakesOnStroke = 0;
    _userStrokeSamples.clear();
    _activePointer = null;
    _stopAllHintTracks();
    _clearQuizCorrectStrokeFades();
    _currentStrokeIndex = 0;
    _currentStrokeProgress = 0;
    _isFinished = false;
    _syncGuideHintLoop();
    _syncController();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void cancelQuiz() {
    if (!_quizActive) return;
    _quizActive = false;
    _userStrokeSamples.clear();
    _activePointer = null;
    _stopAllHintTracks();
    _clearQuizCorrectStrokeFades();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void skipQuizStroke() {
    if (!_quizActive || _quizStrokeIndex >= _strokeCount) return;
    _advanceQuizStroke(
      averageDistance: 0,
      coverage: 1,
      startDistance: 0,
      endDistance: 0,
      isBackwards: false,
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void setShowCharacter(bool showCharacter) {
    if (_showCharacter == showCharacter) return;
    _showCharacter = showCharacter;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void setShowOutline(bool showOutline) {
    if (_showOutline == showOutline) return;
    _showOutline = showOutline;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void setDelayBetweenStrokes(Duration delay) {
    _delayBetweenStrokes = delay;
  }

  @override
  void setDelayBetweenLoops(Duration delay) {
    _delayBetweenLoops = delay;
  }

  @override
  void setStrokeColorOverride(int strokeNum, Color? color) {
    if (_strokeCount == 0) return;
    final index = strokeNum.clamp(0, _strokeCount - 1);
    if (color == null) {
      _strokeColorOverrides.remove(index);
    } else {
      _strokeColorOverrides[index] = color;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void clearStrokeColorOverrides() {
    if (_strokeColorOverrides.isEmpty) return;
    _strokeColorOverrides.clear();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void setAllStrokeColorOverrides(Color? color) {
    if (_strokeCount == 0) return;
    _strokeColorOverrides.clear();
    if (color != null) {
      for (var i = 0; i < _strokeCount; i++) {
        _strokeColorOverrides[i] = color;
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void setMistakeStrokeColor({
    required List<int> strokeNums,
    required Color color,
    required Color defaultColor,
  }) {
    if (_strokeCount == 0) return;
    _strokeColorOverrides.clear();
    for (var i = 0; i < _strokeCount; i++) {
      if (strokeNums.contains(i)) {
        _strokeColorOverrides[i] = color;
      } else {
        _strokeColorOverrides[i] = defaultColor;
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _delayTimer?.cancel();
    _highlightClearTimer?.cancel();
    _stopAllHintTracks();
    _clearQuizCorrectStrokeFades();
    _ticker.dispose();
    _frameWatch.stop();
    _frameWatch.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _quizActive ? _handlePointerDown : null,
        onPointerMove: _quizActive ? _handlePointerMove : null,
        onPointerUp: _quizActive ? _finishPointerStroke : null,
        onPointerCancel: _quizActive ? _finishPointerStroke : null,
        child: CustomPaint(
          painter: _HanziStrokePainter(
            data: widget.data,
            currentStrokeIndex: _currentStrokeIndex,
            currentStrokeProgress: _currentStrokeProgress.clamp(0.0, 1.0),
            isFinished: _isFinished,
            baseSize: widget.baseSize,
            padding: widget.padding,
            showOutline: _showOutline,
            showCharacter: _showCharacter,
            showMedians: widget.showMedians,
            strokeColor: widget.strokeColor,
            radicalColor: widget.radicalColor,
            highlightColor: widget.highlightColor,
            highlightStrokeIndex: _highlightStrokeIndex,
            mistakeHintStrokeIndex: _mistakeHintTrack.strokeIndex,
            mistakeHintProgress: _mistakeHintTrack.sweepProgress,
            mistakeHintOpacity: _mistakeHintTrack.opacity,
            mistakeHintColor: _quizConfig.mistakeHintColor,
            guideHintStrokeIndex: _guideHintTrack.strokeIndex,
            guideHintProgress: _guideHintTrack.sweepProgress,
            guideHintOpacity: _guideHintTrack.opacity,
            guideHintColor: _quizConfig.guideHintColor,
            quizCorrectStrokeOpacities: Map<int, double>.from(
              _quizCorrectStrokeOpacities,
            ),
            quizCorrectStrokeOffsets: Map<int, Offset>.from(
              _quizCorrectStrokeOffsets,
            ),
            strokeColorOverrides: Map<int, Color>.from(_strokeColorOverrides),
            drawingColor: widget.drawingColor,
            drawingWidth: widget.drawingWidth,
            enableDynamicWidth: widget.enableDynamicWidth,
            minDynamicWidth: widget.minDynamicWidth,
            maxDynamicWidth: widget.maxDynamicWidth,
            velocitySmoothing: widget.velocitySmoothing,
            userStrokeSamples: List<StrokeSample>.from(
              _userStrokeSamples,
              growable: false,
            ),
            medianColor: widget.medianColor,
            revealBrushWidth: widget.revealBrushWidth,
            backgroundColor: widget.backgroundColor,
            outlineColor:
                widget.outlineColor ??
                widget.strokeColor.withValues(alpha: 0.14),
          ),
        ),
      ),
    );
  }
}

class _HanziStrokePainter extends CustomPainter {
  _HanziStrokePainter({
    required this.data,
    required this.currentStrokeIndex,
    required this.currentStrokeProgress,
    required this.isFinished,
    required this.baseSize,
    required this.padding,
    required this.showOutline,
    required this.showCharacter,
    required this.showMedians,
    required this.strokeColor,
    required this.radicalColor,
    required this.highlightColor,
    required this.highlightStrokeIndex,
    required this.mistakeHintStrokeIndex,
    required this.mistakeHintProgress,
    required this.mistakeHintOpacity,
    required this.mistakeHintColor,
    required this.guideHintStrokeIndex,
    required this.guideHintProgress,
    required this.guideHintOpacity,
    required this.guideHintColor,
    required this.quizCorrectStrokeOpacities,
    required this.quizCorrectStrokeOffsets,
    required this.strokeColorOverrides,
    required this.drawingColor,
    required this.drawingWidth,
    required this.enableDynamicWidth,
    required this.minDynamicWidth,
    required this.maxDynamicWidth,
    required this.velocitySmoothing,
    required this.userStrokeSamples,
    required this.medianColor,
    required this.revealBrushWidth,
    required this.backgroundColor,
    required this.outlineColor,
  });

  final HanziStrokeData data;
  final int currentStrokeIndex;
  final double currentStrokeProgress;
  final bool isFinished;
  final double baseSize;
  final double padding;
  final bool showOutline;
  final bool showCharacter;
  final bool showMedians;
  final Color strokeColor;
  final Color? radicalColor;
  final Color highlightColor;
  final int? highlightStrokeIndex;
  final int? mistakeHintStrokeIndex;
  final double mistakeHintProgress;
  final double mistakeHintOpacity;
  final Color mistakeHintColor;
  final int? guideHintStrokeIndex;
  final double guideHintProgress;
  final double guideHintOpacity;
  final Color guideHintColor;
  final Map<int, double> quizCorrectStrokeOpacities;
  final Map<int, Offset> quizCorrectStrokeOffsets;
  final Map<int, Color> strokeColorOverrides;
  final Color drawingColor;
  final double drawingWidth;
  final bool enableDynamicWidth;
  final double? minDynamicWidth;
  final double? maxDynamicWidth;
  final double velocitySmoothing;
  final List<StrokeSample> userStrokeSamples;
  final Color medianColor;
  final double? revealBrushWidth;
  final Color backgroundColor;
  final Color outlineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    if (size.isEmpty || data.strokeCount == 0) {
      return;
    }

    final drawSize = size.shortestSide;
    final transform = _buildRenderTransform(
      drawSize: drawSize,
      padding: padding,
      paths: data.paths,
      fallbackSize: baseSize,
    );
    final scale = transform.scale;

    // 统一渲染坐标系：先平移到居中位置，再翻转 Y 轴以匹配字形坐标。
    canvas.save();
    canvas.translate(transform.translateX, transform.translateY);
    canvas.scale(scale, -scale);

    if (showOutline) {
      final outlinePaint = Paint()
        ..color = outlineColor
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      for (final path in data.paths) {
        canvas.drawPath(path, outlinePaint);
      }
    }

    if (showCharacter) {
      final strokePaint = Paint()
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      final maxStroke = data.strokeCount;
      final finishedCount = isFinished
          ? maxStroke
          : currentStrokeIndex.clamp(0, maxStroke);

      for (var i = 0; i < finishedCount; i++) {
        final opacity = (quizCorrectStrokeOpacities[i] ?? 1).clamp(0.0, 1.0);
        final color = _resolveStrokeColor(i);
        strokePaint.color = color.withValues(alpha: color.a * opacity);
        final offset = quizCorrectStrokeOffsets[i] ?? Offset.zero;
        canvas.save();
        canvas.translate(offset.dx, offset.dy);
        canvas.drawPath(data.paths[i], strokePaint);
        canvas.restore();
      }

      if (!isFinished &&
          currentStrokeIndex >= 0 &&
          currentStrokeIndex < maxStroke) {
        final path = data.paths[currentStrokeIndex];
        final progress = currentStrokeProgress.clamp(0.0, 1.0);
        strokePaint.color = _resolveStrokeColor(currentStrokeIndex);
        if (progress >= 1) {
          canvas.drawPath(path, strokePaint);
        } else if (progress > 0) {
          final median = currentStrokeIndex < data.medians.length
              ? data.medians[currentStrokeIndex]
              : const <Offset>[];
          if (median.length >= 2) {
            _drawStrokeByMedianSweep(
              canvas: canvas,
              strokePath: path,
              median: median,
              progress: progress,
              color: strokePaint.color,
              brushWidth: revealBrushWidth,
            );
          } else {
            final partial = _extractPartialPath(path, progress);
            canvas.drawPath(partial, strokePaint);
          }
        }
      }
    }

    if (showMedians) {
      final medianPaint = Paint()
        ..color = medianColor
        ..style = PaintingStyle.stroke
        ..strokeWidth =
            ui.lerpDouble(2.0, 6.0, (1 / scale).clamp(0.0, 1.0).toDouble()) ??
            2.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true;

      for (final line in data.medians) {
        if (line.length < 2) continue;
        final path = Path()..moveTo(line.first.dx, line.first.dy);
        for (var i = 1; i < line.length; i++) {
          path.lineTo(line[i].dx, line[i].dy);
        }
        canvas.drawPath(path, medianPaint);
      }
    }

    _drawHintOverlay(
      canvas: canvas,
      strokeIndex: mistakeHintStrokeIndex,
      progress: mistakeHintProgress,
      opacity: mistakeHintOpacity,
      color: mistakeHintColor,
    );
    _drawHintOverlay(
      canvas: canvas,
      strokeIndex: guideHintStrokeIndex,
      progress: guideHintProgress,
      opacity: guideHintOpacity,
      color: guideHintColor,
    );

    if (userStrokeSamples.length > 1) {
      final visualWidth =
          ui.lerpDouble(
            drawingWidth,
            drawingWidth * 1.8,
            (1 / scale).clamp(0.0, 1.0).toDouble(),
          ) ??
          drawingWidth;
      final resolver = DynamicStrokeWidthResolver(
        enableDynamicWidth: enableDynamicWidth,
        baseWidth: visualWidth,
        minWidth: minDynamicWidth,
        maxWidth: maxDynamicWidth,
        velocitySmoothing: velocitySmoothing,
      );
      final segments = resolver.buildSegments(userStrokeSamples);
      final userPaint = Paint()
        ..color = drawingColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true;
      for (final segment in segments) {
        userPaint.strokeWidth = segment.width;
        canvas.drawLine(segment.from, segment.to, userPaint);
      }
    }

    canvas.restore();
  }

  Color _resolveStrokeColor(int strokeIndex) {
    final override = strokeColorOverrides[strokeIndex];
    if (override != null) {
      return override;
    }
    if (highlightStrokeIndex != null && strokeIndex == highlightStrokeIndex) {
      return highlightColor;
    }
    if (radicalColor != null && data.radStrokes.contains(strokeIndex)) {
      return radicalColor!;
    }
    return strokeColor;
  }

  /// 统一绘制单条提示轨道（错误提示/引导提示共用）。
  void _drawHintOverlay({
    required Canvas canvas,
    required int? strokeIndex,
    required double progress,
    required double opacity,
    required Color color,
  }) {
    if (strokeIndex == null ||
        strokeIndex < 0 ||
        strokeIndex >= data.strokeCount) {
      return;
    }
    final safeProgress = progress.clamp(0.0, 1.0);
    final safeOpacity = opacity.clamp(0.0, 1.0);
    if (safeProgress <= 0 || safeOpacity <= 0) return;

    final hintPath = data.paths[strokeIndex];
    final hintMedian = strokeIndex < data.medians.length
        ? data.medians[strokeIndex]
        : const <Offset>[];
    final hintColor = color.withValues(alpha: color.a * safeOpacity);
    if (hintMedian.length >= 2) {
      _drawStrokeByMedianSweep(
        canvas: canvas,
        strokePath: hintPath,
        median: hintMedian,
        progress: safeProgress,
        color: hintColor,
        brushWidth: revealBrushWidth,
      );
      return;
    }

    final partial = _extractPartialPath(hintPath, safeProgress);
    final hintPaint = Paint()
      ..color = hintColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(partial, hintPaint);
  }

  Path _extractPartialPath(
    Path source,
    double progress, {
    bool reverse = false,
  }) {
    final partial = Path();
    final metrics = source.computeMetrics(forceClosed: false);
    for (final metric in metrics) {
      final start = reverse ? metric.length * (1 - progress) : 0.0;
      final end = reverse ? metric.length : metric.length * progress;
      partial.addPath(metric.extractPath(start, end), Offset.zero);
    }
    return partial;
  }

  void _drawStrokeByMedianSweep({
    required Canvas canvas,
    required Path strokePath,
    required List<Offset> median,
    required double progress,
    required Color color,
    required double? brushWidth,
  }) {
    final sweepPath = _buildMedianSweepPath(
      median,
      progress,
      brushWidth ?? 200.0,
    );
    if (sweepPath == null) return;

    final sweepPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = brushWidth ?? 200.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    canvas.save();
    canvas.clipPath(strokePath);
    canvas.drawPath(sweepPath, sweepPaint);
    canvas.restore();
  }

  Path? _buildMedianSweepPath(
    List<Offset> median,
    double progress,
    double brushWidth,
  ) {
    if (median.length < 2) return null;
    final clamped = progress.clamp(0.0, 1.0);
    if (clamped <= 0) return null;

    final extended = _extendMedianStart(median, brushWidth / 2);
    if (extended.length < 2) return null;

    var totalLength = 0.0;
    for (var i = 1; i < extended.length; i++) {
      totalLength += (extended[i] - extended[i - 1]).distance;
    }
    if (totalLength <= 0) return null;

    if (clamped >= 1) {
      final full = Path()..moveTo(extended.first.dx, extended.first.dy);
      for (var i = 1; i < extended.length; i++) {
        full.lineTo(extended[i].dx, extended[i].dy);
      }
      return full;
    }

    final targetLength = totalLength * clamped;
    final path = Path()..moveTo(extended.first.dx, extended.first.dy);
    var traversed = 0.0;

    for (var i = 1; i < extended.length; i++) {
      final a = extended[i - 1];
      final b = extended[i];
      final segmentLength = (b - a).distance;
      if (segmentLength <= 0) continue;

      if (traversed + segmentLength <= targetLength) {
        path.lineTo(b.dx, b.dy);
        traversed += segmentLength;
        continue;
      }

      final remain = (targetLength - traversed).clamp(0.0, segmentLength);
      final t = remain / segmentLength;
      final mid = Offset.lerp(a, b, t)!;
      path.lineTo(mid.dx, mid.dy);
      break;
    }

    return path;
  }

  List<Offset> _extendMedianStart(List<Offset> points, double extendDistance) {
    if (points.length < 2 || extendDistance <= 0) return points;
    final first = points.first;
    final second = points[1];
    final direction = second - first;
    final length = direction.distance;
    if (length <= 1e-6) return points;
    final unit = Offset(direction.dx / length, direction.dy / length);
    final extendedStart = Offset(
      first.dx - unit.dx * extendDistance,
      first.dy - unit.dy * extendDistance,
    );
    return <Offset>[extendedStart, ...points];
  }

  @override
  bool shouldRepaint(covariant _HanziStrokePainter oldDelegate) {
    return data != oldDelegate.data ||
        currentStrokeIndex != oldDelegate.currentStrokeIndex ||
        currentStrokeProgress != oldDelegate.currentStrokeProgress ||
        isFinished != oldDelegate.isFinished ||
        baseSize != oldDelegate.baseSize ||
        padding != oldDelegate.padding ||
        showOutline != oldDelegate.showOutline ||
        showCharacter != oldDelegate.showCharacter ||
        showMedians != oldDelegate.showMedians ||
        strokeColor != oldDelegate.strokeColor ||
        radicalColor != oldDelegate.radicalColor ||
        highlightColor != oldDelegate.highlightColor ||
        highlightStrokeIndex != oldDelegate.highlightStrokeIndex ||
        mistakeHintStrokeIndex != oldDelegate.mistakeHintStrokeIndex ||
        mistakeHintProgress != oldDelegate.mistakeHintProgress ||
        mistakeHintOpacity != oldDelegate.mistakeHintOpacity ||
        mistakeHintColor != oldDelegate.mistakeHintColor ||
        guideHintStrokeIndex != oldDelegate.guideHintStrokeIndex ||
        guideHintProgress != oldDelegate.guideHintProgress ||
        guideHintOpacity != oldDelegate.guideHintOpacity ||
        guideHintColor != oldDelegate.guideHintColor ||
        !mapEquals(
          quizCorrectStrokeOpacities,
          oldDelegate.quizCorrectStrokeOpacities,
        ) ||
        !mapEquals(
          quizCorrectStrokeOffsets,
          oldDelegate.quizCorrectStrokeOffsets,
        ) ||
        !mapEquals(strokeColorOverrides, oldDelegate.strokeColorOverrides) ||
        drawingColor != oldDelegate.drawingColor ||
        drawingWidth != oldDelegate.drawingWidth ||
        enableDynamicWidth != oldDelegate.enableDynamicWidth ||
        minDynamicWidth != oldDelegate.minDynamicWidth ||
        maxDynamicWidth != oldDelegate.maxDynamicWidth ||
        velocitySmoothing != oldDelegate.velocitySmoothing ||
        userStrokeSamples != oldDelegate.userStrokeSamples ||
        medianColor != oldDelegate.medianColor ||
        revealBrushWidth != oldDelegate.revealBrushWidth ||
        backgroundColor != oldDelegate.backgroundColor ||
        outlineColor != oldDelegate.outlineColor;
  }
}
