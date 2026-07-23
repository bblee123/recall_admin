import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:path_drawing/path_drawing.dart'; // 确保引入了 parseSvgPathData 所在的包

class HanziStrokeData {
  /// 汉字笔画数据。
  ///
  /// - [strokes]：SVG Path 字符串数组，每个元素对应一笔的轮廓。
  /// - [medians]：每笔中心轨迹（中线）坐标数组。
  /// - [radStrokes]：属于部首的笔画索引集合（用于特殊着色）。
  HanziStrokeData({
    required this.strokes,
    required this.medians,
    this.radStrokes = const <int>{},
  });

  // 增加一个 fromBlob 方法，用于从 Uint8List 构建对象。
  factory HanziStrokeData.fromBlob(Uint8List blob) {
    final bytes = GZipCodec().decode(blob);
    final jsonString = utf8.decode(bytes);
    final decodedStroke = jsonDecode(jsonString);
    return HanziStrokeData.fromMap(decodedStroke);
  }

  /// 从 HanziWriter 风格的 Map 数据构建对象。
  factory HanziStrokeData.fromMap(Map<String, dynamic> map) {
    final strokeList = (map['strokes'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => item.toString())
        .toList(growable: false);

    final medianList = (map['medians'] as List<dynamic>? ?? const <dynamic>[])
        .map((strokeMedian) {
          final points = strokeMedian as List<dynamic>? ?? const <dynamic>[];
          return points
              .map((pair) {
                final values = pair as List<dynamic>? ?? const <dynamic>[];
                final x = values.isNotEmpty
                    ? (values[0] as num).toDouble()
                    : 0.0;
                final y = values.length > 1
                    ? (values[1] as num).toDouble()
                    : 0.0;
                return Offset(x, y);
              })
              .toList(growable: false);
        })
        .toList(growable: false);

    final radStrokeList =
        (map['radStrokes'] as List<dynamic>? ?? const <dynamic>[])
            .map((value) => value as num)
            .map((value) => value.toInt())
            .toSet();

    return HanziStrokeData(
      strokes: strokeList,
      medians: medianList,
      radStrokes: radStrokeList,
    );
  }

  final List<String> strokes;
  final List<List<Offset>> medians;
  final Set<int> radStrokes;

  // 缓存变量
  List<Path>? _cachedPaths;
  Rect? _cachedBounds;

  /// 总笔画数
  int get strokeCount => strokes.length;

  /// 解析后的笔画 [Path] 数组，按需懒加载缓存。
  List<Path> get paths =>
      _cachedPaths ??= strokes.map((path) => parseSvgPathData(path)).toList();

  /// 所有笔画路径的联合边界（包围盒），常用于绘制时的缩放或居中对齐，已做缓存优化。
  Rect get bounds => _cachedBounds ??= _computeBounds();

  /// 计算联合边界的私有方法
  Rect _computeBounds() {
    Rect? merged;
    for (final path in paths) {
      final current = path.getBounds();
      if (current.isEmpty) {
        continue;
      }
      merged = merged == null ? current : merged.expandToInclude(current);
    }
    // 如果没有有效边界，默认返回 hanzi-writer 标准的 1024x1024 区域
    return merged ?? const Rect.fromLTWH(0, 0, 1024, 1024);
  }
}
