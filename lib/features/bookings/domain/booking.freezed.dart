// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Booking {

 String get id; String? get courtId; String get courtName;/// Giorno della prenotazione (solo data, `YYYY-MM-DD`).
 DateTime get date;/// `"18:30-20:00"`
 String get timeSlot;@JsonKey(unknownEnumValue: BookingStatus.unknown) BookingStatus get status;@JsonKey(unknownEnumValue: BookingType.court) BookingType get bookingType; String? get coachName; String? get playerEmail;
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingCopyWith<Booking> get copyWith => _$BookingCopyWithImpl<Booking>(this as Booking, _$identity);

  /// Serializes this Booking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.courtId, courtId) || other.courtId == courtId)&&(identical(other.courtName, courtName) || other.courtName == courtName)&&(identical(other.date, date) || other.date == date)&&(identical(other.timeSlot, timeSlot) || other.timeSlot == timeSlot)&&(identical(other.status, status) || other.status == status)&&(identical(other.bookingType, bookingType) || other.bookingType == bookingType)&&(identical(other.coachName, coachName) || other.coachName == coachName)&&(identical(other.playerEmail, playerEmail) || other.playerEmail == playerEmail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,courtId,courtName,date,timeSlot,status,bookingType,coachName,playerEmail);

@override
String toString() {
  return 'Booking(id: $id, courtId: $courtId, courtName: $courtName, date: $date, timeSlot: $timeSlot, status: $status, bookingType: $bookingType, coachName: $coachName, playerEmail: $playerEmail)';
}


}

/// @nodoc
abstract mixin class $BookingCopyWith<$Res>  {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) _then) = _$BookingCopyWithImpl;
@useResult
$Res call({
 String id, String? courtId, String courtName, DateTime date, String timeSlot,@JsonKey(unknownEnumValue: BookingStatus.unknown) BookingStatus status,@JsonKey(unknownEnumValue: BookingType.court) BookingType bookingType, String? coachName, String? playerEmail
});




}
/// @nodoc
class _$BookingCopyWithImpl<$Res>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._self, this._then);

  final Booking _self;
  final $Res Function(Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? courtId = freezed,Object? courtName = null,Object? date = null,Object? timeSlot = null,Object? status = null,Object? bookingType = null,Object? coachName = freezed,Object? playerEmail = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,courtId: freezed == courtId ? _self.courtId : courtId // ignore: cast_nullable_to_non_nullable
as String?,courtName: null == courtName ? _self.courtName : courtName // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,timeSlot: null == timeSlot ? _self.timeSlot : timeSlot // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,bookingType: null == bookingType ? _self.bookingType : bookingType // ignore: cast_nullable_to_non_nullable
as BookingType,coachName: freezed == coachName ? _self.coachName : coachName // ignore: cast_nullable_to_non_nullable
as String?,playerEmail: freezed == playerEmail ? _self.playerEmail : playerEmail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Booking].
extension BookingPatterns on Booking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Booking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Booking value)  $default,){
final _that = this;
switch (_that) {
case _Booking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Booking value)?  $default,){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? courtId,  String courtName,  DateTime date,  String timeSlot, @JsonKey(unknownEnumValue: BookingStatus.unknown)  BookingStatus status, @JsonKey(unknownEnumValue: BookingType.court)  BookingType bookingType,  String? coachName,  String? playerEmail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.courtId,_that.courtName,_that.date,_that.timeSlot,_that.status,_that.bookingType,_that.coachName,_that.playerEmail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? courtId,  String courtName,  DateTime date,  String timeSlot, @JsonKey(unknownEnumValue: BookingStatus.unknown)  BookingStatus status, @JsonKey(unknownEnumValue: BookingType.court)  BookingType bookingType,  String? coachName,  String? playerEmail)  $default,) {final _that = this;
switch (_that) {
case _Booking():
return $default(_that.id,_that.courtId,_that.courtName,_that.date,_that.timeSlot,_that.status,_that.bookingType,_that.coachName,_that.playerEmail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? courtId,  String courtName,  DateTime date,  String timeSlot, @JsonKey(unknownEnumValue: BookingStatus.unknown)  BookingStatus status, @JsonKey(unknownEnumValue: BookingType.court)  BookingType bookingType,  String? coachName,  String? playerEmail)?  $default,) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.courtId,_that.courtName,_that.date,_that.timeSlot,_that.status,_that.bookingType,_that.coachName,_that.playerEmail);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Booking extends Booking {
  const _Booking({required this.id, this.courtId, this.courtName = '', required this.date, required this.timeSlot, @JsonKey(unknownEnumValue: BookingStatus.unknown) this.status = BookingStatus.unknown, @JsonKey(unknownEnumValue: BookingType.court) this.bookingType = BookingType.court, this.coachName, this.playerEmail}): super._();
  factory _Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

@override final  String id;
@override final  String? courtId;
@override@JsonKey() final  String courtName;
/// Giorno della prenotazione (solo data, `YYYY-MM-DD`).
@override final  DateTime date;
/// `"18:30-20:00"`
@override final  String timeSlot;
@override@JsonKey(unknownEnumValue: BookingStatus.unknown) final  BookingStatus status;
@override@JsonKey(unknownEnumValue: BookingType.court) final  BookingType bookingType;
@override final  String? coachName;
@override final  String? playerEmail;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingCopyWith<_Booking> get copyWith => __$BookingCopyWithImpl<_Booking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.courtId, courtId) || other.courtId == courtId)&&(identical(other.courtName, courtName) || other.courtName == courtName)&&(identical(other.date, date) || other.date == date)&&(identical(other.timeSlot, timeSlot) || other.timeSlot == timeSlot)&&(identical(other.status, status) || other.status == status)&&(identical(other.bookingType, bookingType) || other.bookingType == bookingType)&&(identical(other.coachName, coachName) || other.coachName == coachName)&&(identical(other.playerEmail, playerEmail) || other.playerEmail == playerEmail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,courtId,courtName,date,timeSlot,status,bookingType,coachName,playerEmail);

@override
String toString() {
  return 'Booking(id: $id, courtId: $courtId, courtName: $courtName, date: $date, timeSlot: $timeSlot, status: $status, bookingType: $bookingType, coachName: $coachName, playerEmail: $playerEmail)';
}


}

/// @nodoc
abstract mixin class _$BookingCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$BookingCopyWith(_Booking value, $Res Function(_Booking) _then) = __$BookingCopyWithImpl;
@override @useResult
$Res call({
 String id, String? courtId, String courtName, DateTime date, String timeSlot,@JsonKey(unknownEnumValue: BookingStatus.unknown) BookingStatus status,@JsonKey(unknownEnumValue: BookingType.court) BookingType bookingType, String? coachName, String? playerEmail
});




}
/// @nodoc
class __$BookingCopyWithImpl<$Res>
    implements _$BookingCopyWith<$Res> {
  __$BookingCopyWithImpl(this._self, this._then);

  final _Booking _self;
  final $Res Function(_Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? courtId = freezed,Object? courtName = null,Object? date = null,Object? timeSlot = null,Object? status = null,Object? bookingType = null,Object? coachName = freezed,Object? playerEmail = freezed,}) {
  return _then(_Booking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,courtId: freezed == courtId ? _self.courtId : courtId // ignore: cast_nullable_to_non_nullable
as String?,courtName: null == courtName ? _self.courtName : courtName // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,timeSlot: null == timeSlot ? _self.timeSlot : timeSlot // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,bookingType: null == bookingType ? _self.bookingType : bookingType // ignore: cast_nullable_to_non_nullable
as BookingType,coachName: freezed == coachName ? _self.coachName : coachName // ignore: cast_nullable_to_non_nullable
as String?,playerEmail: freezed == playerEmail ? _self.playerEmail : playerEmail // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
