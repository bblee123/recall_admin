// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeState {

 bool get loading; CharItem? get char; String? get error; bool get mergeMeanings; int? get activeVariantId;
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStateCopyWith<HomeState> get copyWith => _$HomeStateCopyWithImpl<HomeState>(this as HomeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.char, char) || other.char == char)&&(identical(other.error, error) || other.error == error)&&(identical(other.mergeMeanings, mergeMeanings) || other.mergeMeanings == mergeMeanings)&&(identical(other.activeVariantId, activeVariantId) || other.activeVariantId == activeVariantId));
}


@override
int get hashCode => Object.hash(runtimeType,loading,char,error,mergeMeanings,activeVariantId);

@override
String toString() {
  return 'HomeState(loading: $loading, char: $char, error: $error, mergeMeanings: $mergeMeanings, activeVariantId: $activeVariantId)';
}


}

/// @nodoc
abstract mixin class $HomeStateCopyWith<$Res>  {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) _then) = _$HomeStateCopyWithImpl;
@useResult
$Res call({
 bool loading, CharItem? char, String? error, bool mergeMeanings, int? activeVariantId
});




}
/// @nodoc
class _$HomeStateCopyWithImpl<$Res>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._self, this._then);

  final HomeState _self;
  final $Res Function(HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = null,Object? char = freezed,Object? error = freezed,Object? mergeMeanings = null,Object? activeVariantId = freezed,}) {
  return _then(HomeState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,char: freezed == char ? _self.char : char // ignore: cast_nullable_to_non_nullable
as CharItem?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,mergeMeanings: null == mergeMeanings ? _self.mergeMeanings : mergeMeanings // ignore: cast_nullable_to_non_nullable
as bool,activeVariantId: freezed == activeVariantId ? _self.activeVariantId : activeVariantId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeState value)  $default,){
final _that = this;
switch (_that) {
case _HomeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeState value)?  $default,){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool loading,  CharItem? char,  String? error,  bool mergeMeanings,  int? activeVariantId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.loading,_that.char,_that.error,_that.mergeMeanings,_that.activeVariantId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool loading,  CharItem? char,  String? error,  bool mergeMeanings,  int? activeVariantId)  $default,) {final _that = this;
switch (_that) {
case _HomeState():
return $default(_that.loading,_that.char,_that.error,_that.mergeMeanings,_that.activeVariantId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool loading,  CharItem? char,  String? error,  bool mergeMeanings,  int? activeVariantId)?  $default,) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.loading,_that.char,_that.error,_that.mergeMeanings,_that.activeVariantId);case _:
  return null;

}
}

}

/// @nodoc


class _HomeState implements HomeState {
  const _HomeState({this.loading = false, this.char, this.error, this.mergeMeanings = false, this.activeVariantId});
  

@override@JsonKey() final  bool loading;
@override final  CharItem? char;
@override final  String? error;
@override@JsonKey() final  bool mergeMeanings;
@override final  int? activeVariantId;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStateCopyWith<_HomeState> get copyWith => __$HomeStateCopyWithImpl<_HomeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeState&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.char, char) || other.char == char)&&(identical(other.error, error) || other.error == error)&&(identical(other.mergeMeanings, mergeMeanings) || other.mergeMeanings == mergeMeanings)&&(identical(other.activeVariantId, activeVariantId) || other.activeVariantId == activeVariantId));
}


@override
int get hashCode => Object.hash(runtimeType,loading,char,error,mergeMeanings,activeVariantId);

@override
String toString() {
  return 'HomeState(loading: $loading, char: $char, error: $error, mergeMeanings: $mergeMeanings, activeVariantId: $activeVariantId)';
}


}

/// @nodoc
abstract mixin class _$HomeStateCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$HomeStateCopyWith(_HomeState value, $Res Function(_HomeState) _then) = __$HomeStateCopyWithImpl;
@override @useResult
$Res call({
 bool loading, CharItem? char, String? error, bool mergeMeanings, int? activeVariantId
});




}
/// @nodoc
class __$HomeStateCopyWithImpl<$Res>
    implements _$HomeStateCopyWith<$Res> {
  __$HomeStateCopyWithImpl(this._self, this._then);

  final _HomeState _self;
  final $Res Function(_HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = null,Object? char = freezed,Object? error = freezed,Object? mergeMeanings = null,Object? activeVariantId = freezed,}) {
  return _then(_HomeState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,char: freezed == char ? _self.char : char // ignore: cast_nullable_to_non_nullable
as CharItem?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,mergeMeanings: null == mergeMeanings ? _self.mergeMeanings : mergeMeanings // ignore: cast_nullable_to_non_nullable
as bool,activeVariantId: freezed == activeVariantId ? _self.activeVariantId : activeVariantId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
