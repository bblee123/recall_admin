// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'variant_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VariantState {

 bool get loading; List<Variant> get items; int get total; int get page; int get pageSize; int get audioType; String get searchText; Set<int> get selectedIds; String? get error;
/// Create a copy of VariantState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VariantStateCopyWith<VariantState> get copyWith => _$VariantStateCopyWithImpl<VariantState>(this as VariantState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VariantState&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.audioType, audioType) || other.audioType == audioType)&&(identical(other.searchText, searchText) || other.searchText == searchText)&&const DeepCollectionEquality().equals(other.selectedIds, selectedIds)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,loading,const DeepCollectionEquality().hash(items),total,page,pageSize,audioType,searchText,const DeepCollectionEquality().hash(selectedIds),error);

@override
String toString() {
  return 'VariantState(loading: $loading, items: $items, total: $total, page: $page, pageSize: $pageSize, audioType: $audioType, searchText: $searchText, selectedIds: $selectedIds, error: $error)';
}


}

/// @nodoc
abstract mixin class $VariantStateCopyWith<$Res>  {
  factory $VariantStateCopyWith(VariantState value, $Res Function(VariantState) _then) = _$VariantStateCopyWithImpl;
@useResult
$Res call({
 bool loading, List<Variant> items, int total, int page, int pageSize, int audioType, String searchText, Set<int> selectedIds, String? error
});




}
/// @nodoc
class _$VariantStateCopyWithImpl<$Res>
    implements $VariantStateCopyWith<$Res> {
  _$VariantStateCopyWithImpl(this._self, this._then);

  final VariantState _self;
  final $Res Function(VariantState) _then;

/// Create a copy of VariantState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loading = null,Object? items = null,Object? total = null,Object? page = null,Object? pageSize = null,Object? audioType = null,Object? searchText = null,Object? selectedIds = null,Object? error = freezed,}) {
  return _then(VariantState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Variant>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,audioType: null == audioType ? _self.audioType : audioType // ignore: cast_nullable_to_non_nullable
as int,searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,selectedIds: null == selectedIds ? _self.selectedIds : selectedIds // ignore: cast_nullable_to_non_nullable
as Set<int>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VariantState].
extension VariantStatePatterns on VariantState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VariantState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VariantState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VariantState value)  $default,){
final _that = this;
switch (_that) {
case _VariantState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VariantState value)?  $default,){
final _that = this;
switch (_that) {
case _VariantState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool loading,  List<Variant> items,  int total,  int page,  int pageSize,  int audioType,  String searchText,  Set<int> selectedIds,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VariantState() when $default != null:
return $default(_that.loading,_that.items,_that.total,_that.page,_that.pageSize,_that.audioType,_that.searchText,_that.selectedIds,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool loading,  List<Variant> items,  int total,  int page,  int pageSize,  int audioType,  String searchText,  Set<int> selectedIds,  String? error)  $default,) {final _that = this;
switch (_that) {
case _VariantState():
return $default(_that.loading,_that.items,_that.total,_that.page,_that.pageSize,_that.audioType,_that.searchText,_that.selectedIds,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool loading,  List<Variant> items,  int total,  int page,  int pageSize,  int audioType,  String searchText,  Set<int> selectedIds,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _VariantState() when $default != null:
return $default(_that.loading,_that.items,_that.total,_that.page,_that.pageSize,_that.audioType,_that.searchText,_that.selectedIds,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _VariantState implements VariantState {
  const _VariantState({this.loading = true,  List<Variant> items = const <Variant>[], this.total = 0, this.page = 1, this.pageSize = 100, this.audioType = 1, this.searchText = '',  Set<int> selectedIds = const <int>{}, this.error}): _items = items,_selectedIds = selectedIds;
  

@override@JsonKey() final  bool loading;
 final  List<Variant> _items;
@override@JsonKey() List<Variant> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  int total;
@override@JsonKey() final  int page;
@override@JsonKey() final  int pageSize;
@override@JsonKey() final  int audioType;
@override@JsonKey() final  String searchText;
 final  Set<int> _selectedIds;
@override@JsonKey() Set<int> get selectedIds {
  if (_selectedIds is EqualUnmodifiableSetView) return _selectedIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedIds);
}

@override final  String? error;

/// Create a copy of VariantState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VariantStateCopyWith<_VariantState> get copyWith => __$VariantStateCopyWithImpl<_VariantState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VariantState&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.audioType, audioType) || other.audioType == audioType)&&(identical(other.searchText, searchText) || other.searchText == searchText)&&const DeepCollectionEquality().equals(other._selectedIds, _selectedIds)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,loading,const DeepCollectionEquality().hash(_items),total,page,pageSize,audioType,searchText,const DeepCollectionEquality().hash(_selectedIds),error);

@override
String toString() {
  return 'VariantState(loading: $loading, items: $items, total: $total, page: $page, pageSize: $pageSize, audioType: $audioType, searchText: $searchText, selectedIds: $selectedIds, error: $error)';
}


}

/// @nodoc
abstract mixin class _$VariantStateCopyWith<$Res> implements $VariantStateCopyWith<$Res> {
  factory _$VariantStateCopyWith(_VariantState value, $Res Function(_VariantState) _then) = __$VariantStateCopyWithImpl;
@override @useResult
$Res call({
 bool loading, List<Variant> items, int total, int page, int pageSize, int audioType, String searchText, Set<int> selectedIds, String? error
});




}
/// @nodoc
class __$VariantStateCopyWithImpl<$Res>
    implements _$VariantStateCopyWith<$Res> {
  __$VariantStateCopyWithImpl(this._self, this._then);

  final _VariantState _self;
  final $Res Function(_VariantState) _then;

/// Create a copy of VariantState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loading = null,Object? items = null,Object? total = null,Object? page = null,Object? pageSize = null,Object? audioType = null,Object? searchText = null,Object? selectedIds = null,Object? error = freezed,}) {
  return _then(_VariantState(
loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Variant>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,audioType: null == audioType ? _self.audioType : audioType // ignore: cast_nullable_to_non_nullable
as int,searchText: null == searchText ? _self.searchText : searchText // ignore: cast_nullable_to_non_nullable
as String,selectedIds: null == selectedIds ? _self._selectedIds : selectedIds // ignore: cast_nullable_to_non_nullable
as Set<int>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
