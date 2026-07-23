// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Word _$WordFromJson(Map<String, dynamic> json) => Word(
  id: (json['id'] as num?)?.toInt(),
  text: json['text'] as String,
  pinyin: json['pinyin'] as String?,
  pinyinRaw: json['pinyin_raw'] as String?,
  translation: json['translation'] as String?,
  hasPolyphone: (json['has_polyphone'] as num?)?.toInt() ?? 0,
  charMetas:
      (json['charMetas'] as List<dynamic>?)
          ?.map((e) => CharMeta.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CharMeta>[],
  selectWords: (json['selectWords'] as List<dynamic>?)
      ?.map((e) => Word.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$WordToJson(Word instance) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'pinyin': instance.pinyin,
  'pinyin_raw': instance.pinyinRaw,
  'translation': instance.translation,
  'has_polyphone': instance.hasPolyphone,
  'charMetas': instance.charMetas.map((e) => e.toJson()).toList(),
  'selectWords': instance.selectWords?.map((e) => e.toJson()).toList(),
};

WordListResponse _$WordListResponseFromJson(Map<String, dynamic> json) =>
    WordListResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => Word.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Word>[],
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$WordListResponseToJson(WordListResponse instance) =>
    <String, dynamic>{
      'data': instance.data.map((e) => e.toJson()).toList(),
      'total': instance.total,
      'page': instance.page,
      'last_page': instance.lastPage,
    };
