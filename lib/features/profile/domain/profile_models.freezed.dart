// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlayerRanking {

/// Id utente, se registrato; altrimenti un altro riferimento stabile.
 String? get playerRef; String get playerName; int get position; String? get rankingBandName; String? get rankingBandColor; int get matchesPlayed; int get matchesWon;
/// Create a copy of PlayerRanking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerRankingCopyWith<PlayerRanking> get copyWith => _$PlayerRankingCopyWithImpl<PlayerRanking>(this as PlayerRanking, _$identity);

  /// Serializes this PlayerRanking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerRanking&&(identical(other.playerRef, playerRef) || other.playerRef == playerRef)&&(identical(other.playerName, playerName) || other.playerName == playerName)&&(identical(other.position, position) || other.position == position)&&(identical(other.rankingBandName, rankingBandName) || other.rankingBandName == rankingBandName)&&(identical(other.rankingBandColor, rankingBandColor) || other.rankingBandColor == rankingBandColor)&&(identical(other.matchesPlayed, matchesPlayed) || other.matchesPlayed == matchesPlayed)&&(identical(other.matchesWon, matchesWon) || other.matchesWon == matchesWon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playerRef,playerName,position,rankingBandName,rankingBandColor,matchesPlayed,matchesWon);

@override
String toString() {
  return 'PlayerRanking(playerRef: $playerRef, playerName: $playerName, position: $position, rankingBandName: $rankingBandName, rankingBandColor: $rankingBandColor, matchesPlayed: $matchesPlayed, matchesWon: $matchesWon)';
}


}

/// @nodoc
abstract mixin class $PlayerRankingCopyWith<$Res>  {
  factory $PlayerRankingCopyWith(PlayerRanking value, $Res Function(PlayerRanking) _then) = _$PlayerRankingCopyWithImpl;
@useResult
$Res call({
 String? playerRef, String playerName, int position, String? rankingBandName, String? rankingBandColor, int matchesPlayed, int matchesWon
});




}
/// @nodoc
class _$PlayerRankingCopyWithImpl<$Res>
    implements $PlayerRankingCopyWith<$Res> {
  _$PlayerRankingCopyWithImpl(this._self, this._then);

  final PlayerRanking _self;
  final $Res Function(PlayerRanking) _then;

/// Create a copy of PlayerRanking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playerRef = freezed,Object? playerName = null,Object? position = null,Object? rankingBandName = freezed,Object? rankingBandColor = freezed,Object? matchesPlayed = null,Object? matchesWon = null,}) {
  return _then(_self.copyWith(
playerRef: freezed == playerRef ? _self.playerRef : playerRef // ignore: cast_nullable_to_non_nullable
as String?,playerName: null == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,rankingBandName: freezed == rankingBandName ? _self.rankingBandName : rankingBandName // ignore: cast_nullable_to_non_nullable
as String?,rankingBandColor: freezed == rankingBandColor ? _self.rankingBandColor : rankingBandColor // ignore: cast_nullable_to_non_nullable
as String?,matchesPlayed: null == matchesPlayed ? _self.matchesPlayed : matchesPlayed // ignore: cast_nullable_to_non_nullable
as int,matchesWon: null == matchesWon ? _self.matchesWon : matchesWon // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerRanking].
extension PlayerRankingPatterns on PlayerRanking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerRanking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerRanking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerRanking value)  $default,){
final _that = this;
switch (_that) {
case _PlayerRanking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerRanking value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerRanking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? playerRef,  String playerName,  int position,  String? rankingBandName,  String? rankingBandColor,  int matchesPlayed,  int matchesWon)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerRanking() when $default != null:
return $default(_that.playerRef,_that.playerName,_that.position,_that.rankingBandName,_that.rankingBandColor,_that.matchesPlayed,_that.matchesWon);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? playerRef,  String playerName,  int position,  String? rankingBandName,  String? rankingBandColor,  int matchesPlayed,  int matchesWon)  $default,) {final _that = this;
switch (_that) {
case _PlayerRanking():
return $default(_that.playerRef,_that.playerName,_that.position,_that.rankingBandName,_that.rankingBandColor,_that.matchesPlayed,_that.matchesWon);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? playerRef,  String playerName,  int position,  String? rankingBandName,  String? rankingBandColor,  int matchesPlayed,  int matchesWon)?  $default,) {final _that = this;
switch (_that) {
case _PlayerRanking() when $default != null:
return $default(_that.playerRef,_that.playerName,_that.position,_that.rankingBandName,_that.rankingBandColor,_that.matchesPlayed,_that.matchesWon);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayerRanking implements PlayerRanking {
  const _PlayerRanking({this.playerRef, required this.playerName, this.position = 0, this.rankingBandName, this.rankingBandColor, this.matchesPlayed = 0, this.matchesWon = 0});
  factory _PlayerRanking.fromJson(Map<String, dynamic> json) => _$PlayerRankingFromJson(json);

/// Id utente, se registrato; altrimenti un altro riferimento stabile.
@override final  String? playerRef;
@override final  String playerName;
@override@JsonKey() final  int position;
@override final  String? rankingBandName;
@override final  String? rankingBandColor;
@override@JsonKey() final  int matchesPlayed;
@override@JsonKey() final  int matchesWon;

/// Create a copy of PlayerRanking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerRankingCopyWith<_PlayerRanking> get copyWith => __$PlayerRankingCopyWithImpl<_PlayerRanking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerRankingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerRanking&&(identical(other.playerRef, playerRef) || other.playerRef == playerRef)&&(identical(other.playerName, playerName) || other.playerName == playerName)&&(identical(other.position, position) || other.position == position)&&(identical(other.rankingBandName, rankingBandName) || other.rankingBandName == rankingBandName)&&(identical(other.rankingBandColor, rankingBandColor) || other.rankingBandColor == rankingBandColor)&&(identical(other.matchesPlayed, matchesPlayed) || other.matchesPlayed == matchesPlayed)&&(identical(other.matchesWon, matchesWon) || other.matchesWon == matchesWon));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playerRef,playerName,position,rankingBandName,rankingBandColor,matchesPlayed,matchesWon);

@override
String toString() {
  return 'PlayerRanking(playerRef: $playerRef, playerName: $playerName, position: $position, rankingBandName: $rankingBandName, rankingBandColor: $rankingBandColor, matchesPlayed: $matchesPlayed, matchesWon: $matchesWon)';
}


}

/// @nodoc
abstract mixin class _$PlayerRankingCopyWith<$Res> implements $PlayerRankingCopyWith<$Res> {
  factory _$PlayerRankingCopyWith(_PlayerRanking value, $Res Function(_PlayerRanking) _then) = __$PlayerRankingCopyWithImpl;
@override @useResult
$Res call({
 String? playerRef, String playerName, int position, String? rankingBandName, String? rankingBandColor, int matchesPlayed, int matchesWon
});




}
/// @nodoc
class __$PlayerRankingCopyWithImpl<$Res>
    implements _$PlayerRankingCopyWith<$Res> {
  __$PlayerRankingCopyWithImpl(this._self, this._then);

  final _PlayerRanking _self;
  final $Res Function(_PlayerRanking) _then;

/// Create a copy of PlayerRanking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playerRef = freezed,Object? playerName = null,Object? position = null,Object? rankingBandName = freezed,Object? rankingBandColor = freezed,Object? matchesPlayed = null,Object? matchesWon = null,}) {
  return _then(_PlayerRanking(
playerRef: freezed == playerRef ? _self.playerRef : playerRef // ignore: cast_nullable_to_non_nullable
as String?,playerName: null == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,rankingBandName: freezed == rankingBandName ? _self.rankingBandName : rankingBandName // ignore: cast_nullable_to_non_nullable
as String?,rankingBandColor: freezed == rankingBandColor ? _self.rankingBandColor : rankingBandColor // ignore: cast_nullable_to_non_nullable
as String?,matchesPlayed: null == matchesPlayed ? _self.matchesPlayed : matchesPlayed // ignore: cast_nullable_to_non_nullable
as int,matchesWon: null == matchesWon ? _self.matchesWon : matchesWon // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Lesson {

 String get id; String get coachName; DateTime get date; String get timeSlot;@JsonKey(unknownEnumValue: LessonStatus.unknown) LessonStatus get status;
/// Create a copy of Lesson
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LessonCopyWith<Lesson> get copyWith => _$LessonCopyWithImpl<Lesson>(this as Lesson, _$identity);

  /// Serializes this Lesson to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Lesson&&(identical(other.id, id) || other.id == id)&&(identical(other.coachName, coachName) || other.coachName == coachName)&&(identical(other.date, date) || other.date == date)&&(identical(other.timeSlot, timeSlot) || other.timeSlot == timeSlot)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,coachName,date,timeSlot,status);

@override
String toString() {
  return 'Lesson(id: $id, coachName: $coachName, date: $date, timeSlot: $timeSlot, status: $status)';
}


}

/// @nodoc
abstract mixin class $LessonCopyWith<$Res>  {
  factory $LessonCopyWith(Lesson value, $Res Function(Lesson) _then) = _$LessonCopyWithImpl;
@useResult
$Res call({
 String id, String coachName, DateTime date, String timeSlot,@JsonKey(unknownEnumValue: LessonStatus.unknown) LessonStatus status
});




}
/// @nodoc
class _$LessonCopyWithImpl<$Res>
    implements $LessonCopyWith<$Res> {
  _$LessonCopyWithImpl(this._self, this._then);

  final Lesson _self;
  final $Res Function(Lesson) _then;

/// Create a copy of Lesson
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? coachName = null,Object? date = null,Object? timeSlot = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,coachName: null == coachName ? _self.coachName : coachName // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,timeSlot: null == timeSlot ? _self.timeSlot : timeSlot // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LessonStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [Lesson].
extension LessonPatterns on Lesson {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Lesson value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Lesson() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Lesson value)  $default,){
final _that = this;
switch (_that) {
case _Lesson():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Lesson value)?  $default,){
final _that = this;
switch (_that) {
case _Lesson() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String coachName,  DateTime date,  String timeSlot, @JsonKey(unknownEnumValue: LessonStatus.unknown)  LessonStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Lesson() when $default != null:
return $default(_that.id,_that.coachName,_that.date,_that.timeSlot,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String coachName,  DateTime date,  String timeSlot, @JsonKey(unknownEnumValue: LessonStatus.unknown)  LessonStatus status)  $default,) {final _that = this;
switch (_that) {
case _Lesson():
return $default(_that.id,_that.coachName,_that.date,_that.timeSlot,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String coachName,  DateTime date,  String timeSlot, @JsonKey(unknownEnumValue: LessonStatus.unknown)  LessonStatus status)?  $default,) {final _that = this;
switch (_that) {
case _Lesson() when $default != null:
return $default(_that.id,_that.coachName,_that.date,_that.timeSlot,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Lesson implements Lesson {
  const _Lesson({required this.id, this.coachName = '', required this.date, this.timeSlot = '', @JsonKey(unknownEnumValue: LessonStatus.unknown) this.status = LessonStatus.unknown});
  factory _Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);

@override final  String id;
@override@JsonKey() final  String coachName;
@override final  DateTime date;
@override@JsonKey() final  String timeSlot;
@override@JsonKey(unknownEnumValue: LessonStatus.unknown) final  LessonStatus status;

/// Create a copy of Lesson
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LessonCopyWith<_Lesson> get copyWith => __$LessonCopyWithImpl<_Lesson>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LessonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Lesson&&(identical(other.id, id) || other.id == id)&&(identical(other.coachName, coachName) || other.coachName == coachName)&&(identical(other.date, date) || other.date == date)&&(identical(other.timeSlot, timeSlot) || other.timeSlot == timeSlot)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,coachName,date,timeSlot,status);

@override
String toString() {
  return 'Lesson(id: $id, coachName: $coachName, date: $date, timeSlot: $timeSlot, status: $status)';
}


}

/// @nodoc
abstract mixin class _$LessonCopyWith<$Res> implements $LessonCopyWith<$Res> {
  factory _$LessonCopyWith(_Lesson value, $Res Function(_Lesson) _then) = __$LessonCopyWithImpl;
@override @useResult
$Res call({
 String id, String coachName, DateTime date, String timeSlot,@JsonKey(unknownEnumValue: LessonStatus.unknown) LessonStatus status
});




}
/// @nodoc
class __$LessonCopyWithImpl<$Res>
    implements _$LessonCopyWith<$Res> {
  __$LessonCopyWithImpl(this._self, this._then);

  final _Lesson _self;
  final $Res Function(_Lesson) _then;

/// Create a copy of Lesson
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? coachName = null,Object? date = null,Object? timeSlot = null,Object? status = null,}) {
  return _then(_Lesson(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,coachName: null == coachName ? _self.coachName : coachName // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,timeSlot: null == timeSlot ? _self.timeSlot : timeSlot // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as LessonStatus,
  ));
}


}

// dart format on
