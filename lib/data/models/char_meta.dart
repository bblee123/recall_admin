import 'package:json_annotation/json_annotation.dart';

part 'char_meta.g.dart';

/// 词中单字的拼音元数据（对照 wordType.d.ts CharMeta）。
@JsonSerializable()
class CharMeta {
  const CharMeta({
    this.id,
    this.wordId,
    required this.charText,
    required this.pinyin,
    required this.position,
  });

  final int? id;

  @JsonKey(name: 'word_id')
  final int? wordId;

  @JsonKey(name: 'char_text')
  final String charText;

  final String pinyin;

  final int position;

  factory CharMeta.fromJson(Map<String, dynamic> json) =>
      _$CharMetaFromJson(json);

  Map<String, dynamic> toJson() => _$CharMetaToJson(this);

  CharMeta copyWith({
    int? id,
    int? wordId,
    String? charText,
    String? pinyin,
    int? position,
  }) {
    return CharMeta(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      charText: charText ?? this.charText,
      pinyin: pinyin ?? this.pinyin,
      position: position ?? this.position,
    );
  }
}
