// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recorder_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecorderState {

 RecorderStatus get status; RecorderOptions get options; List<InputDevice> get devices;/// 已录制时长。
 Duration get elapsed;/// 波形振幅历史（0..1，归一化后的当前电平序列）。
 List<double> get amplitudes;/// 硬件实际生效的采样率（由 setOnConfigChanged 回报）。
 int? get effectiveSampleRate;/// 正在录制的临时文件路径。
 String? get tempPath;/// 保存后的最终路径 / URL。
 String? get savedPath;/// 是否有麦克风权限（null 表示尚未检查）。
 bool? get hasPermission;/// 是否正忙（保存中等）。
 bool get busy;/// 预览播放阶段。
 PlaybackStatus get playback;/// 预览播放当前位置。
 Duration get playbackPosition;/// 预览录音总时长。
 Duration get playbackDuration; String? get error;
/// Create a copy of RecorderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecorderStateCopyWith<RecorderState> get copyWith => _$RecorderStateCopyWithImpl<RecorderState>(this as RecorderState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecorderState&&(identical(other.status, status) || other.status == status)&&(identical(other.options, options) || other.options == options)&&const DeepCollectionEquality().equals(other.devices, devices)&&(identical(other.elapsed, elapsed) || other.elapsed == elapsed)&&const DeepCollectionEquality().equals(other.amplitudes, amplitudes)&&(identical(other.effectiveSampleRate, effectiveSampleRate) || other.effectiveSampleRate == effectiveSampleRate)&&(identical(other.tempPath, tempPath) || other.tempPath == tempPath)&&(identical(other.savedPath, savedPath) || other.savedPath == savedPath)&&(identical(other.hasPermission, hasPermission) || other.hasPermission == hasPermission)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.playback, playback) || other.playback == playback)&&(identical(other.playbackPosition, playbackPosition) || other.playbackPosition == playbackPosition)&&(identical(other.playbackDuration, playbackDuration) || other.playbackDuration == playbackDuration)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,options,const DeepCollectionEquality().hash(devices),elapsed,const DeepCollectionEquality().hash(amplitudes),effectiveSampleRate,tempPath,savedPath,hasPermission,busy,playback,playbackPosition,playbackDuration,error);

@override
String toString() {
  return 'RecorderState(status: $status, options: $options, devices: $devices, elapsed: $elapsed, amplitudes: $amplitudes, effectiveSampleRate: $effectiveSampleRate, tempPath: $tempPath, savedPath: $savedPath, hasPermission: $hasPermission, busy: $busy, playback: $playback, playbackPosition: $playbackPosition, playbackDuration: $playbackDuration, error: $error)';
}


}

/// @nodoc
abstract mixin class $RecorderStateCopyWith<$Res>  {
  factory $RecorderStateCopyWith(RecorderState value, $Res Function(RecorderState) _then) = _$RecorderStateCopyWithImpl;
@useResult
$Res call({
 RecorderStatus status, RecorderOptions options, List<InputDevice> devices, Duration elapsed, List<double> amplitudes, int? effectiveSampleRate, String? tempPath, String? savedPath, bool? hasPermission, bool busy, PlaybackStatus playback, Duration playbackPosition, Duration playbackDuration, String? error
});




}
/// @nodoc
class _$RecorderStateCopyWithImpl<$Res>
    implements $RecorderStateCopyWith<$Res> {
  _$RecorderStateCopyWithImpl(this._self, this._then);

  final RecorderState _self;
  final $Res Function(RecorderState) _then;

/// Create a copy of RecorderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? options = null,Object? devices = null,Object? elapsed = null,Object? amplitudes = null,Object? effectiveSampleRate = freezed,Object? tempPath = freezed,Object? savedPath = freezed,Object? hasPermission = freezed,Object? busy = null,Object? playback = null,Object? playbackPosition = null,Object? playbackDuration = null,Object? error = freezed,}) {
  return _then(RecorderState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecorderStatus,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as RecorderOptions,devices: null == devices ? _self.devices : devices // ignore: cast_nullable_to_non_nullable
as List<InputDevice>,elapsed: null == elapsed ? _self.elapsed : elapsed // ignore: cast_nullable_to_non_nullable
as Duration,amplitudes: null == amplitudes ? _self.amplitudes : amplitudes // ignore: cast_nullable_to_non_nullable
as List<double>,effectiveSampleRate: freezed == effectiveSampleRate ? _self.effectiveSampleRate : effectiveSampleRate // ignore: cast_nullable_to_non_nullable
as int?,tempPath: freezed == tempPath ? _self.tempPath : tempPath // ignore: cast_nullable_to_non_nullable
as String?,savedPath: freezed == savedPath ? _self.savedPath : savedPath // ignore: cast_nullable_to_non_nullable
as String?,hasPermission: freezed == hasPermission ? _self.hasPermission : hasPermission // ignore: cast_nullable_to_non_nullable
as bool?,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,playback: null == playback ? _self.playback : playback // ignore: cast_nullable_to_non_nullable
as PlaybackStatus,playbackPosition: null == playbackPosition ? _self.playbackPosition : playbackPosition // ignore: cast_nullable_to_non_nullable
as Duration,playbackDuration: null == playbackDuration ? _self.playbackDuration : playbackDuration // ignore: cast_nullable_to_non_nullable
as Duration,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecorderState].
extension RecorderStatePatterns on RecorderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecorderState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecorderState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecorderState value)  $default,){
final _that = this;
switch (_that) {
case _RecorderState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecorderState value)?  $default,){
final _that = this;
switch (_that) {
case _RecorderState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RecorderStatus status,  RecorderOptions options,  List<InputDevice> devices,  Duration elapsed,  List<double> amplitudes,  int? effectiveSampleRate,  String? tempPath,  String? savedPath,  bool? hasPermission,  bool busy,  PlaybackStatus playback,  Duration playbackPosition,  Duration playbackDuration,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecorderState() when $default != null:
return $default(_that.status,_that.options,_that.devices,_that.elapsed,_that.amplitudes,_that.effectiveSampleRate,_that.tempPath,_that.savedPath,_that.hasPermission,_that.busy,_that.playback,_that.playbackPosition,_that.playbackDuration,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RecorderStatus status,  RecorderOptions options,  List<InputDevice> devices,  Duration elapsed,  List<double> amplitudes,  int? effectiveSampleRate,  String? tempPath,  String? savedPath,  bool? hasPermission,  bool busy,  PlaybackStatus playback,  Duration playbackPosition,  Duration playbackDuration,  String? error)  $default,) {final _that = this;
switch (_that) {
case _RecorderState():
return $default(_that.status,_that.options,_that.devices,_that.elapsed,_that.amplitudes,_that.effectiveSampleRate,_that.tempPath,_that.savedPath,_that.hasPermission,_that.busy,_that.playback,_that.playbackPosition,_that.playbackDuration,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RecorderStatus status,  RecorderOptions options,  List<InputDevice> devices,  Duration elapsed,  List<double> amplitudes,  int? effectiveSampleRate,  String? tempPath,  String? savedPath,  bool? hasPermission,  bool busy,  PlaybackStatus playback,  Duration playbackPosition,  Duration playbackDuration,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _RecorderState() when $default != null:
return $default(_that.status,_that.options,_that.devices,_that.elapsed,_that.amplitudes,_that.effectiveSampleRate,_that.tempPath,_that.savedPath,_that.hasPermission,_that.busy,_that.playback,_that.playbackPosition,_that.playbackDuration,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _RecorderState extends RecorderState {
  const _RecorderState({this.status = RecorderStatus.idle, this.options = const RecorderOptions(),  List<InputDevice> devices = const <InputDevice>[], this.elapsed = Duration.zero,  List<double> amplitudes = const <double>[], this.effectiveSampleRate, this.tempPath, this.savedPath, this.hasPermission, this.busy = false, this.playback = PlaybackStatus.stopped, this.playbackPosition = Duration.zero, this.playbackDuration = Duration.zero, this.error}): _devices = devices,_amplitudes = amplitudes,super._();
  

@override@JsonKey() final  RecorderStatus status;
@override@JsonKey() final  RecorderOptions options;
 final  List<InputDevice> _devices;
@override@JsonKey() List<InputDevice> get devices {
  if (_devices is EqualUnmodifiableListView) return _devices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_devices);
}

/// 已录制时长。
@override@JsonKey() final  Duration elapsed;
/// 波形振幅历史（0..1，归一化后的当前电平序列）。
 final  List<double> _amplitudes;
/// 波形振幅历史（0..1，归一化后的当前电平序列）。
@override@JsonKey() List<double> get amplitudes {
  if (_amplitudes is EqualUnmodifiableListView) return _amplitudes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_amplitudes);
}

/// 硬件实际生效的采样率（由 setOnConfigChanged 回报）。
@override final  int? effectiveSampleRate;
/// 正在录制的临时文件路径。
@override final  String? tempPath;
/// 保存后的最终路径 / URL。
@override final  String? savedPath;
/// 是否有麦克风权限（null 表示尚未检查）。
@override final  bool? hasPermission;
/// 是否正忙（保存中等）。
@override@JsonKey() final  bool busy;
/// 预览播放阶段。
@override@JsonKey() final  PlaybackStatus playback;
/// 预览播放当前位置。
@override@JsonKey() final  Duration playbackPosition;
/// 预览录音总时长。
@override@JsonKey() final  Duration playbackDuration;
@override final  String? error;

/// Create a copy of RecorderState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecorderStateCopyWith<_RecorderState> get copyWith => __$RecorderStateCopyWithImpl<_RecorderState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecorderState&&(identical(other.status, status) || other.status == status)&&(identical(other.options, options) || other.options == options)&&const DeepCollectionEquality().equals(other._devices, _devices)&&(identical(other.elapsed, elapsed) || other.elapsed == elapsed)&&const DeepCollectionEquality().equals(other._amplitudes, _amplitudes)&&(identical(other.effectiveSampleRate, effectiveSampleRate) || other.effectiveSampleRate == effectiveSampleRate)&&(identical(other.tempPath, tempPath) || other.tempPath == tempPath)&&(identical(other.savedPath, savedPath) || other.savedPath == savedPath)&&(identical(other.hasPermission, hasPermission) || other.hasPermission == hasPermission)&&(identical(other.busy, busy) || other.busy == busy)&&(identical(other.playback, playback) || other.playback == playback)&&(identical(other.playbackPosition, playbackPosition) || other.playbackPosition == playbackPosition)&&(identical(other.playbackDuration, playbackDuration) || other.playbackDuration == playbackDuration)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,options,const DeepCollectionEquality().hash(_devices),elapsed,const DeepCollectionEquality().hash(_amplitudes),effectiveSampleRate,tempPath,savedPath,hasPermission,busy,playback,playbackPosition,playbackDuration,error);

@override
String toString() {
  return 'RecorderState(status: $status, options: $options, devices: $devices, elapsed: $elapsed, amplitudes: $amplitudes, effectiveSampleRate: $effectiveSampleRate, tempPath: $tempPath, savedPath: $savedPath, hasPermission: $hasPermission, busy: $busy, playback: $playback, playbackPosition: $playbackPosition, playbackDuration: $playbackDuration, error: $error)';
}


}

/// @nodoc
abstract mixin class _$RecorderStateCopyWith<$Res> implements $RecorderStateCopyWith<$Res> {
  factory _$RecorderStateCopyWith(_RecorderState value, $Res Function(_RecorderState) _then) = __$RecorderStateCopyWithImpl;
@override @useResult
$Res call({
 RecorderStatus status, RecorderOptions options, List<InputDevice> devices, Duration elapsed, List<double> amplitudes, int? effectiveSampleRate, String? tempPath, String? savedPath, bool? hasPermission, bool busy, PlaybackStatus playback, Duration playbackPosition, Duration playbackDuration, String? error
});




}
/// @nodoc
class __$RecorderStateCopyWithImpl<$Res>
    implements _$RecorderStateCopyWith<$Res> {
  __$RecorderStateCopyWithImpl(this._self, this._then);

  final _RecorderState _self;
  final $Res Function(_RecorderState) _then;

/// Create a copy of RecorderState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? options = null,Object? devices = null,Object? elapsed = null,Object? amplitudes = null,Object? effectiveSampleRate = freezed,Object? tempPath = freezed,Object? savedPath = freezed,Object? hasPermission = freezed,Object? busy = null,Object? playback = null,Object? playbackPosition = null,Object? playbackDuration = null,Object? error = freezed,}) {
  return _then(_RecorderState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RecorderStatus,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as RecorderOptions,devices: null == devices ? _self._devices : devices // ignore: cast_nullable_to_non_nullable
as List<InputDevice>,elapsed: null == elapsed ? _self.elapsed : elapsed // ignore: cast_nullable_to_non_nullable
as Duration,amplitudes: null == amplitudes ? _self._amplitudes : amplitudes // ignore: cast_nullable_to_non_nullable
as List<double>,effectiveSampleRate: freezed == effectiveSampleRate ? _self.effectiveSampleRate : effectiveSampleRate // ignore: cast_nullable_to_non_nullable
as int?,tempPath: freezed == tempPath ? _self.tempPath : tempPath // ignore: cast_nullable_to_non_nullable
as String?,savedPath: freezed == savedPath ? _self.savedPath : savedPath // ignore: cast_nullable_to_non_nullable
as String?,hasPermission: freezed == hasPermission ? _self.hasPermission : hasPermission // ignore: cast_nullable_to_non_nullable
as bool?,busy: null == busy ? _self.busy : busy // ignore: cast_nullable_to_non_nullable
as bool,playback: null == playback ? _self.playback : playback // ignore: cast_nullable_to_non_nullable
as PlaybackStatus,playbackPosition: null == playbackPosition ? _self.playbackPosition : playbackPosition // ignore: cast_nullable_to_non_nullable
as Duration,playbackDuration: null == playbackDuration ? _self.playbackDuration : playbackDuration // ignore: cast_nullable_to_non_nullable
as Duration,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
