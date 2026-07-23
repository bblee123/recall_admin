// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'word_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WordState {

 bool get loading; List<Word> get items; int get total; int get page; int get pageSize; int get searchType; String get searchText; String? get error;
/// Create a copy of WordState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WordStateCopyWith<WordState> get copyWith => _$WordStateCopyWithImpl<WordState>(this as WordState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WordState&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.searchType, searchType) || other.searchType == searchType)&&(identical(other.searchText, searchText) || other.searchText == searchText)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,loading,const DeepCollectionEquality().hash(items),total,page,pageSize,searchType,searchText,error);

@override
String toString() {
  return 'WordState(loading: $loading, items: $items, total: $total, page: $page, pageSize: $pageSize, searchType: $searchType, searchText: $searchText, error: $error)';
}


}

/// @nodoc
abstract mixin class $WordStateCopyWith<$Res>  {
  factory $WordStateCopyWith(WordState value, $Res Function(WordState) _then) = _$WordStateCopyWithImpl;
@useResult
$Res call({
 bool loading, List<Word> items, int total, int page, int pageSize, int searchType, String searchText, String? error
});




}
/// @nodoc
class _$WordStateCopyWithImpl<$Res>
    implements $WordStateCopyWith<$Res> {
  _$WordStateCopyWithImpl(this._self, this._then);

  final WordState _self;
  final $Res Function(WordState) _then;

/// Create a copy of WordState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = null,Object? items = null,Object? total = null,Object? page = null,Object? pageSize = null,Object? searchType = null,Object? searchText = null,Object? error = freezed,}) {
  return _then(WordState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Word>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,searchType: null == searchType ? _self.searchType : searchType // ignore: cast_nullable_to_non_nullable
as int,searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WordState].
extension WordStatePatterns on WordState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WordState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WordState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WordState value)  $default,){
final _that = this;
switch (_that) {
case _WordState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WordState value)?  $default,){
final _that = this;
switch (_that) {
case _WordState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool loading,  List<Word> items,  int total,  int page,  int pageSize,  int searchType,  String searchText,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WordState() when $default != null:
return $default(_that.loading,_that.items,_that.total,_that.page,_that.pageSize,_that.searchType,_that.searchText,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool loading,  List<Word> items,  int total,  int page,  int pageSize,  int searchType,  String searchText,  String? error)  $default,) {final _that = this;
switch (_that) {
case _WordState():
return $default(_that.loading,_that.items,_that.total,_that.page,_that.pageSize,_that.searchType,_that.searchText,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool loading,  List<Word> items,  int total,  int page,  int pageSize,  int searchType,  String searchText,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _WordState() when $default != null:
return $default(_that.loading,_that.items,_that.total,_that.page,_that.pageSize,_that.searchType,_that.searchText,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _WordState implements WordState {
  const _WordState({this.loading = true,  List<Word> items = const <Word>[], this.total = 0, this.page = 1, this.pageSize = 20, this.searchType = 1, this.searchText = '', this.error}): _items = items;
  

@override@JsonKey() final  bool loading;
 final  List<Word> _items;
@override@JsonKey() List<Word> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  int total;
@override@JsonKey() final  int page;
@override@JsonKey() final  int pageSize;
@override@JsonKey() final  int searchType;
@override@JsonKey() final  String searchText;
@override final  String? error;

/// Create a copy of WordState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WordStateCopyWith<_WordState> get copyWith => __$WordStateCopyWithImpl<_WordState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WordState&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.searchType, searchType) || other.searchType == searchType)&&(identical(other.searchText, searchText) || other.searchText == searchText)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,loading,const DeepCollectionEquality().hash(_items),total,page,pageSize,searchType,searchText,error);

@override
String toString() {
  return 'WordState(loading: $loading, items: $items, total: $total, page: $page, pageSize: $pageSize, searchType: $searchType, searchText: $searchText, error: $error)';
}


}

/// @nodoc
abstract mixin class _$WordStateCopyWith<$Res> implements $WordStateCopyWith<$Res> {
  factory _$WordStateCopyWith(_WordState value, $Res Function(_WordState) _then) = __$WordStateCopyWithImpl;
@override @useResult
$Res call({
 bool loading, List<Word> items, int total, int page, int pageSize, int searchType, String searchText, String? error
});




}
/// @nodoc
class __$WordStateCopyWithImpl<$Res>
    implements _$WordStateCopyWith<$Res> {
  __$WordStateCopyWithImpl(this._self, this._then);

  final _WordState _self;
  final $Res Function(_WordState) _then;

/// Create a copy of WordState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = null,Object? items = null,Object? total = null,Object? page = null,Object? pageSize = null,Object? searchType = null,Object? searchText = null,Object? error = freezed,}) {
  return _then(_WordState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Word>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,searchType: null == searchType ? _self.searchType : searchType // ignore: cast_nullable_to_non_nullable
as int,searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
