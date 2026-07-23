import 'package:json_annotation/json_annotation.dart';

part 'variant.g.dart';

/// 汉字释义实体（对照 variantType.d.ts Variant）。
@JsonSerializable()
class Variant {
  const Variant({
    this.id = 0,
    required this.charText,
    required this.pinyin,
    required this.meaning,
    this.samples,
    required this.pinyinRaw,
    this.encAudio = '',
  });

  final int id;

  @JsonKey(name: 'char_text')
  final String charText;

  final String pinyin;

  final String meaning;

  final String? samples;

  @JsonKey(name: 'pinyin_raw')
  final String pinyinRaw;

  @JsonKey(name: 'enc_audio')
  final String encAudio;

  bool get hasAudio => encAudio.isNotEmpty;

  factory Variant.fromJson(Map<String, dynamic> json) =>
      _$VariantFromJson(json);

  Map<String, dynamic> toJson() => _$VariantToJson(this);

  Variant copyWith({
    int? id,
    String? charText,
    String? pinyin,
    String? meaning,
    String? samples,
    String? pinyinRaw,
    String? encAudio,
  }) {
    return Variant(
      id: id ?? this.id,
      charText: charText ?? this.charText,
      pinyin: pinyin ?? this.pinyin,
      meaning: meaning ?? this.meaning,
      samples: samples ?? this.samples,
      pinyinRaw: pinyinRaw ?? this.pinyinRaw,
      encAudio: encAudio ?? this.encAudio,
    );
  }
}

/// 释义分页返回（对照 VariantListResponse）。
@JsonSerializable(explicitToJson: true)
class VariantListResponse {
  const VariantListResponse({
    this.data = const <Variant>[],
    this.total = 0,
    this.page = 1,
    this.lastPage = 1,
  });

  final List<Variant> data;
  final int total;
  final int page;

  @JsonKey(name: 'last_page')
  final int lastPage;

  factory VariantListResponse.fromJson(Map<String, dynamic> json) =>
      _$VariantListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VariantListResponseToJson(this);
}

/// AI 生成音频请求（对照 GenerateAudioRequest）。
@JsonSerializable()
class GenerateAudioRequest {
  const GenerateAudioRequest({
    required this.text,
    required this.variantId,
    required this.fileName,
    required this.pinyinRaw,
  });

  final String text;
  final int variantId;
  final String fileName;
  final String pinyinRaw;

  factory GenerateAudioRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateAudioRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateAudioRequestToJson(this);
}
