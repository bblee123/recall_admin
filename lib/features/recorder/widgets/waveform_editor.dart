import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../service/pcm_waveform.dart';

/// 被拖拽的对象。
enum _DragTarget { none, start, end, playhead }

/// 可滚动、可缩放的波形编辑器：拖拽首尾把手裁切，播放头合并显示进度。
///
/// 裁切区外用半透明遮罩标示"会被裁掉"的部分。
class WaveformEditor extends StatefulWidget {
  const WaveformEditor({
    super.key,
    required this.waveform,
    required this.duration,
    required this.trimStart,
    required this.trimEnd,
    required this.playhead,
    required this.pxPerSecond,
    required this.onTrimStartChanged,
    required this.onTrimEndChanged,
    required this.onSeek,
    required this.onZoomInitialized,
    this.enableTrim = true,
    this.followPlayhead = false,
    this.height = 132,
  });

  final WaveformData waveform;
  final Duration duration;
  final Duration trimStart;
  final Duration trimEnd;
  final Duration playhead;

  /// 每秒占多少像素；<= 0 表示尚未初始化，由本组件按视口自适应。
  final double pxPerSecond;

  final ValueChanged<Duration> onTrimStartChanged;
  final ValueChanged<Duration> onTrimEndChanged;
  final ValueChanged<Duration> onSeek;

  /// 首次布局算出自适应缩放后回调，交给上层存入状态。
  final ValueChanged<double> onZoomInitialized;

  /// 格式不支持裁切时隐藏把手与遮罩。
  final bool enableTrim;

  /// 播放时自动横向滚动跟随播放头。
  final bool followPlayhead;

  final double height;

  @override
  State<WaveformEditor> createState() => _WaveformEditorState();
}

class _WaveformEditorState extends State<WaveformEditor> {
  final ScrollController _scroll = ScrollController();

  /// 把手命中区左右各加宽，避免难以拖中。
  static const double _handleHitSlop = 12;
  static const double _rulerHeight = 18;

  _DragTarget _dragging = _DragTarget.none;

  @override
  void didUpdateWidget(covariant WaveformEditor old) {
    super.didUpdateWidget(old);
    if (widget.followPlayhead && widget.playhead != old.playhead) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealPlayhead());
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  double get _totalSeconds {
    final us = widget.duration.inMicroseconds;
    return us <= 0 ? 0 : us / Duration.microsecondsPerSecond;
  }

  double _contentWidth(double viewportWidth) {
    if (_totalSeconds <= 0) return viewportWidth;
    return math.max(viewportWidth, _totalSeconds * widget.pxPerSecond);
  }

  Duration _timeAt(double dx, double contentWidth) {
    if (contentWidth <= 0) return Duration.zero;
    final ratio = (dx / contentWidth).clamp(0.0, 1.0);
    return Duration(
      microseconds: (widget.duration.inMicroseconds * ratio).round(),
    );
  }

  double _xOf(Duration t, double contentWidth) {
    final total = widget.duration.inMicroseconds;
    if (total <= 0) return 0;
    return (t.inMicroseconds / total).clamp(0.0, 1.0) * contentWidth;
  }

  /// 把播放头滚动进可视区域（留出边距，避免贴边）。
  void _revealPlayhead() {
    if (!_scroll.hasClients) return;
    final viewport = _scroll.position.viewportDimension;
    final contentWidth = _contentWidth(viewport);
    if (contentWidth <= viewport) return;

    final x = _xOf(widget.playhead, contentWidth);
    final margin = viewport * 0.25;
    final offset = _scroll.offset;
    if (x < offset + margin || x > offset + viewport - margin) {
      _scroll.jumpTo(
        (x - viewport / 2).clamp(0.0, _scroll.position.maxScrollExtent),
      );
    }
  }

  _DragTarget _hitTest(double dx, double contentWidth) {
    if (!widget.enableTrim) return _DragTarget.playhead;
    final startX = _xOf(widget.trimStart, contentWidth);
    final endX = _xOf(widget.trimEnd, contentWidth);
    final toStart = (dx - startX).abs();
    final toEnd = (dx - endX).abs();
    if (toStart <= _handleHitSlop && toStart <= toEnd) return _DragTarget.start;
    if (toEnd <= _handleHitSlop) return _DragTarget.end;
    return _DragTarget.playhead;
  }

  void _applyDrag(double dx, double contentWidth) {
    final time = _timeAt(dx, contentWidth);
    switch (_dragging) {
      case _DragTarget.start:
        widget.onTrimStartChanged(time);
      case _DragTarget.end:
        widget.onTrimEndChanged(time);
      case _DragTarget.playhead:
        widget.onSeek(time);
      case _DragTarget.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewport = constraints.maxWidth;

          // 首次布局：按视口自适应，短录音正好铺满，长录音进入滚动。
          if (widget.pxPerSecond <= 0 && _totalSeconds > 0) {
            final fit = (viewport / _totalSeconds).clamp(20.0, 2000.0);
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => widget.onZoomInitialized(fit),
            );
          }

          final contentWidth = _contentWidth(viewport);

          return Scrollbar(
            controller: _scroll,
            thumbVisibility: contentWidth > viewport,
            child: SingleChildScrollView(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              physics: _dragging == _DragTarget.none
                  ? const ClampingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) {
                  final target = _hitTest(d.localPosition.dx, contentWidth);
                  if (target == _DragTarget.playhead) {
                    widget.onSeek(_timeAt(d.localPosition.dx, contentWidth));
                  }
                },
                onHorizontalDragStart: (d) {
                  setState(() {
                    _dragging = _hitTest(d.localPosition.dx, contentWidth);
                  });
                  _applyDrag(d.localPosition.dx, contentWidth);
                },
                onHorizontalDragUpdate: (d) =>
                    _applyDrag(d.localPosition.dx, contentWidth),
                onHorizontalDragEnd: (_) =>
                    setState(() => _dragging = _DragTarget.none),
                onHorizontalDragCancel: () =>
                    setState(() => _dragging = _DragTarget.none),
                child: CustomPaint(
                  size: Size(contentWidth, widget.height),
                  painter: _WaveformPainter(
                    peaks: widget.waveform.peaks,
                    duration: widget.duration,
                    trimStart: widget.trimStart,
                    trimEnd: widget.trimEnd,
                    playhead: widget.playhead,
                    enableTrim: widget.enableTrim,
                    activeHandle: _dragging,
                    rulerHeight: _rulerHeight,
                    waveColor: scheme.primary,
                    maskColor: scheme.surface.withValues(alpha: 0.62),
                    handleColor: scheme.primary,
                    activeHandleColor: scheme.tertiary,
                    playheadColor: scheme.error,
                    rulerColor: scheme.outline,
                    baselineColor: scheme.outlineVariant,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.peaks,
    required this.duration,
    required this.trimStart,
    required this.trimEnd,
    required this.playhead,
    required this.enableTrim,
    required this.activeHandle,
    required this.rulerHeight,
    required this.waveColor,
    required this.maskColor,
    required this.handleColor,
    required this.activeHandleColor,
    required this.playheadColor,
    required this.rulerColor,
    required this.baselineColor,
  });

  final List<double> peaks;
  final Duration duration;
  final Duration trimStart;
  final Duration trimEnd;
  final Duration playhead;
  final bool enableTrim;
  final _DragTarget activeHandle;
  final double rulerHeight;
  final Color waveColor;
  final Color maskColor;
  final Color handleColor;
  final Color activeHandleColor;
  final Color playheadColor;
  final Color rulerColor;
  final Color baselineColor;

  double _x(Duration t, double width) {
    final total = duration.inMicroseconds;
    if (total <= 0) return 0;
    return (t.inMicroseconds / total).clamp(0.0, 1.0) * width;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final waveTop = rulerHeight;
    final waveHeight = size.height - rulerHeight;
    final midY = waveTop + waveHeight / 2;

    _paintRuler(canvas, size);
    _paintWave(canvas, size, midY, waveHeight);

    if (enableTrim) {
      _paintMask(canvas, size, waveTop, waveHeight);
      _paintHandles(canvas, size, waveTop, waveHeight);
    }
    _paintPlayhead(canvas, size, waveTop, waveHeight);
  }

  /// 时间刻度：按缩放挑选一个"整数感"的间隔，避免标签过密。
  void _paintRuler(Canvas canvas, Size size) {
    final totalSeconds = duration.inMicroseconds / Duration.microsecondsPerSecond;
    if (totalSeconds <= 0) return;

    final pxPerSecond = size.width / totalSeconds;
    const candidates = <double>[
      0.01, 0.02, 0.05, 0.1, 0.25, 0.5, 1, 2, 5, 10, 30, 60,
    ];
    // 让相邻刻度至少相隔 64px。
    final step = candidates.firstWhere(
      (s) => s * pxPerSecond >= 64,
      orElse: () => candidates.last,
    );

    final tickPaint = Paint()
      ..color = rulerColor.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    for (var t = 0.0; t <= totalSeconds; t += step) {
      final x = (t / totalSeconds) * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, rulerHeight * 0.5), tickPaint);

      final label = TextPainter(
        text: TextSpan(
          text: _formatTick(t, step),
          style: TextStyle(color: rulerColor, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelX = math.min(x + 3, size.width - label.width);
      label.paint(canvas, Offset(math.max(0, labelX), 1));
    }
  }

  String _formatTick(double seconds, double step) {
    if (step < 1) return '${seconds.toStringAsFixed(step < 0.1 ? 2 : 1)}s';
    final m = seconds ~/ 60;
    final s = (seconds % 60).round();
    return m > 0 ? '$m:${s.toString().padLeft(2, '0')}' : '${s}s';
  }

  void _paintWave(Canvas canvas, Size size, double midY, double waveHeight) {
    final baselinePaint = Paint()
      ..color = baselineColor
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, midY), Offset(size.width, midY), baselinePaint);

    if (peaks.isEmpty || size.width <= 0) return;

    final barPaint = Paint()
      ..color = waveColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6;

    const step = 2.5;
    final barCount = (size.width / step).floor();
    if (barCount <= 0) return;

    final maxHalf = waveHeight / 2 - 3;

    // 一个像素条可能覆盖多个包络桶，取区间内峰值以免丢失瞬态。
    for (var i = 0; i < barCount; i++) {
      final from = (peaks.length * i) ~/ barCount;
      var to = (peaks.length * (i + 1)) ~/ barCount;
      if (to <= from) to = math.min(from + 1, peaks.length);

      var peak = 0.0;
      for (var j = from; j < to; j++) {
        if (peaks[j] > peak) peak = peaks[j];
      }

      final half = (peak * maxHalf).clamp(0.5, maxHalf);
      final x = i * step + step / 2;
      canvas.drawLine(Offset(x, midY - half), Offset(x, midY + half), barPaint);
    }
  }

  /// 裁切区外的半透明遮罩：直观表示这部分会被丢弃。
  void _paintMask(Canvas canvas, Size size, double top, double height) {
    final paint = Paint()..color = maskColor;
    final startX = _x(trimStart, size.width);
    final endX = _x(trimEnd, size.width);

    if (startX > 0) {
      canvas.drawRect(Rect.fromLTWH(0, top, startX, height), paint);
    }
    if (endX < size.width) {
      canvas.drawRect(
        Rect.fromLTWH(endX, top, size.width - endX, height),
        paint,
      );
    }
  }

  void _paintHandles(Canvas canvas, Size size, double top, double height) {
    _paintHandle(
      canvas,
      _x(trimStart, size.width),
      top,
      height,
      isStart: true,
      active: activeHandle == _DragTarget.start,
    );
    _paintHandle(
      canvas,
      _x(trimEnd, size.width),
      top,
      height,
      isStart: false,
      active: activeHandle == _DragTarget.end,
    );
  }

  void _paintHandle(
    Canvas canvas,
    double x,
    double top,
    double height, {
    required bool isStart,
    required bool active,
  }) {
    final color = active ? activeHandleColor : handleColor;
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = active ? 2.5 : 1.8;
    canvas.drawLine(Offset(x, top), Offset(x, top + height), linePaint);

    // 抓手：朝向裁切区内侧的小圆角块，便于识别拖动方向。
    const gripW = 7.0;
    final gripH = math.min(26.0, height * 0.4);
    final left = isStart ? x : x - gripW;
    final rect = RRect.fromRectAndCorners(
      Rect.fromLTWH(left, top + (height - gripH) / 2, gripW, gripH),
      topLeft: Radius.circular(isStart ? 3 : 0),
      bottomLeft: Radius.circular(isStart ? 3 : 0),
      topRight: Radius.circular(isStart ? 0 : 3),
      bottomRight: Radius.circular(isStart ? 0 : 3),
    );
    canvas.drawRRect(rect, Paint()..color = color);
  }

  void _paintPlayhead(Canvas canvas, Size size, double top, double height) {
    final x = _x(playhead, size.width);
    final paint = Paint()
      ..color = playheadColor
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(x, top), Offset(x, top + height), paint);
    canvas.drawCircle(Offset(x, top), 3, Paint()..color = playheadColor);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) {
    return old.peaks != peaks ||
        old.duration != duration ||
        old.trimStart != trimStart ||
        old.trimEnd != trimEnd ||
        old.playhead != playhead ||
        old.enableTrim != enableTrim ||
        old.activeHandle != activeHandle ||
        old.waveColor != waveColor;
  }
}
