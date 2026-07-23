import 'package:json_annotation/json_annotation.dart';

import 'variant.dart';

part 'character.g.dart';

/// 单字查询实体（对照 characterType.d.ts CharItem / ChineseChar）。
///
/// [stroke] 保留后端原始结构（strokes/medians/radStrokes），
/// 直接用于 `HanziStrokeData.fromMap`。
@JsonSerializable(explicitToJson: true)
class CharItem {
  const CharItem({
    this.charText = '',
    this.radical = '',
    this.strokeCount = 0,
    this.isPolyphone = 0,
    this.variants = const <Variant>[],
    this.stroke,
  });

  @JsonKey(name: 'char_text')
  final String charText;

  final String radical;

  @JsonKey(name: 'stroke_count')
  final int strokeCount;

  @JsonKey(name: 'is_polyphone')
  final int isPolyphone;

  final List<Variant> variants;

  /// 原始笔画数据，可能是对象（有数据）或空数组（无数据）。
  final dynamic stroke;

  bool get polyphone => isPolyphone == 1;

  /// 取笔画 Map；无有效数据时返回 null。
  Map<String, dynamic>? get strokeMap {
    final value = stroke;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  factory CharItem.fromJson(Map<String, dynamic> json) =>
      _$CharItemFromJson(json);

  Map<String, dynamic> toJson() => _$CharItemToJson(this);
}
