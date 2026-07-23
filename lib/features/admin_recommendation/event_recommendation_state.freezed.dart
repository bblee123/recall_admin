// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_recommendation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EventRecommendationState {

 bool get loading; List<EventRecommendation> get items; String get searchWord; String? get error;
/// Create a copy of EventRecommendationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventRecommendationStateCopyWith<EventRecommendationState> get copyWith => _$EventRecommendationStateCopyWithImpl<EventRecommendationState>(this as EventRecommendationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventRecommendationState&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.searchWord, searchWord) || other.searchWord == searchWord)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,loading,const DeepCollectionEquality().hash(items),searchWord,error);

@override
String toString() {
  return 'EventRecommendationState(loading: $loading, items: $items, searchWord: $searchWord, error: $error)';
}


}

/// @nodoc
abstract mixin class $EventRecommendationStateCopyWith<$Res>  {
  factory $EventRecommendationStateCopyWith(EventRecommendationState value, $Res Function(EventRecommendationState) _then) = _$EventRecommendationStateCopyWithImpl;
@useResult
$Res call({
 bool loading, List<EventRecommendation> items, String searchWord, String? error
});




}
/// @nodoc
class _$EventRecommendationStateCopyWithImpl<$Res>
    implements $EventRecommendationStateCopyWith<$Res> {
  _$EventRecommendationStateCopyWithImpl(this._self, this._then);

  final EventRecommendationState _self;
  final $Res Function(EventRecommendationState) _then;

/// Create a copy of EventRecommendationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = null,Object? items = null,Object? searchWord = null,Object? error = freezed,}) {
  return _then(EventRecommendationState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<EventRecommendation>,searchWord: null == searchWord ? _self.searchWord : searchWord // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventRecommendationState].
extension EventRecommendationStatePatterns on EventRecommendationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventRecommendationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventRecommendationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventRecommendationState value)  $default,){
final _that = this;
switch (_that) {
case _EventRecommendationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventRecommendationState value)?  $default,){
final _that = this;
switch (_that) {
case _EventRecommendationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool loading,  List<EventRecommendation> items,  String searchWord,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventRecommendationState() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool loading,  List<EventRecommendation> items,  String searchWord,  String? error)  $default,) {final _that = this;
switch (_that) {
case _EventRecommendationState():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool loading,  List<EventRecommendation> items,  String searchWord,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _EventRecommendationState() when $default != null:
return $default(_that.loading,_that.items,_that.searchWord,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _EventRecommendationState implements EventRecommendationState {
  const _EventRecommendationState({this.loading = true,  List<EventRecommendation> items = const <EventRecommendation>[], this.searchWord = '', this.error}): _items = items;
  

@override@JsonKey() final  bool loading;
 final  List<EventRecommendation> _items;
@override@JsonKey() List<EventRecommendation> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  String searchWord;
@override final  String? error;

/// Create a copy of EventRecommendationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventRecommendationStateCopyWith<_EventRecommendationState> get copyWith => __$EventRecommendationStateCopyWithImpl<_EventRecommendationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventRecommendationState&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.searchWord, searchWord) || other.searchWord == searchWord)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,loading,const DeepCollectionEquality().hash(_items),searchWord,error);

@override
String toString() {
  return 'EventRecommendationState(loading: $loading, items: $items, searchWord: $searchWord, error: $error)';
}


}

/// @nodoc
abstract mixin class _$EventRecommendationStateCopyWith<$Res> implements $EventRecommendationStateCopyWith<$Res> {
  factory _$EventRecommendationStateCopyWith(_EventRecommendationState value, $Res Function(_EventRecommendationState) _then) = __$EventRecommendationStateCopyWithImpl;
@override @useResult
$Res call({
 bool loading, List<EventRecommendation> items, String searchWord, String? error
});




}
/// @nodoc
class __$EventRecommendationStateCopyWithImpl<$Res>
    implements _$EventRecommendationStateCopyWith<$Res> {
  __$EventRecommendationStateCopyWithImpl(this._self, this._then);

  final _EventRecommendationState _self;
  final $Res Function(_EventRecommendationState) _then;

/// Create a copy of EventRecommendationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = null,Object? items = null,Object? searchWord = null,Object? error = freezed,}) {
  return _then(_EventRecommendationState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<EventRecommendation>,searchWord: null == searchWord ? _self.searchWord : searchWord // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
