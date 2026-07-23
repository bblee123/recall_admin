part of '../hanzi_stroke.dart';

/// 单笔测验回调类型。
typedef HanziQuizStrokeCallback = void Function(HanziQuizStrokeData data);

/// 完成整字测验后的回调类型。
typedef HanziQuizCompleteCallback = void Function(HanziQuizSummary summary);

/// Quiz 提示模式：
/// - [off]：关闭所有自动提示轨道。
/// - [onMistake]：仅按错误阈值触发提示。
/// - [alwaysGuide]：持续循环引导当前目标笔（仍可同时保留错误提示）。
enum HanziQuizHintMode { off, onMistake, alwaysGuide }

/// 一次笔画判定（正确或错误）后的统计数据。
class HanziQuizStrokeData {
  const HanziQuizStrokeData({
    required this.strokeNum,
    required this.mistakesOnStroke,
    required this.totalMistakes,
    required this.strokesRemaining,
    required this.averageDistance,
    required this.coverage,
    required this.startDistance,
    required this.endDistance,
    required this.isBackwards,
  });

  final int strokeNum;
  final int mistakesOnStroke;
  final int totalMistakes;
  final int strokesRemaining;
  final double averageDistance;
  final double coverage;
  final double startDistance;
  final double endDistance;
  final bool isBackwards;
}

/// 一次测验完成时的汇总结果。
class HanziQuizSummary {
  const HanziQuizSummary({
    required this.totalStrokes,
    required this.totalMistakes,
  });

  final int totalStrokes;
  final int totalMistakes;
}

/// 测验模式配置。
///
/// 说明：
/// - 距离/覆盖阈值用于控制判定严格程度。
/// - `showHintAfterMisses` 和 `hintDisplayDuration` 控制错误提示。
/// - `correctStrokeFadeDuration` 控制答对后笔画淡入时长。
/// - `enableCorrectStrokeMotion` 等参数控制判对后入场位移动效。
class HanziQuizOptions {
  const HanziQuizOptions({
    /// 判定松紧系数（>1 更宽松，<1 更严格）。
    this.leniency = 1.0,

    /// 用户轨迹与目标中线的平均距离阈值（单位：字坐标）。
    this.averageDistanceThreshold = 350.0,

    /// 覆盖率阈值，范围 0~1，越大要求越高。
    this.coverageThreshold = 0.7,

    /// 起笔点允许偏差阈值。
    this.startPointThreshold = 220.0,

    /// 收笔点允许偏差阈值。
    this.endPointThreshold = 220.0,

    /// 是否接受反向书写通过。
    this.acceptBackwardsStrokes = false,

    /// 反向判定阈值（方向点积阈值，越小越容易判反向）。
    this.backwardsDirectionThreshold = 0.15,

    /// 错误达到多少次后显示提示；设为 null 表示关闭。
    this.showHintAfterMisses = 3,

    /// 每次提示笔迹动画显示时长。
    this.hintDisplayDuration = const Duration(milliseconds: 900),

    /// 提示笔迹动画颜色。
    this.hintColor = const Color(0xFFAAAAFF),

    /// 提示模式：支持关闭、按错误触发、以及持续引导。
    this.hintMode = HanziQuizHintMode.onMistake,

    /// 错误提示颜色（null 时回退到 [hintColor]）。
    this.mistakeHintColor = const Color(0xFFAAAAFF),

    /// 错误提示的淡入时长。
    this.mistakeHintFadeInDuration = const Duration(milliseconds: 120),

    /// 错误提示的中线扫过时长（用于控制提示播放速度）。
    this.mistakeHintSweepDuration = const Duration(milliseconds: 900),

    /// 错误提示的淡出时长。
    this.mistakeHintFadeOutDuration = const Duration(milliseconds: 180),

    /// 引导提示颜色（null 时回退到 [hintColor]）。
    this.guideHintColor = const Color.fromARGB(255, 144, 144, 144),

    /// 引导提示的淡入时长。
    this.guideHintFadeInDuration = const Duration(milliseconds: 120),

    /// 引导提示的中线扫过时长（用于控制提示播放速度）。
    this.guideHintSweepDuration = const Duration(milliseconds: 900),

    /// 引导提示的淡出时长。
    this.guideHintFadeOutDuration = const Duration(milliseconds: 180),

    /// 引导提示循环间隔时长（每轮 FadeOut 后等待再重播）。
    this.guideHintLoopGapDuration = const Duration(milliseconds: 260),

    /// 答对后该笔淡入时长；设为 Duration.zero 则立即显示。
    this.correctStrokeFadeDuration = const Duration(milliseconds: 280),

    /// 是否启用判对后的“偏移入场 + 回弹”动效。
    this.enableCorrectStrokeMotion = true,

    /// 判对笔画入场偏移距离（单位：字坐标）。
    this.correctStrokeEnterOffset = 48.0,

    /// 判对笔画位移动画总时长。
    this.correctStrokeMotionDuration = const Duration(milliseconds: 1000),

    /// 回弹幅度系数（建议 0~0.3）。
    this.correctStrokeSpringOvershoot = 0,

    /// 回弹所占末段窗口比例（范围 0~1）。
    this.correctStrokeSpringWindow = 0,

    /// 连续错误达到该值后强制判当前笔通过；null 为关闭。
    this.markStrokeCorrectAfterMisses,

    /// 每次判错回调。
    this.onMistake,

    /// 每次判对回调。
    this.onCorrectStroke,

    /// 每次提示判错回调。
    this.onHintMistake,

    /// 全部完成回调。
    this.onComplete,
  });

  final double leniency;
  final double averageDistanceThreshold;
  final double coverageThreshold;
  final double startPointThreshold;
  final double endPointThreshold;
  final bool acceptBackwardsStrokes;
  final double backwardsDirectionThreshold;
  final int? showHintAfterMisses;
  final Duration hintDisplayDuration;
  final Color hintColor;
  final HanziQuizHintMode hintMode;
  final Color? mistakeHintColor;
  final Duration mistakeHintFadeInDuration;
  final Duration? mistakeHintSweepDuration;
  final Duration mistakeHintFadeOutDuration;
  final Color? guideHintColor;
  final Duration guideHintFadeInDuration;
  final Duration? guideHintSweepDuration;
  final Duration guideHintFadeOutDuration;
  final Duration guideHintLoopGapDuration;
  final Duration correctStrokeFadeDuration;
  final bool enableCorrectStrokeMotion;
  final double correctStrokeEnterOffset;
  final Duration correctStrokeMotionDuration;
  final double correctStrokeSpringOvershoot;
  final double correctStrokeSpringWindow;
  final int? markStrokeCorrectAfterMisses;
  final HanziQuizStrokeCallback? onMistake;
  final HanziQuizStrokeCallback? onHintMistake;
  final HanziQuizStrokeCallback? onCorrectStroke;
  final HanziQuizCompleteCallback? onComplete;
}

class _QuizConfig {
  const _QuizConfig({
    this.leniency = 1.0,
    this.averageDistanceThreshold = 350.0,
    this.coverageThreshold = 0.7,
    this.startPointThreshold = 220.0,
    this.endPointThreshold = 220.0,
    this.acceptBackwardsStrokes = false,
    this.backwardsDirectionThreshold = 0.15,
    this.showHintAfterMisses = 3,
    this.hintDisplayDuration = const Duration(milliseconds: 900),
    this.hintColor = const Color(0xFFAAAAFF),
    this.hintMode = HanziQuizHintMode.onMistake,
    this.mistakeHintColor = const Color(0xFFAAAAFF),
    this.mistakeHintFadeInDuration = const Duration(milliseconds: 120),
    this.mistakeHintSweepDuration = const Duration(milliseconds: 900),
    this.mistakeHintFadeOutDuration = const Duration(milliseconds: 180),
    this.guideHintColor = const Color(0xFF66AAFF),
    this.guideHintFadeInDuration = const Duration(milliseconds: 120),
    this.guideHintSweepDuration = const Duration(milliseconds: 900),
    this.guideHintFadeOutDuration = const Duration(milliseconds: 180),
    this.guideHintLoopGapDuration = const Duration(milliseconds: 260),
    this.correctStrokeFadeDuration = const Duration(milliseconds: 280),
    this.enableCorrectStrokeMotion = true,
    this.correctStrokeEnterOffset = 48.0,
    this.correctStrokeMotionDuration = const Duration(milliseconds: 280),
    this.correctStrokeSpringOvershoot = 0.12,
    this.correctStrokeSpringWindow = 0.22,
    this.markStrokeCorrectAfterMisses,
    this.onMistake,
    this.onHintMistake,
    this.onCorrectStroke,
    this.onComplete,
  });

  final double leniency;
  final double averageDistanceThreshold;
  final double coverageThreshold;
  final double startPointThreshold;
  final double endPointThreshold;
  final bool acceptBackwardsStrokes;
  final double backwardsDirectionThreshold;
  final int? showHintAfterMisses;
  final Duration hintDisplayDuration;
  final Color hintColor;
  final HanziQuizHintMode hintMode;
  final Color mistakeHintColor;
  final Duration mistakeHintFadeInDuration;
  final Duration mistakeHintSweepDuration;
  final Duration mistakeHintFadeOutDuration;
  final Color guideHintColor;
  final Duration guideHintFadeInDuration;
  final Duration guideHintSweepDuration;
  final Duration guideHintFadeOutDuration;
  final Duration guideHintLoopGapDuration;
  final Duration correctStrokeFadeDuration;
  final bool enableCorrectStrokeMotion;
  final double correctStrokeEnterOffset;
  final Duration correctStrokeMotionDuration;
  final double correctStrokeSpringOvershoot;
  final double correctStrokeSpringWindow;
  final int? markStrokeCorrectAfterMisses;
  final HanziQuizStrokeCallback? onMistake;
  final HanziQuizStrokeCallback? onHintMistake;
  final HanziQuizStrokeCallback? onCorrectStroke;
  final HanziQuizCompleteCallback? onComplete;
}

class _RenderTransform {
  const _RenderTransform({
    required this.scale,
    required this.translateX,
    required this.translateY,
    required this.bounds,
  });

  final double scale;
  final double translateX;
  final double translateY;
  final Rect bounds;
}

_RenderTransform _buildRenderTransform({
  required double drawSize,
  required double padding,
  required List<Path> paths,
  required double fallbackSize,
}) {
  final safePadding = padding.clamp(0.0, drawSize / 2);
  final drawable = (drawSize - 2 * safePadding).clamp(1.0, drawSize);

  Rect? bounds;
  for (final path in paths) {
    final pathBounds = path.getBounds();
    if (pathBounds.isEmpty) continue;
    bounds = bounds == null ? pathBounds : bounds.expandToInclude(pathBounds);
  }
  bounds ??= Rect.fromLTWH(0, 0, fallbackSize, fallbackSize);
  if (bounds.width <= 1e-6 || bounds.height <= 1e-6) {
    bounds = Rect.fromLTWH(0, 0, fallbackSize, fallbackSize);
  }

  final scaleX = drawable / bounds.width;
  final scaleY = drawable / bounds.height;
  final scale = scaleX < scaleY ? scaleX : scaleY;
  final xBuffer = safePadding + (drawable - scale * bounds.width) / 2;
  final yBuffer = safePadding + (drawable - scale * bounds.height) / 2;
  final translateX = xBuffer - bounds.left * scale;
  final translateY = yBuffer + bounds.bottom * scale;

  return _RenderTransform(
    scale: scale,
    translateX: translateX,
    translateY: translateY,
    bounds: bounds,
  );
}
