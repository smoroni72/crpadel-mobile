// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'directory_player.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DirectoryPlayer {

 String get id; String get fullName;/// `member` (iscritto all'app) o `guest`.
 String? get registrationStatus;/// È l'utente stesso.
 bool get isSelf; String? get rankingBandName; String? get rankingBandColor;
/// Create a copy of DirectoryPlayer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DirectoryPlayerCopyWith<DirectoryPlayer> get copyWith => _$DirectoryPlayerCopyWithImpl<DirectoryPlayer>(this as DirectoryPlayer, _$identity);

  /// Serializes this DirectoryPlayer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DirectoryPlayer&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.registrationStatus, registrationStatus) || other.registrationStatus == registrationStatus)&&(identical(other.isSelf, isSelf) || other.isSelf == isSelf)&&(identical(other.rankingBandName, rankingBandName) || other.rankingBandName == rankingBandName)&&(identical(other.rankingBandColor, rankingBandColor) || other.rankingBandColor == rankingBandColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,registrationStatus,isSelf,rankingBandName,rankingBandColor);

@override
String toString() {
  return 'DirectoryPlayer(id: $id, fullName: $fullName, registrationStatus: $registrationStatus, isSelf: $isSelf, rankingBandName: $rankingBandName, rankingBandColor: $rankingBandColor)';
}


}

/// @nodoc
abstract mixin class $DirectoryPlayerCopyWith<$Res>  {
  factory $DirectoryPlayerCopyWith(DirectoryPlayer value, $Res Function(DirectoryPlayer) _then) = _$DirectoryPlayerCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, String? registrationStatus, bool isSelf, String? rankingBandName, String? rankingBandColor
});




}
/// @nodoc
class _$DirectoryPlayerCopyWithImpl<$Res>
    implements $DirectoryPlayerCopyWith<$Res> {
  _$DirectoryPlayerCopyWithImpl(this._self, this._then);

  final DirectoryPlayer _self;
  final $Res Function(DirectoryPlayer) _then;

/// Create a copy of DirectoryPlayer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? registrationStatus = freezed,Object? isSelf = null,Object? rankingBandName = freezed,Object? rankingBandColor = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,registrationStatus: freezed == registrationStatus ? _self.registrationStatus : registrationStatus // ignore: cast_nullable_to_non_nullable
as String?,isSelf: null == isSelf ? _self.isSelf : isSelf // ignore: cast_nullable_to_non_nullable
as bool,rankingBandName: freezed == rankingBandName ? _self.rankingBandName : rankingBandName // ignore: cast_nullable_to_non_nullable
as String?,rankingBandColor: freezed == rankingBandColor ? _self.rankingBandColor : rankingBandColor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DirectoryPlayer].
extension DirectoryPlayerPatterns on DirectoryPlayer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DirectoryPlayer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DirectoryPlayer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DirectoryPlayer value)  $default,){
final _that = this;
switch (_that) {
case _DirectoryPlayer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DirectoryPlayer value)?  $default,){
final _that = this;
switch (_that) {
case _DirectoryPlayer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  String? registrationStatus,  bool isSelf,  String? rankingBandName,  String? rankingBandColor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DirectoryPlayer() when $default != null:
return $default(_that.id,_that.fullName,_that.registrationStatus,_that.isSelf,_that.rankingBandName,_that.rankingBandColor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  String? registrationStatus,  bool isSelf,  String? rankingBandName,  String? rankingBandColor)  $default,) {final _that = this;
switch (_that) {
case _DirectoryPlayer():
return $default(_that.id,_that.fullName,_that.registrationStatus,_that.isSelf,_that.rankingBandName,_that.rankingBandColor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  String? registrationStatus,  bool isSelf,  String? rankingBandName,  String? rankingBandColor)?  $default,) {final _that = this;
switch (_that) {
case _DirectoryPlayer() when $default != null:
return $default(_that.id,_that.fullName,_that.registrationStatus,_that.isSelf,_that.rankingBandName,_that.rankingBandColor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DirectoryPlayer implements DirectoryPlayer {
  const _DirectoryPlayer({required this.id, required this.fullName, this.registrationStatus, this.isSelf = false, this.rankingBandName, this.rankingBandColor});
  factory _DirectoryPlayer.fromJson(Map<String, dynamic> json) => _$DirectoryPlayerFromJson(json);

@override final  String id;
@override final  String fullName;
/// `member` (iscritto all'app) o `guest`.
@override final  String? registrationStatus;
/// È l'utente stesso.
@override@JsonKey() final  bool isSelf;
@override final  String? rankingBandName;
@override final  String? rankingBandColor;

/// Create a copy of DirectoryPlayer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DirectoryPlayerCopyWith<_DirectoryPlayer> get copyWith => __$DirectoryPlayerCopyWithImpl<_DirectoryPlayer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DirectoryPlayerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DirectoryPlayer&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.registrationStatus, registrationStatus) || other.registrationStatus == registrationStatus)&&(identical(other.isSelf, isSelf) || other.isSelf == isSelf)&&(identical(other.rankingBandName, rankingBandName) || other.rankingBandName == rankingBandName)&&(identical(other.rankingBandColor, rankingBandColor) || other.rankingBandColor == rankingBandColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,registrationStatus,isSelf,rankingBandName,rankingBandColor);

@override
String toString() {
  return 'DirectoryPlayer(id: $id, fullName: $fullName, registrationStatus: $registrationStatus, isSelf: $isSelf, rankingBandName: $rankingBandName, rankingBandColor: $rankingBandColor)';
}


}

/// @nodoc
abstract mixin class _$DirectoryPlayerCopyWith<$Res> implements $DirectoryPlayerCopyWith<$Res> {
  factory _$DirectoryPlayerCopyWith(_DirectoryPlayer value, $Res Function(_DirectoryPlayer) _then) = __$DirectoryPlayerCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, String? registrationStatus, bool isSelf, String? rankingBandName, String? rankingBandColor
});




}
/// @nodoc
class __$DirectoryPlayerCopyWithImpl<$Res>
    implements _$DirectoryPlayerCopyWith<$Res> {
  __$DirectoryPlayerCopyWithImpl(this._self, this._then);

  final _DirectoryPlayer _self;
  final $Res Function(_DirectoryPlayer) _then;

/// Create a copy of DirectoryPlayer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? registrationStatus = freezed,Object? isSelf = null,Object? rankingBandName = freezed,Object? rankingBandColor = freezed,}) {
  return _then(_DirectoryPlayer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,registrationStatus: freezed == registrationStatus ? _self.registrationStatus : registrationStatus // ignore: cast_nullable_to_non_nullable
as String?,isSelf: null == isSelf ? _self.isSelf : isSelf // ignore: cast_nullable_to_non_nullable
as bool,rankingBandName: freezed == rankingBandName ? _self.rankingBandName : rankingBandName // ignore: cast_nullable_to_non_nullable
as String?,rankingBandColor: freezed == rankingBandColor ? _self.rankingBandColor : rankingBandColor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
