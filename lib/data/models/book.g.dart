// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookUnit _$BookUnitFromJson(Map<String, dynamic> json) => BookUnit(
  id: json['id'] as String?,
  title: json['title'] as String,
  description: json['description'] as String?,
  wordIds:
      (json['wordIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
  order: (json['order'] as num?)?.toInt() ?? 0,
  words: (json['words'] as List<dynamic>?)
      ?.map((e) => Word.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BookUnitToJson(BookUnit instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'wordIds': instance.wordIds,
  'order': instance.order,
  'words': instance.words?.map((e) => e.toJson()).toList(),
};

Book _$BookFromJson(Map<String, dynamic> json) => Book(
  id: json['id'] as String,
  title: json['title'] as String,
  subtitle: json['subtitle'] as String? ?? '',
  coverUrl: json['coverUrl'] as String? ?? '',
  isFree: json['isFree'] as bool? ?? false,
  wordCount: (json['wordCount'] as num?)?.toInt() ?? 0,
  units:
      (json['units'] as List<dynamic>?)
          ?.map((e) => BookUnit.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <BookUnit>[],
  order: (json['order'] as num?)?.toInt() ?? 0,
  category: json['category'] == null
      ? null
      : Category.fromJson(json['category'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'coverUrl': instance.coverUrl,
  'isFree': instance.isFree,
  'wordCount': instance.wordCount,
  'units': instance.units.map((e) => e.toJson()).toList(),
  'order': instance.order,
  'category': instance.category?.toJson(),
};
