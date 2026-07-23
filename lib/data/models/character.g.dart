// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharItem _$CharItemFromJson(Map<String, dynamic> json) => CharItem(
  charText: json['char_text'] as String? ?? '',
  radical: json['radical'] as String? ?? '',
  strokeCount: (json['stroke_count'] as num?)?.toInt() ?? 0,
  isPolyphone: (json['is_polyphone'] as num?)?.toInt() ?? 0,
  variants:
      (json['variants'] as List<dynamic>?)
          ?.map((e) => Variant.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Variant>[],
  stroke: json['stroke'],
);

Map<String, dynamic> _$CharItemToJson(CharItem instance) => <String, dynamic>{
  'char_text': instance.charText,
  'radical': instance.radical,
  'stroke_count': instance.strokeCount,
  'is_polyphone': instance.isPolyphone,
  'variants': instance.variants.map((e) => e.toJson()).toList(),
  'stroke': instance.stroke,
};
