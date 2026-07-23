// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'books_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BooksState {

 bool get loading; List<Category> get categories; String get categoryId; List<Book> get books; String? get error;
/// Create a copy of BooksState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BooksStateCopyWith<BooksState> get copyWith => _$BooksStateCopyWithImpl<BooksState>(this as BooksState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BooksState&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other.categories, categories)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&const DeepCollectionEquality().equals(other.books, books)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,loading,const DeepCollectionEquality().hash(categories),categoryId,const DeepCollectionEquality().hash(books),error);

@override
String toString() {
  return 'BooksState(loading: $loading, categories: $categories, categoryId: $categoryId, books: $books, error: $error)';
}


}

/// @nodoc
abstract mixin class $BooksStateCopyWith<$Res>  {
  factory $BooksStateCopyWith(BooksState value, $Res Function(BooksState) _then) = _$BooksStateCopyWithImpl;
@useResult
$Res call({
 bool loading, List<Category> categories, String categoryId, List<Book> books, String? error
});




}
/// @nodoc
class _$BooksStateCopyWithImpl<$Res>
    implements $BooksStateCopyWith<$Res> {
  _$BooksStateCopyWithImpl(this._self, this._then);

  final BooksState _self;
  final $Res Function(BooksState) _then;

/// Create a copy of BooksState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = null,Object? categories = null,Object? categoryId = null,Object? books = null,Object? error = freezed,}) {
  return _then(BooksState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<Category>,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,books: null == books ? _self.books : books // ignore: cast_nullable_to_non_nullable
as List<Book>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BooksState].
extension BooksStatePatterns on BooksState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BooksState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BooksState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BooksState value)  $default,){
final _that = this;
switch (_that) {
case _BooksState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BooksState value)?  $default,){
final _that = this;
switch (_that) {
case _BooksState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool loading,  List<Category> categories,  String categoryId,  List<Book> books,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BooksState() when $default != null:
return $default(_that.loading,_that.categories,_that.categoryId,_that.books,_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool loading,  List<Category> categories,  String categoryId,  List<Book> books,  String? error)  $default,) {final _that = this;
switch (_that) {
case _BooksState():
return $default(_that.loading,_that.categories,_that.categoryId,_that.books,_that.error);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool loading,  List<Category> categories,  String categoryId,  List<Book> books,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _BooksState() when $default != null:
return $default(_that.loading,_that.categories,_that.categoryId,_that.books,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _BooksState implements BooksState {
  const _BooksState({this.loading = true,  List<Category> categories = const <Category>[], this.categoryId = '',  List<Book> books = const <Book>[], this.error}): _categories = categories,_books = books;
  

@override@JsonKey() final  bool loading;
 final  List<Category> _categories;
@override@JsonKey() List<Category> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

@override@JsonKey() final  String categoryId;
 final  List<Book> _books;
@override@JsonKey() List<Book> get books {
  if (_books is EqualUnmodifiableListView) return _books;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_books);
}

@override final  String? error;

/// Create a copy of BooksState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BooksStateCopyWith<_BooksState> get copyWith => __$BooksStateCopyWithImpl<_BooksState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BooksState&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other._categories, _categories)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&const DeepCollectionEquality().equals(other._books, _books)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,loading,const DeepCollectionEquality().hash(_categories),categoryId,const DeepCollectionEquality().hash(_books),error);

@override
String toString() {
  return 'BooksState(loading: $loading, categories: $categories, categoryId: $categoryId, books: $books, error: $error)';
}


}

/// @nodoc
abstract mixin class _$BooksStateCopyWith<$Res> implements $BooksStateCopyWith<$Res> {
  factory _$BooksStateCopyWith(_BooksState value, $Res Function(_BooksState) _then) = __$BooksStateCopyWithImpl;
@override @useResult
$Res call({
 bool loading, List<Category> categories, String categoryId, List<Book> books, String? error
});




}
/// @nodoc
class __$BooksStateCopyWithImpl<$Res>
    implements _$BooksStateCopyWith<$Res> {
  __$BooksStateCopyWithImpl(this._self, this._then);

  final _BooksState _self;
  final $Res Function(_BooksState) _then;

/// Create a copy of BooksState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = null,Object? categories = null,Object? categoryId = null,Object? books = null,Object? error = freezed,}) {
  return _then(_BooksState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<Category>,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,books: null == books ? _self._books : books // ignore: cast_nullable_to_non_nullable
as List<Book>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
