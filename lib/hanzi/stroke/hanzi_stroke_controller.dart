part of '../hanzi_stroke.dart';

abstract class _HanziStrokeControllerBinding {
  void play();

  void pause();

  void reset();

  void nextStroke();

  void previousStroke();

  void setStrokeAnimationDuration(Duration duration);

  Future<void> animateCharacter();

  Future<void> animateStroke(int strokeNum);

  void hintNextStroke(int strokeNum);

  Future<void> animateCharacterLoop();

  Future<void> highlightStroke(int strokeNum, Duration duration);

  void setShowCharacter(bool showCharacter);

  void setShowOutline(bool showOutline);

  void setDelayBetweenStrokes(Duration delay);

  void setDelayBetweenLoops(Duration delay);

  void startQuiz(_QuizConfig config);

  void cancelQuiz();

  void skipQuizStroke();

  void setStrokeColorOverride(int strokeNum, Color? color);

  // 设置错误的笔画颜色
  void setMistakeStrokeColor({
    required List<int> strokeNums,
    required Color color,
    required Color defaultColor,
  });

  void clearStrokeColorOverrides();

  void setAllStrokeColorOverrides(Color? color);
}

class HanziStrokeController extends ChangeNotifier {
  /// 组件控制器。
  ///
  /// 用于外部控制播放、单笔切换、测验模式、颜色覆盖等行为。
  HanziStrokeController({
    /// 单笔动画时长。
    this.strokeAnimationDuration = const Duration(milliseconds: 700),

    /// 连续播放时，笔与笔之间的停顿。
    this.delayBetweenStrokes = Duration.zero,

    /// 循环播放时，整轮之间的停顿。
    this.delayBetweenLoops = Duration.zero,
  });

  Duration strokeAnimationDuration;
  Duration delayBetweenStrokes;
  Duration delayBetweenLoops;

  bool _isPlaying = false;
  int _visibleStrokeCount = 0;
  int _totalStrokes = 0;
  double _currentStrokeProgress = 0;
  _HanziStrokeControllerBinding? _binding;

  bool get isPlaying => _isPlaying;

  int get visibleStrokeCount => _visibleStrokeCount;

  int get totalStrokes => _totalStrokes;

  double get currentStrokeProgress => _currentStrokeProgress;

  void _attach(_HanziStrokeControllerBinding binding) {
    _binding = binding;
  }

  void _detach(_HanziStrokeControllerBinding binding) {
    if (identical(_binding, binding)) {
      _binding = null;
    }
  }

  void _updateState({
    required bool isPlaying,
    required int visibleStrokeCount,
    required int totalStrokes,
    required double currentStrokeProgress,
  }) {
    if (_isPlaying == isPlaying &&
        _visibleStrokeCount == visibleStrokeCount &&
        _totalStrokes == totalStrokes &&
        _currentStrokeProgress == currentStrokeProgress) {
      return;
    }
    _isPlaying = isPlaying;
    _visibleStrokeCount = visibleStrokeCount;
    _totalStrokes = totalStrokes;
    _currentStrokeProgress = currentStrokeProgress;
    notifyListeners();
  }

  /// 提示下一笔。
  void hintNextStroke(int strokeNum) => _binding?.hintNextStroke(strokeNum);

  /// 开始/继续播放整字动画。
  void play() => _binding?.play();

  /// 暂停动画。
  void pause() => _binding?.pause();

  /// 重置到初始状态。
  void reset() => _binding?.reset();

  /// 进入下一笔（带该笔动画）。
  void nextStroke() => _binding?.nextStroke();

  /// 回到上一笔（立即回退）。
  void previousStroke() => _binding?.previousStroke();

  /// 设置单笔动画时长。
  void setStrokeAnimationDuration(Duration duration) {
    strokeAnimationDuration = duration;
    _binding?.setStrokeAnimationDuration(duration);
  }

  /// 播放整字一次。
  Future<void> animateCharacter() async {
    await _binding?.animateCharacter();
  }

  /// 播放指定笔画一次。
  Future<void> animateStroke(int strokeNum) async {
    await _binding?.animateStroke(strokeNum);
  }

  /// 循环播放整字。
  Future<void> animateCharacterLoop() async {
    await _binding?.animateCharacterLoop();
  }

  /// 临时高亮某一笔。
  Future<void> highlightStroke(
    int strokeNum, {
    Duration duration = const Duration(milliseconds: 200),
  }) async {
    await _binding?.highlightStroke(strokeNum, duration);
  }

  void pauseAnimation() => pause();

  void resumeAnimation() => play();

  /// 显示主字形。
  void showCharacter() => _binding?.setShowCharacter(true);

  /// 隐藏主字形。
  void hideCharacter() => _binding?.setShowCharacter(false);

  /// 显示轮廓层。
  void showOutline() => _binding?.setShowOutline(true);

  /// 隐藏轮廓层。
  void hideOutline() => _binding?.setShowOutline(false);

  /// 设置笔画间隔时长（连续播放时生效）。
  void setDelayBetweenStrokes(Duration delay) {
    delayBetweenStrokes = delay;
    _binding?.setDelayBetweenStrokes(delay);
  }

  /// 设置循环播放每轮间隔。
  void setDelayBetweenLoops(Duration delay) {
    delayBetweenLoops = delay;
    _binding?.setDelayBetweenLoops(delay);
  }

  /// 进入测验模式。
  void quiz([HanziQuizOptions options = const HanziQuizOptions()]) {
    _binding?.startQuiz(
      _QuizConfig(
        leniency: options.leniency,
        averageDistanceThreshold: options.averageDistanceThreshold,
        coverageThreshold: options.coverageThreshold,
        startPointThreshold: options.startPointThreshold,
        endPointThreshold: options.endPointThreshold,
        acceptBackwardsStrokes: options.acceptBackwardsStrokes,
        backwardsDirectionThreshold: options.backwardsDirectionThreshold,
        showHintAfterMisses: options.showHintAfterMisses,
        hintDisplayDuration: options.hintDisplayDuration,
        hintColor: options.hintColor,
        hintMode: options.hintMode,
        // 兼容历史参数：未单独配置错误提示时，沿用旧 hintColor/hintDisplayDuration。
        mistakeHintColor: options.mistakeHintColor ?? options.hintColor,
        mistakeHintFadeInDuration: options.mistakeHintFadeInDuration,
        mistakeHintSweepDuration:
            options.mistakeHintSweepDuration ?? options.hintDisplayDuration,
        mistakeHintFadeOutDuration: options.mistakeHintFadeOutDuration,
        // 引导提示也允许回退到旧 hintColor/hintDisplayDuration，避免破坏老调用。
        guideHintColor: options.guideHintColor ?? options.hintColor,
        guideHintFadeInDuration: options.guideHintFadeInDuration,
        guideHintSweepDuration:
            options.guideHintSweepDuration ?? options.hintDisplayDuration,
        guideHintFadeOutDuration: options.guideHintFadeOutDuration,
        guideHintLoopGapDuration: options.guideHintLoopGapDuration,
        correctStrokeFadeDuration: options.correctStrokeFadeDuration,
        enableCorrectStrokeMotion: options.enableCorrectStrokeMotion,
        correctStrokeEnterOffset: options.correctStrokeEnterOffset,
        correctStrokeMotionDuration: options.correctStrokeMotionDuration,
        correctStrokeSpringOvershoot: options.correctStrokeSpringOvershoot,
        correctStrokeSpringWindow: options.correctStrokeSpringWindow,
        markStrokeCorrectAfterMisses: options.markStrokeCorrectAfterMisses,
        onMistake: options.onMistake,
        onHintMistake: options.onHintMistake,
        onCorrectStroke: options.onCorrectStroke,
        onComplete: options.onComplete,
      ),
    );
  }

  /// 取消测验模式。
  void cancelQuiz() => _binding?.cancelQuiz();

  /// 跳过当前测验笔画。
  void skipQuizStroke() => _binding?.skipQuizStroke();

  /// 为单笔设置覆盖颜色。
  void setStrokeColor(int strokeNum, Color color) {
    _binding?.setStrokeColorOverride(strokeNum, color);
  }

  /// 清除单笔覆盖颜色。
  void clearStrokeColor(int strokeNum) {
    _binding?.setStrokeColorOverride(strokeNum, null);
  }

  /// 清除全部覆盖颜色。
  void clearAllStrokeColors() {
    _binding?.clearStrokeColorOverrides();
  }

  /// 一次性将所有笔画设置为同一覆盖颜色。
  void setAllStrokeColors(Color color) {
    _binding?.setAllStrokeColorOverrides(color);
  }

  /// 设置错误的笔画颜色
  void setMistakeStrokeColor({
    required List<int> strokeNums,
    required Color color,
    required Color defaultColor,
  }) {
    _binding?.setMistakeStrokeColor(
      strokeNums: strokeNums,
      color: color,
      defaultColor: defaultColor,
    );
  }

  /// 重置全部笔画颜色到默认策略。
  void resetAllStrokeColors() {
    _binding?.setAllStrokeColorOverrides(null);
  }
}
