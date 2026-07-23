// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'base_recommendation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BaseRecommendationState {

 bool get loading; List<BaseRecommendation> get items; String get searchWord; String? get error;
/// Create a copy of BaseRecommendationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BaseRecommendationStateCopyWith<BaseRecommendationState> get copyWith => _$BaseRecommendationStateCopyWithImpl<BaseRecommendationState>(this as BaseRecommendationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BaseRecommendationState&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.searchWord, searchWord) || other.searchWord == searchWord)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,loading,const DeepCollectionEquality().hash(items),searchWord,error);

@override
String toString() {
  return 'BaseRecommendationState(loading: $loading, items: $items, searchWord: $searchWord, error: $error)';
}


}

/// @nodoc
abstract mixin class $BaseRecommendationStateCopyWith<$Res>  {
  factory $BaseRecommendationStateCopyWith(BaseRecommendationState value, $Res Function(BaseRecommendationState) _then) = _$BaseRecommendationStateCopyWithImpl;
@useResult
$Res call({
 bool loading, List<BaseRecommendation> items, String searchWord, String? error
});




}
/// @nodoc
class _$BaseRecommendationStateCopyWithImpl<$Res>
    implements $BaseRecommendationStateCopyWith<$Res> {
  _$BaseRecommendationStateCopyWithImpl(this._self, this._then);

  final BaseRecommendationState _self;
  final $Res Function(BaseRecommendationState) _then;

/// Create a copy of BaseRecommendationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = null,Object? items = null,Object? searchWord = null,Object? error = freezed,}) {
  return _then(BaseRecommendationState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<BaseRecommendation>,searchWord: null == searchWord ? _self.searchWord : searchWord // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BaseRecommendationState].
extension BaseRecommendationStatePatterns on BaseRecommendationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BaseRecommendationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BaseRecommendationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BaseRecommendationState value)  $default,){
final _that = this;
switch (_that) {
case _BaseRecommendationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BaseRecommendationState value)?  $default,){
final _that = this;
switch (_that) {
case _BaseRecommendationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool loading,  List<BaseRecommendation> items,  String searchWord,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BaseRecommendationState() when $default != null:
return $default(_that.loading,_that.items,_that.searchWord,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool loading,  List<BaseRecommendation> items,  String searchWord,  String? error)  $default,) {final _that = this;
switch (_that) {
case _BaseRecommendationState():
return $default(_that.loading,_that.items,_that.searchWord,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool loading,  List<BaseRecommendation> items,  String searchWord,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _BaseRecommendationState() when $default != null:
return $default(_that.loading,_that.items,_that.searchWord,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _BaseRecommendationState implements BaseRecommendationState {
  const _BaseRecommendationState({this.loading = true,  List<BaseRecommendation> items = const <BaseRecommendation>[], this.searchWord = '', this.error}): _items = items;
  

@override@JsonKey() final  bool loading;
 final  List<BaseRecommendation> _items;
@override@JsonKey() List<BaseRecommendation> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  String searchWord;
@override final  String? error;

/// Create a copy of BaseRecommendationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BaseRecommendationStateCopyWith<_BaseRecommendationState> get copyWith => __$BaseRecommendationStateCopyWithImpl<_BaseRecommendationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BaseRecommendationState&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.searchWord, searchWord) || other.searchWord == searchWord)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,loading,const DeepCollectionEquality().hash(_items),searchWord,error);

@override
String toString() {
  return 'BaseRecommendationState(loading: $loading, items: $items, searchWord: $searchWord, error: $error)';
}


}

/// @nodoc
abstract mixin class _$BaseRecommendationStateCopyWith<$Res> implements $BaseRecommendationStateCopyWith<$Res> {
  factory _$BaseRecommendationStateCopyWith(_BaseRecommendationState value, $Res Function(_BaseRecommendationState) _then) = __$BaseRecommendationStateCopyWithImpl;
@override @useResult
$Res call({
 bool loading, List<BaseRecommendation> items, String searchWord, String? error
});




}
/// @nodoc
class __$BaseRecommendationStateCopyWithImpl<$Res>
    implements _$BaseRecommendationStateCopyWith<$Res> {
  __$BaseRecommendationStateCopyWithImpl(this._self, this._then);

  final _BaseRecommendationState _self;
  final $Res Function(_BaseRecommendationState) _then;

/// Create a copy of BaseRecommendationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = null,Object? items = null,Object? searchWord = null,Object? error = freezed,}) {
  return _then(_BaseRecommendationState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<BaseRecommendation>,searchWord: null == searchWord ? _self.searchWord : searchWord // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
