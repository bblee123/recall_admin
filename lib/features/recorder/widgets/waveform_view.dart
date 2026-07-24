import 'package:flutter/material.dart';

/// 波形图：把 0..1 的振幅序列画成居中对称的竖条，最新数据在右侧。
class WaveformView extends StatelessWidget {
  const WaveformView({
    super.key,
    required this.amplitudes,
    this.color,
    this.barWidth = 3,
    this.barGap = 2,
    this.active = true,
  });

  /// 归一化振幅（0..1），末尾为最新值。
  final List<double> amplitudes;
  final Color? color;
  final double barWidth;
  final double barGap;

  /// 是否处于录制态（影响颜色亮度）。
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final barColor = color ??
        (active ? scheme.primary : scheme.primary.withValues(alpha: 0.45));
    return ClipRect(
      child: CustomPaint(
        painter: _WaveformPainter(
          amplitudes: amplitudes,
          color: barColor,
          baselineColor: scheme.outlineVariant,
          barWidth: barWidth,
          barGap: barGap,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.amplitudes,
    required this.color,
    required this.baselineColor,
    required this.barWidth,
    required this.barGap,
  });

  final List<double> amplitudes;
  final Color color;
  final Color baselineColor;
  final double barWidth;
  final double barGap;

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height / 2;

    final baselinePaint = Paint()
      ..color = baselineColor
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, midY), Offset(size.width, midY), baselinePaint);

    if (amplitudes.isEmpty) return;

    final barPaint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;

    final step = barWidth + barGap;
    final maxBars = (size.width / step).floor();
    if (maxBars <= 0) return;

    // 只取能显示下的最新 N 个，靠右对齐。
    final start =
        amplitudes.length > maxBars ? amplitudes.length - maxBars : 0;
    final visible = amplitudes.sublist(start);

    for (var i = 0; i < visible.length; i++) {
      final v = visible[i].clamp(0.0, 1.0);
      final x = size.width - (visible.length - i) * step + barWidth / 2;
      if (x < 0) continue;
      final half = (v * (size.height / 2 - 2)).clamp(0.5, size.height / 2);
      canvas.drawLine(Offset(x, midY - half), Offset(x, midY + half), barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) {
    return old.amplitudes != amplitudes ||
        old.color != color ||
        old.barWidth != barWidth ||
        old.barGap != barGap;
  }
}
