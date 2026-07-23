part of '../hanzi_static.dart';

typedef StaticHanziStepWrapBuilder =
    Widget Function(int stepIndex, int visibleStrokeCount, Widget child);

/// Build discrete stroke-order snapshots for list/grid usage.
///
/// Example for `二`:
/// - step 0: 一 (visibleStrokeCount = 1)
/// - step 1: 二 (visibleStrokeCount = 2)
class StaticHanziSequenceBuilder {
  const StaticHanziSequenceBuilder({
    required this.data,
    this.includeEmptyStep = false,
  });

  final HanziStrokeData data;
  final bool includeEmptyStep;

  int get stepCount => data.strokeCount + (includeEmptyStep ? 1 : 0);

  int visibleStrokeCountForStep(int stepIndex) {
    assert(stepIndex >= 0 && stepIndex < stepCount);
    if (includeEmptyStep) {
      return stepIndex;
    }
    return stepIndex + 1;
  }

  List<int> buildStrokeProgression() {
    return List<int>.generate(
      stepCount,
      (index) => visibleStrokeCountForStep(index),
      growable: false,
    );
  }

  /// Build plain `StaticHanziWidget` list.
  List<StaticHanziWidget> buildWidgets({
    required double size,
    double baseSize = 1024,
    double padding = 12,
    StaticHanziStyle style = const StaticHanziStyle(),
    Color backgroundColor = const Color(0x00000000),
    bool showOutline = false,
    Color outlineColor = const Color(0x22000000),
  }) {
    final progression = buildStrokeProgression();
    return progression
        .map(
          (visibleStrokeCount) => StaticHanziWidget(
            data: data,
            size: size,
            baseSize: baseSize,
            padding: padding,
            visibleStrokeCount: visibleStrokeCount,
            style: style,
            backgroundColor: backgroundColor,
            showOutline: showOutline,
            outlineColor: outlineColor,
          ),
        )
        .toList(growable: false);
  }

  /// Build wrapped widgets for custom frame/card/list item layout.
  List<Widget> buildWrappedWidgets({
    required double size,
    required StaticHanziStepWrapBuilder wrapBuilder,
    double baseSize = 1024,
    double padding = 12,
    StaticHanziStyle style = const StaticHanziStyle(),
    Color backgroundColor = const Color(0x00000000),
    bool showOutline = false,
    Color outlineColor = const Color(0x22000000),
  }) {
    final progression = buildStrokeProgression();
    return List<Widget>.generate(stepCount, (index) {
      final visibleStrokeCount = progression[index];
      final child = StaticHanziWidget(
        data: data,
        size: size,
        baseSize: baseSize,
        padding: padding,
        visibleStrokeCount: visibleStrokeCount,
        style: style,
        backgroundColor: backgroundColor,
        showOutline: showOutline,
        outlineColor: outlineColor,
      );
      return wrapBuilder(index, visibleStrokeCount, child);
    }, growable: false);
  }
}
