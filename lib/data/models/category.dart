import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

/// 书籍分类（对照 categorieType.d.ts Category）。
@JsonSerializable()
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.order = 0,
  });

  final String id;
  final String name;
  final String slug;
  final int order;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
