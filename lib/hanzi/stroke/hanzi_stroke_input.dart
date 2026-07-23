part of '../hanzi_stroke.dart';

class StrokeSample {
  const StrokeSample({
    required this.position,
    required this.timeStamp,
    required this.kind,
    required this.pressure,
    required this.pressureMin,
    required this.pressureMax,
  });

  final Offset position;
  final Duration timeStamp;
  final ui.PointerDeviceKind kind;
  final double pressure;
  final double pressureMin;
  final double pressureMax;
}

class StrokeSegment {
  const StrokeSegment({
    required this.from,
    required this.to,
    required this.width,
  });

  final Offset from;
  final Offset to;
  final double width;
}

class DynamicStrokeWidthResolver {
  const DynamicStrokeWidthResolver({
    required this.enableDynamicWidth,
    required this.baseWidth,
    this.minWidth,
    this.maxWidth,
    this.velocitySmoothing = 0.16,
    this.minVelocity = 20,
    this.maxVelocity = 900,
    this.widthSmoothing = 0.28,
  });

  final bool enableDynamicWidth;
  final double baseWidth;
  final double? minWidth;
  final double? maxWidth;
  final double velocitySmoothing;
  final double minVelocity;
  final double maxVelocity;
  final double widthSmoothing;

  List<StrokeSegment> buildSegments(List<StrokeSample> samples) {
    if (samples.length < 2) return const <StrokeSegment>[];
    final resolvedMin = (minWidth ?? (baseWidth * 0.45)).clamp(0.1, 1000.0);
    final resolvedMax = (maxWidth ?? (baseWidth * 1.7)).clamp(
      resolvedMin,
      1000.0,
    );
    if ((resolvedMax - resolvedMin).abs() < 1e-4) {
      return _buildFixedSegments(samples, resolvedMin);
    }

    if (!enableDynamicWidth) {
      return _buildFixedSegments(samples, baseWidth);
    }
    if (_supportsStylusPressure(samples)) {
      return _buildPressureSegments(
        samples,
        minW: resolvedMin,
        maxW: resolvedMax,
      );
    }
    return _buildVelocitySegments(
      samples,
      minW: resolvedMin,
      maxW: resolvedMax,
    );
  }

  bool _supportsStylusPressure(List<StrokeSample> samples) {
    for (final sample in samples) {
      final isStylus =
          sample.kind == ui.PointerDeviceKind.stylus ||
          sample.kind == ui.PointerDeviceKind.invertedStylus;
      if (!isStylus) continue;
      final range = sample.pressureMax - sample.pressureMin;
      if (range > 1e-4) return true;
    }
    return false;
  }

  List<StrokeSegment> _buildFixedSegments(
    List<StrokeSample> samples,
    double width,
  ) {
    final out = <StrokeSegment>[];
    for (var i = 1; i < samples.length; i++) {
      final from = samples[i - 1].position;
      final to = samples[i].position;
      if ((to - from).distance <= 1e-6) continue;
      out.add(StrokeSegment(from: from, to: to, width: width));
    }
    return out;
  }

  List<StrokeSegment> _buildPressureSegments(
    List<StrokeSample> samples, {
    required double minW,
    required double maxW,
  }) {
    final out = <StrokeSegment>[];
    var prevWidth = (minW + maxW) / 2;
    for (var i = 1; i < samples.length; i++) {
      final a = samples[i - 1];
      final b = samples[i];
      final distance = (b.position - a.position).distance;
      if (distance <= 1e-6) continue;

      final bRange = (b.pressureMax - b.pressureMin).abs();
      final rawNorm =
          bRange > 1e-4
              ? (b.pressure - b.pressureMin) / (b.pressureMax - b.pressureMin)
              : 0.5;
      final pNorm = rawNorm.clamp(0.0, 1.0);
      final targetWidth = ui.lerpDouble(minW, maxW, pNorm) ?? prevWidth;
      final width =
          ui.lerpDouble(
            prevWidth,
            targetWidth,
            widthSmoothing.clamp(0.0, 1.0),
          ) ??
          targetWidth;

      out.add(StrokeSegment(from: a.position, to: b.position, width: width));
      prevWidth = width;
    }
    return out;
  }

  List<StrokeSegment> _buildVelocitySegments(
    List<StrokeSample> samples, {
    required double minW,
    required double maxW,
  }) {
    final out = <StrokeSegment>[];
    var smoothVelocity = minVelocity;
    var prevWidth = maxW;
    for (var i = 1; i < samples.length; i++) {
      final a = samples[i - 1];
      final b = samples[i];
      final delta = b.position - a.position;
      final distance = delta.distance;
      if (distance <= 1e-6) continue;

      final dtUs = (b.timeStamp - a.timeStamp).inMicroseconds.abs();
      final dtSeconds = (dtUs <= 0 ? 1 : dtUs) / 1000000.0;
      final velocity = distance / dtSeconds;

      smoothVelocity =
          ui.lerpDouble(
            smoothVelocity,
            velocity,
            velocitySmoothing.clamp(0.0, 1.0),
          ) ??
          velocity;
      final velocityNorm = ((smoothVelocity - minVelocity) /
              (maxVelocity - minVelocity))
          .clamp(0.0, 1.0);
      final speedToPressure = 1.0 - velocityNorm;
      final targetWidth =
          ui.lerpDouble(minW, maxW, speedToPressure) ?? prevWidth;
      final width =
          ui.lerpDouble(
            prevWidth,
            targetWidth,
            widthSmoothing.clamp(0.0, 1.0),
          ) ??
          targetWidth;

      out.add(StrokeSegment(from: a.position, to: b.position, width: width));
      prevWidth = width;
    }
    return out;
  }
}
