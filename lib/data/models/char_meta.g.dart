// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'char_meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharMeta _$CharMetaFromJson(Map<String, dynamic> json) => CharMeta(
  id: (json['id'] as num?)?.toInt(),
  wordId: (json['word_id'] as num?)?.toInt(),
  charText: json['char_text'] as String,
  pinyin: json['pinyin'] as String,
  position: (json['position'] as num).toInt(),
);

Map<String, dynamic> _$CharMetaToJson(CharMeta instance) => <String, dynamic>{
  'id': instance.id,
  'word_id': instance.wordId,
  'char_text': instance.charText,
  'pinyin': instance.pinyin,
  'position': instance.position,
};
