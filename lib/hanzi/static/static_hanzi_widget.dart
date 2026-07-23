part of '../hanzi_static.dart';

@immutable
class StaticHanziStyle {
  const StaticHanziStyle({
    this.defaultStrokeColor = Colors.black,
    this.radicalColor,
    this.allStrokeColor,
    this.strokeColorOverrides = const <int, Color>{},
  });

  final Color defaultStrokeColor;
  final Color? radicalColor;
  final Color? allStrokeColor;
  final Map<int, Color> strokeColorOverrides;

  /// Set all strokes to one color.
  StaticHanziStyle withAllStrokeColor(Color? color) {
    return StaticHanziStyle(
      defaultStrokeColor: defaultStrokeColor,
      radicalColor: radicalColor,
      allStrokeColor: color,
      strokeColorOverrides: strokeColorOverrides,
    );
  }

  /// Set one stroke color override.
  StaticHanziStyle withStrokeColor(int strokeIndex, Color color) {
    final next = Map<int, Color>.from(strokeColorOverrides);
    next[strokeIndex] = color;
    return StaticHanziStyle(
      defaultStrokeColor: defaultStrokeColor,
      radicalColor: radicalColor,
      allStrokeColor: allStrokeColor,
      strokeColorOverrides: next,
    );
  }

  /// Remove one stroke override.
  StaticHanziStyle withoutStrokeColor(int strokeIndex) {
    final next = Map<int, Color>.from(strokeColorOverrides);
    next.remove(strokeIndex);
    return StaticHanziStyle(
      defaultStrokeColor: defaultStrokeColor,
      radicalColor: radicalColor,
      allStrokeColor: allStrokeColor,
      strokeColorOverrides: next,
    );
  }

  Color resolveStrokeColor(HanziStrokeData data, int strokeIndex) {
    final global = allStrokeColor;
    if (global != null) {
      return global;
    }
    final override = strokeColorOverrides[strokeIndex];
    if (override != null) {
      return override;
    }
    if (radicalColor != null && data.radStrokes.contains(strokeIndex)) {
      return radicalColor!;
    }
    return defaultStrokeColor;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is StaticHanziStyle &&
        defaultStrokeColor == other.defaultStrokeColor &&
        radicalColor == other.radicalColor &&
        allStrokeColor == other.allStrokeColor &&
        mapEquals(strokeColorOverrides, other.strokeColorOverrides);
  }

  @override
  int get hashCode => Object.hash(
    defaultStrokeColor,
    radicalColor,
    allStrokeColor,
    Object.hashAllUnordered(
      strokeColorOverrides.entries.map(
        (entry) => Object.hash(entry.key, entry.value),
      ),
    ),
  );
}

class StaticHanziWidget extends StatelessWidget {
  const StaticHanziWidget({
    super.key,
    required this.data,
    this.size = 120,
    this.baseSize = 1024,
    this.padding = 12,
    this.visibleStrokeCount,
    this.style = const StaticHanziStyle(),
    this.backgroundColor = Colors.transparent,
    this.showOutline = false,
    this.outlineColor = const Color(0x22000000),
  });

  final HanziStrokeData data;
  final double size;
  final double baseSize;
  final double padding;

  /// Number of visible strokes from the start.
  ///
  /// - null means full character.
  /// - values are clamped to [0, data.strokeCount].
  final int? visibleStrokeCount;

  final StaticHanziStyle style;
  final Color backgroundColor;
  final bool showOutline;
  final Color outlineColor;

  @override
  Widget build(BuildContext context) {
    final clampedVisible = (visibleStrokeCount ?? data.strokeCount).clamp(
      0,
      data.strokeCount,
    );
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          isComplex: true,
          willChange: false,
          painter: _StaticHanziPainter(
            data: data,
            visibleStrokeCount: clampedVisible,
            baseSize: baseSize,
            padding: padding,
            style: style,
            backgroundColor: backgroundColor,
            showOutline: showOutline,
            outlineColor: outlineColor,
          ),
        ),
      ),
    );
  }
}

class _StaticHanziPainter extends CustomPainter {
  const _StaticHanziPainter({
    required this.data,
    required this.visibleStrokeCount,
    required this.baseSize,
    required this.padding,
    required this.style,
    required this.backgroundColor,
    required this.showOutline,
    required this.outlineColor,
  });

  final HanziStrokeData data;
  final int visibleStrokeCount;
  final double baseSize;
  final double padding;
  final StaticHanziStyle style;
  final Color backgroundColor;
  final bool showOutline;
  final Color outlineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }
    if (backgroundColor.a > 0) {
      canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor);
    }
    if (data.strokeCount == 0) {
      return;
    }

    final drawSize = size.shortestSide;
    final transform = _buildRenderTransform(
      drawSize: drawSize,
      padding: padding,
      fallbackSize: baseSize,
      bounds: data.bounds,
    );

    canvas.save();
    canvas.translate(transform.translateX, transform.translateY);
    canvas.scale(transform.scale, -transform.scale);

    if (showOutline) {
      final outlinePaint = Paint()
        ..style = PaintingStyle.fill
        ..color = outlineColor
        ..isAntiAlias = true;
      for (final path in data.paths) {
        canvas.drawPath(path, outlinePaint);
      }
    }

    final strokePaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final maxStroke = visibleStrokeCount.clamp(0, data.strokeCount);
    for (var i = 0; i < maxStroke; i++) {
      strokePaint.color = style.resolveStrokeColor(data, i);
      canvas.drawPath(data.paths[i], strokePaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StaticHanziPainter oldDelegate) {
    return data != oldDelegate.data ||
        visibleStrokeCount != oldDelegate.visibleStrokeCount ||
        baseSize != oldDelegate.baseSize ||
        padding != oldDelegate.padding ||
        style != oldDelegate.style ||
        backgroundColor != oldDelegate.backgroundColor ||
        showOutline != oldDelegate.showOutline ||
        outlineColor != oldDelegate.outlineColor;
  }
}

class _RenderTransform {
  const _RenderTransform({
    required this.scale,
    required this.translateX,
    required this.translateY,
  });

  final double scale;
  final double translateX;
  final double translateY;
}

_RenderTransform _buildRenderTransform({
  required double drawSize,
  required double padding,
  required double fallbackSize,
  required Rect bounds,
}) {
  final safePadding = padding.clamp(0.0, drawSize / 2);
  final drawable = (drawSize - 2 * safePadding).clamp(1.0, drawSize);

  var safeBounds = bounds;
  if (safeBounds.width <= 1e-6 || safeBounds.height <= 1e-6) {
    safeBounds = Rect.fromLTWH(0, 0, fallbackSize, fallbackSize);
  }

  final scaleX = drawable / safeBounds.width;
  final scaleY = drawable / safeBounds.height;
  final scale = scaleX < scaleY ? scaleX : scaleY;
  final xBuffer = safePadding + (drawable - scale * safeBounds.width) / 2;
  final yBuffer = safePadding + (drawable - scale * safeBounds.height) / 2;

  return _RenderTransform(
    scale: scale,
    translateX: xBuffer - safeBounds.left * scale,
    translateY: yBuffer + safeBounds.bottom * scale,
  );
}

/// Utility for adaptive median/debug overlays in future.
double adaptiveLogicalStrokeWidth({
  required double scale,
  required double minValue,
  required double maxValue,
}) {
  return ui.lerpDouble(minValue, maxValue, (1 / scale).clamp(0.0, 1.0)) ??
      minValue;
}
