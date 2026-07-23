import 'package:json_annotation/json_annotation.dart';

import 'category.dart';
import 'word.dart';

part 'book.g.dart';

/// 书籍单元（对照 bookType.d.ts BookUnit）。
@JsonSerializable(explicitToJson: true)
class BookUnit {
  const BookUnit({
    this.id,
    required this.title,
    this.description,
    this.wordIds = const <int>[],
    this.order = 0,
    this.words,
  });

  final String? id;
  final String title;
  final String? description;
  final List<int> wordIds;
  final int order;
  final List<Word>? words;

  factory BookUnit.fromJson(Map<String, dynamic> json) =>
      _$BookUnitFromJson(json);

  Map<String, dynamic> toJson() => _$BookUnitToJson(this);

  BookUnit copyWith({
    String? id,
    String? title,
    String? description,
    List<int>? wordIds,
    int? order,
    List<Word>? words,
  }) {
    return BookUnit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      wordIds: wordIds ?? this.wordIds,
      order: order ?? this.order,
      words: words ?? this.words,
    );
  }
}

/// 书籍实体（对照 bookType.d.ts Book）。
@JsonSerializable(explicitToJson: true)
class Book {
  const Book({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.coverUrl = '',
    this.isFree = false,
    this.wordCount = 0,
    this.units = const <BookUnit>[],
    this.order = 0,
    this.category,
  });

  final String id;
  final String title;
  final String subtitle;
  final String coverUrl;
  final bool isFree;
  final int wordCount;
  final List<BookUnit> units;
  final int order;
  final Category? category;

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

  Map<String, dynamic> toJson() => _$BookToJson(this);
}
