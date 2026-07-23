import 'package:json_annotation/json_annotation.dart';

import 'char_meta.dart';

part 'word.g.dart';

/// 词汇实体（对照 wordType.d.ts Word）。
@JsonSerializable(explicitToJson: true)
class Word {
  const Word({
    this.id,
    required this.text,
    this.pinyin,
    this.pinyinRaw,
    this.translation,
    this.hasPolyphone = 0,
    this.charMetas = const <CharMeta>[],
    this.selectWords,
  });

  final int? id;

  final String text;

  final String? pinyin;

  @JsonKey(name: 'pinyin_raw')
  final String? pinyinRaw;

  final String? translation;

  /// 0=否 1=是。
  @JsonKey(name: 'has_polyphone')
  final int hasPolyphone;

  final List<CharMeta> charMetas;

  final List<Word>? selectWords;

  bool get isPolyphone => hasPolyphone == 1;

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);

  Map<String, dynamic> toJson() => _$WordToJson(this);

  Word copyWith({
    int? id,
    String? text,
    String? pinyin,
    String? pinyinRaw,
    String? translation,
    int? hasPolyphone,
    List<CharMeta>? charMetas,
    List<Word>? selectWords,
  }) {
    return Word(
      id: id ?? this.id,
      text: text ?? this.text,
      pinyin: pinyin ?? this.pinyin,
      pinyinRaw: pinyinRaw ?? this.pinyinRaw,
      translation: translation ?? this.translation,
      hasPolyphone: hasPolyphone ?? this.hasPolyphone,
      charMetas: charMetas ?? this.charMetas,
      selectWords: selectWords ?? this.selectWords,
    );
  }
}

/// 词汇分页返回（对照 WordListResponse）。
@JsonSerializable(explicitToJson: true)
class WordListResponse {
  const WordListResponse({
    this.data = const <Word>[],
    this.total = 0,
    this.page = 1,
    this.lastPage = 1,
  });

  final List<Word> data;
  final int total;
  final int page;

  @JsonKey(name: 'last_page')
  final int lastPage;

  factory WordListResponse.fromJson(Map<String, dynamic> json) =>
      _$WordListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WordListResponseToJson(this);
}
