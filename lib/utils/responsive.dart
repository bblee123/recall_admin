import 'package:flutter/material.dart';

/// 优雅的 Tailwind 式响应式上下文扩展
extension TailwindResponsiveContext on BuildContext {
  /// 1. 获取当前屏幕的逻辑像素宽度
  /// 使用 MediaQuery.sizeOf(this) 比普通的 MediaQuery.of(this).size 性能更好，
  /// 它只在宽度改变时才触发组件重绘，非常适合分屏拉伸的场景。
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// 2. 快捷断点判断（方便在其他地方做布尔判断）
  bool get isSm => screenWidth < 600.0;
  bool get isMd => screenWidth >= 600.0 && screenWidth < 840.0;
  bool get isLg => screenWidth >= 840.0;

  /// 3. 核心 select 方法
  /// 利用了 Dart 的「泛型 <T>」，这意味着它不仅可以返回 Axis 方向，
  /// 还可以返回 double(间距)、EdgeInsets(内边距)、Color(颜色) 等任何类型。
  T responsive<T>({
    required T sm, // 手机端的值（必填，作为保底基准值）
    T? md, // 平板竖屏/中屏的值（选填）
    T? lg, // 平板横屏/大屏的值（选填）
  }) {
    // 逻辑：从最大屏幕向上匹配，如果大屏没有传值，则优雅降级使用小屏的值
    if (isLg) {
      return lg ?? md ?? sm;
    }
    if (isMd) {
      return md ?? sm;
    }
    return sm;
  }
}
