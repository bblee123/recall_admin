// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Variant _$VariantFromJson(Map<String, dynamic> json) => Variant(
  id: (json['id'] as num?)?.toInt() ?? 0,
  charText: json['char_text'] as String,
  pinyin: json['pinyin'] as String,
  meaning: json['meaning'] as String,
  samples: json['samples'] as String?,
  pinyinRaw: json['pinyin_raw'] as String,
  encAudio: json['enc_audio'] as String? ?? '',
);

Map<String, dynamic> _$VariantToJson(Variant instance) => <String, dynamic>{
  'id': instance.id,
  'char_text': instance.charText,
  'pinyin': instance.pinyin,
  'meaning': instance.meaning,
  'samples': instance.samples,
  'pinyin_raw': instance.pinyinRaw,
  'enc_audio': instance.encAudio,
};

VariantListResponse _$VariantListResponseFromJson(Map<String, dynamic> json) =>
    VariantListResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => Variant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Variant>[],
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$VariantListResponseToJson(
  VariantListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'total': instance.total,
  'page': instance.page,
  'last_page': instance.lastPage,
};

GenerateAudioRequest _$GenerateAudioRequestFromJson(
  Map<String, dynamic> json,
) => GenerateAudioRequest(
  text: json['text'] as String,
  variantId: (json['variantId'] as num).toInt(),
  fileName: json['fileName'] as String,
  pinyinRaw: json['pinyinRaw'] as String,
);

Map<String, dynamic> _$GenerateAudioRequestToJson(
  GenerateAudioRequest instance,
) => <String, dynamic>{
  'text': instance.text,
  'variantId': instance.variantId,
  'fileName': instance.fileName,
  'pinyinRaw': instance.pinyinRaw,
};
