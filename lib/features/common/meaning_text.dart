import 'package:flutter/material.dart';

/// 释义展示（对照 Vue 项目 components/meaning.vue）。
///
/// 合并释义时后端/前端用 `&split&` 连接多条，这里按分隔符拆成多行。
class MeaningText extends StatelessWidget {
  const MeaningText({
    super.key,
    required this.meaning,
    this.showOne = false,
    this.style,
  });

  final String? meaning;

  /// 仅显示首条（对照 meaning.vue show="one"）。
  final bool showOne;

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final raw = meaning ?? '';
    if (raw.isEmpty) return const SizedBox.shrink();
    final parts = raw
        .split('&split&')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return const SizedBox.shrink();
    if (showOne) {
      return Text(parts.first, style: style);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < parts.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              parts.length > 1 ? '${i + 1}. ${parts[i]}' : parts[i],
              style: style,
            ),
          ),
      ],
    );
  }
}
