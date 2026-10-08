// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'padel_match.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MatchPlayer {

 String? get userId; String? get playerRef; String get name; String? get participantType;
/// Create a copy of MatchPlayer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchPlayerCopyWith<MatchPlayer> get copyWith => _$MatchPlayerCopyWithImpl<MatchPlayer>(this as MatchPlayer, _$identity);

  /// Serializes this MatchPlayer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MatchPlayer&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.playerRef, playerRef) || other.playerRef == playerRef)&&(identical(other.name, name) || other.name == name)&&(identical(other.participantType, participantType) || other.participantType == participantType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,playerRef,name,participantType);

@override
String toString() {
  return 'MatchPlayer(userId: $userId, playerRef: $playerRef, name: $name, participantType: $participantType)';
}


}

/// @nodoc
abstract mixin class $MatchPlayerCopyWith<$Res>  {
  factory $MatchPlayerCopyWith(MatchPlayer value, $Res Function(MatchPlayer) _then) = _$MatchPlayerCopyWithImpl;
@useResult
$Res call({
 String? userId, String? playerRef, String name, String? participantType
});




}
/// @nodoc
class _$MatchPlayerCopyWithImpl<$Res>
    implements $MatchPlayerCopyWith<$Res> {
  _$MatchPlayerCopyWithImpl(this._self, this._then);

  final MatchPlayer _self;
  final $Res Function(MatchPlayer) _then;

/// Create a copy of MatchPlayer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = freezed,Object? playerRef = freezed,Object? name = null,Object? participantType = freezed,}) {
  return _then(_self.copyWith(
userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,playerRef: freezed == playerRef ? _self.playerRef : playerRef // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,participantType: freezed == participantType ? _self.participantType : participantType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MatchPlayer].
extension MatchPlayerPatterns on MatchPlayer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MatchPlayer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MatchPlayer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MatchPlayer value)  $default,){
final _that = this;
switch (_that) {
case _MatchPlayer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MatchPlayer value)?  $default,){
final _that = this;
switch (_that) {
case _MatchPlayer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? userId,  String? playerRef,  String name,  String? participantType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MatchPlayer() when $default != null:
return $default(_that.userId,_that.playerRef,_that.name,_that.participantType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? userId,  String? playerRef,  String name,  String? participantType)  $default,) {final _that = this;
switch (_that) {
case _MatchPlayer():
return $default(_that.userId,_that.playerRef,_that.name,_that.participantType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? userId,  String? playerRef,  String name,  String? participantType)?  $default,) {final _that = this;
switch (_that) {
case _MatchPlayer() when $default != null:
return $default(_that.userId,_that.playerRef,_that.name,_that.participantType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MatchPlayer implements MatchPlayer {
  const _MatchPlayer({this.userId, this.playerRef, required this.name, this.participantType});
  factory _MatchPlayer.fromJson(Map<String, dynamic> json) => _$MatchPlayerFromJson(json);

@override final  String? userId;
@override final  String? playerRef;
@override final  String name;
@override final  String? participantType;

/// Create a copy of MatchPlayer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchPlayerCopyWith<_MatchPlayer> get copyWith => __$MatchPlayerCopyWithImpl<_MatchPlayer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchPlayerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MatchPlayer&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.playerRef, playerRef) || other.playerRef == playerRef)&&(identical(other.name, name) || other.name == name)&&(identical(other.participantType, participantType) || other.participantType == participantType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,playerRef,name,participantType);

@override
String toString() {
  return 'MatchPlayer(userId: $userId, playerRef: $playerRef, name: $name, participantType: $participantType)';
}


}

/// @nodoc
abstract mixin class _$MatchPlayerCopyWith<$Res> implements $MatchPlayerCopyWith<$Res> {
  factory _$MatchPlayerCopyWith(_MatchPlayer value, $Res Function(_MatchPlayer) _then) = __$MatchPlayerCopyWithImpl;
@override @useResult
$Res call({
 String? userId, String? playerRef, String name, String? participantType
});




}
/// @nodoc
class __$MatchPlayerCopyWithImpl<$Res>
    implements _$MatchPlayerCopyWith<$Res> {
  __$MatchPlayerCopyWithImpl(this._self, this._then);

  final _MatchPlayer _self;
  final $Res Function(_MatchPlayer) _then;

/// Create a copy of MatchPlayer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = freezed,Object? playerRef = freezed,Object? name = null,Object? participantType = freezed,}) {
  return _then(_MatchPlayer(
userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,playerRef: freezed == playerRef ? _self.playerRef : playerRef // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,participantType: freezed == participantType ? _self.participantType : participantType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PadelMatch {

 String get id; String? get bookingId; DateTime get date; String get courtName; String get timeSlot;@JsonKey(unknownEnumValue: MatchStatus.unknown) MatchStatus get status;@JsonKey(unknownEnumValue: MatchType.unknown) MatchType get matchType;@JsonKey(unknownEnumValue: MatchLevel.qualsiasi) MatchLevel get level;/// Id dell'organizzatore se registrato, altrimenti un hash dell'email.
 String? get organizerRef; String? get organizerName; int get maxPlayers;/// Punteggio dal punto di vista della squadra A, es. `"6-4 6-3"`.
 String? get scoreTeam1; String? get winnerTeam;/// In ordine di posizione: 0–1 squadra A, 2–3 squadra B.
 List<MatchPlayer> get players;
/// Create a copy of PadelMatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PadelMatchCopyWith<PadelMatch> get copyWith => _$PadelMatchCopyWithImpl<PadelMatch>(this as PadelMatch, _$identity);

  /// Serializes this PadelMatch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PadelMatch&&(identical(other.id, id) || other.id == id)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.date, date) || other.date == date)&&(identical(other.courtName, courtName) || other.courtName == courtName)&&(identical(other.timeSlot, timeSlot) || other.timeSlot == timeSlot)&&(identical(other.status, status) || other.status == status)&&(identical(other.matchType, matchType) || other.matchType == matchType)&&(identical(other.level, level) || other.level == level)&&(identical(other.organizerRef, organizerRef) || other.organizerRef == organizerRef)&&(identical(other.organizerName, organizerName) || other.organizerName == organizerName)&&(identical(other.maxPlayers, maxPlayers) || other.maxPlayers == maxPlayers)&&(identical(other.scoreTeam1, scoreTeam1) || other.scoreTeam1 == scoreTeam1)&&(identical(other.winnerTeam, winnerTeam) || other.winnerTeam == winnerTeam)&&const DeepCollectionEquality().equals(other.players, players));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bookingId,date,courtName,timeSlot,status,matchType,level,organizerRef,organizerName,maxPlayers,scoreTeam1,winnerTeam,const DeepCollectionEquality().hash(players));

@override
String toString() {
  return 'PadelMatch(id: $id, bookingId: $bookingId, date: $date, courtName: $courtName, timeSlot: $timeSlot, status: $status, matchType: $matchType, level: $level, organizerRef: $organizerRef, organizerName: $organizerName, maxPlayers: $maxPlayers, scoreTeam1: $scoreTeam1, winnerTeam: $winnerTeam, players: $players)';
}


}

/// @nodoc
abstract mixin class $PadelMatchCopyWith<$Res>  {
  factory $PadelMatchCopyWith(PadelMatch value, $Res Function(PadelMatch) _then) = _$PadelMatchCopyWithImpl;
@useResult
$Res call({
 String id, String? bookingId, DateTime date, String courtName, String timeSlot,@JsonKey(unknownEnumValue: MatchStatus.unknown) MatchStatus status,@JsonKey(unknownEnumValue: MatchType.unknown) MatchType matchType,@JsonKey(unknownEnumValue: MatchLevel.qualsiasi) MatchLevel level, String? organizerRef, String? organizerName, int maxPlayers, String? scoreTeam1, String? winnerTeam, List<MatchPlayer> players
});




}
/// @nodoc
class _$PadelMatchCopyWithImpl<$Res>
    implements $PadelMatchCopyWith<$Res> {
  _$PadelMatchCopyWithImpl(this._self, this._then);

  final PadelMatch _self;
  final $Res Function(PadelMatch) _then;

/// Create a copy of PadelMatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bookingId = freezed,Object? date = null,Object? courtName = null,Object? timeSlot = null,Object? status = null,Object? matchType = null,Object? level = null,Object? organizerRef = freezed,Object? organizerName = freezed,Object? maxPlayers = null,Object? scoreTeam1 = freezed,Object? winnerTeam = freezed,Object? players = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,courtName: null == courtName ? _self.courtName : courtName // ignore: cast_nullable_to_non_nullable
as String,timeSlot: null == timeSlot ? _self.timeSlot : timeSlot // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MatchStatus,matchType: null == matchType ? _self.matchType : matchType // ignore: cast_nullable_to_non_nullable
as MatchType,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as MatchLevel,organizerRef: freezed == organizerRef ? _self.organizerRef : organizerRef // ignore: cast_nullable_to_non_nullable
as String?,organizerName: freezed == organizerName ? _self.organizerName : organizerName // ignore: cast_nullable_to_non_nullable
as String?,maxPlayers: null == maxPlayers ? _self.maxPlayers : maxPlayers // ignore: cast_nullable_to_non_nullable
as int,scoreTeam1: freezed == scoreTeam1 ? _self.scoreTeam1 : scoreTeam1 // ignore: cast_nullable_to_non_nullable
as String?,winnerTeam: freezed == winnerTeam ? _self.winnerTeam : winnerTeam // ignore: cast_nullable_to_non_nullable
as String?,players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as List<MatchPlayer>,
  ));
}

}


/// Adds pattern-matching-related methods to [PadelMatch].
extension PadelMatchPatterns on PadelMatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PadelMatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PadelMatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PadelMatch value)  $default,){
final _that = this;
switch (_that) {
case _PadelMatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PadelMatch value)?  $default,){
final _that = this;
switch (_that) {
case _PadelMatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? bookingId,  DateTime date,  String courtName,  String timeSlot, @JsonKey(unknownEnumValue: MatchStatus.unknown)  MatchStatus status, @JsonKey(unknownEnumValue: MatchType.unknown)  MatchType matchType, @JsonKey(unknownEnumValue: MatchLevel.qualsiasi)  MatchLevel level,  String? organizerRef,  String? organizerName,  int maxPlayers,  String? scoreTeam1,  String? winnerTeam,  List<MatchPlayer> players)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PadelMatch() when $default != null:
return $default(_that.id,_that.bookingId,_that.date,_that.courtName,_that.timeSlot,_that.status,_that.matchType,_that.level,_that.organizerRef,_that.organizerName,_that.maxPlayers,_that.scoreTeam1,_that.winnerTeam,_that.players);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? bookingId,  DateTime date,  String courtName,  String timeSlot, @JsonKey(unknownEnumValue: MatchStatus.unknown)  MatchStatus status, @JsonKey(unknownEnumValue: MatchType.unknown)  MatchType matchType, @JsonKey(unknownEnumValue: MatchLevel.qualsiasi)  MatchLevel level,  String? organizerRef,  String? organizerName,  int maxPlayers,  String? scoreTeam1,  String? winnerTeam,  List<MatchPlayer> players)  $default,) {final _that = this;
switch (_that) {
case _PadelMatch():
return $default(_that.id,_that.bookingId,_that.date,_that.courtName,_that.timeSlot,_that.status,_that.matchType,_that.level,_that.organizerRef,_that.organizerName,_that.maxPlayers,_that.scoreTeam1,_that.winnerTeam,_that.players);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? bookingId,  DateTime date,  String courtName,  String timeSlot, @JsonKey(unknownEnumValue: MatchStatus.unknown)  MatchStatus status, @JsonKey(unknownEnumValue: MatchType.unknown)  MatchType matchType, @JsonKey(unknownEnumValue: MatchLevel.qualsiasi)  MatchLevel level,  String? organizerRef,  String? organizerName,  int maxPlayers,  String? scoreTeam1,  String? winnerTeam,  List<MatchPlayer> players)?  $default,) {final _that = this;
switch (_that) {
case _PadelMatch() when $default != null:
return $default(_that.id,_that.bookingId,_that.date,_that.courtName,_that.timeSlot,_that.status,_that.matchType,_that.level,_that.organizerRef,_that.organizerName,_that.maxPlayers,_that.scoreTeam1,_that.winnerTeam,_that.players);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PadelMatch extends PadelMatch {
  const _PadelMatch({required this.id, this.bookingId, required this.date, this.courtName = '', required this.timeSlot, @JsonKey(unknownEnumValue: MatchStatus.unknown) this.status = MatchStatus.unknown, @JsonKey(unknownEnumValue: MatchType.unknown) this.matchType = MatchType.unknown, @JsonKey(unknownEnumValue: MatchLevel.qualsiasi) this.level = MatchLevel.qualsiasi, this.organizerRef, this.organizerName, this.maxPlayers = 4, this.scoreTeam1, this.winnerTeam, final  List<MatchPlayer> players = const []}): _players = players,super._();
  factory _PadelMatch.fromJson(Map<String, dynamic> json) => _$PadelMatchFromJson(json);

@override final  String id;
@override final  String? bookingId;
@override final  DateTime date;
@override@JsonKey() final  String courtName;
@override final  String timeSlot;
@override@JsonKey(unknownEnumValue: MatchStatus.unknown) final  MatchStatus status;
@override@JsonKey(unknownEnumValue: MatchType.unknown) final  MatchType matchType;
@override@JsonKey(unknownEnumValue: MatchLevel.qualsiasi) final  MatchLevel level;
/// Id dell'organizzatore se registrato, altrimenti un hash dell'email.
@override final  String? organizerRef;
@override final  String? organizerName;
@override@JsonKey() final  int maxPlayers;
/// Punteggio dal punto di vista della squadra A, es. `"6-4 6-3"`.
@override final  String? scoreTeam1;
@override final  String? winnerTeam;
/// In ordine di posizione: 0–1 squadra A, 2–3 squadra B.
 final  List<MatchPlayer> _players;
/// In ordine di posizione: 0–1 squadra A, 2–3 squadra B.
@override@JsonKey() List<MatchPlayer> get players {
  if (_players is EqualUnmodifiableListView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_players);
}


/// Create a copy of PadelMatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PadelMatchCopyWith<_PadelMatch> get copyWith => __$PadelMatchCopyWithImpl<_PadelMatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PadelMatchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PadelMatch&&(identical(other.id, id) || other.id == id)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.date, date) || other.date == date)&&(identical(other.courtName, courtName) || other.courtName == courtName)&&(identical(other.timeSlot, timeSlot) || other.timeSlot == timeSlot)&&(identical(other.status, status) || other.status == status)&&(identical(other.matchType, matchType) || other.matchType == matchType)&&(identical(other.level, level) || other.level == level)&&(identical(other.organizerRef, organizerRef) || other.organizerRef == organizerRef)&&(identical(other.organizerName, organizerName) || other.organizerName == organizerName)&&(identical(other.maxPlayers, maxPlayers) || other.maxPlayers == maxPlayers)&&(identical(other.scoreTeam1, scoreTeam1) || other.scoreTeam1 == scoreTeam1)&&(identical(other.winnerTeam, winnerTeam) || other.winnerTeam == winnerTeam)&&const DeepCollectionEquality().equals(other._players, _players));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bookingId,date,courtName,timeSlot,status,matchType,level,organizerRef,organizerName,maxPlayers,scoreTeam1,winnerTeam,const DeepCollectionEquality().hash(_players));

@override
String toString() {
  return 'PadelMatch(id: $id, bookingId: $bookingId, date: $date, courtName: $courtName, timeSlot: $timeSlot, status: $status, matchType: $matchType, level: $level, organizerRef: $organizerRef, organizerName: $organizerName, maxPlayers: $maxPlayers, scoreTeam1: $scoreTeam1, winnerTeam: $winnerTeam, players: $players)';
}


}

/// @nodoc
abstract mixin class _$PadelMatchCopyWith<$Res> implements $PadelMatchCopyWith<$Res> {
  factory _$PadelMatchCopyWith(_PadelMatch value, $Res Function(_PadelMatch) _then) = __$PadelMatchCopyWithImpl;
@override @useResult
$Res call({
 String id, String? bookingId, DateTime date, String courtName, String timeSlot,@JsonKey(unknownEnumValue: MatchStatus.unknown) MatchStatus status,@JsonKey(unknownEnumValue: MatchType.unknown) MatchType matchType,@JsonKey(unknownEnumValue: MatchLevel.qualsiasi) MatchLevel level, String? organizerRef, String? organizerName, int maxPlayers, String? scoreTeam1, String? winnerTeam, List<MatchPlayer> players
});




}
/// @nodoc
class __$PadelMatchCopyWithImpl<$Res>
    implements _$PadelMatchCopyWith<$Res> {
  __$PadelMatchCopyWithImpl(this._self, this._then);

  final _PadelMatch _self;
  final $Res Function(_PadelMatch) _then;

/// Create a copy of PadelMatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bookingId = freezed,Object? date = null,Object? courtName = null,Object? timeSlot = null,Object? status = null,Object? matchType = null,Object? level = null,Object? organizerRef = freezed,Object? organizerName = freezed,Object? maxPlayers = null,Object? scoreTeam1 = freezed,Object? winnerTeam = freezed,Object? players = null,}) {
  return _then(_PadelMatch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,courtName: null == courtName ? _self.courtName : courtName // ignore: cast_nullable_to_non_nullable
as String,timeSlot: null == timeSlot ? _self.timeSlot : timeSlot // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MatchStatus,matchType: null == matchType ? _self.matchType : matchType // ignore: cast_nullable_to_non_nullable
as MatchType,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as MatchLevel,organizerRef: freezed == organizerRef ? _self.organizerRef : organizerRef // ignore: cast_nullable_to_non_nullable
as String?,organizerName: freezed == organizerName ? _self.organizerName : organizerName // ignore: cast_nullable_to_non_nullable
as String?,maxPlayers: null == maxPlayers ? _self.maxPlayers : maxPlayers // ignore: cast_nullable_to_non_nullable
as int,scoreTeam1: freezed == scoreTeam1 ? _self.scoreTeam1 : scoreTeam1 // ignore: cast_nullable_to_non_nullable
as String?,winnerTeam: freezed == winnerTeam ? _self.winnerTeam : winnerTeam // ignore: cast_nullable_to_non_nullable
as String?,players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as List<MatchPlayer>,
  ));
}


}

// dart format on
