// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_subscription.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlayerSubscription {

 String get id; String get planName;@JsonKey(unknownEnumValue: PlanType.unknown) PlanType get planType;@JsonKey(unknownEnumValue: SubscriptionStatus.unknown) SubscriptionStatus get status;/// La validità parte dalla prima partita giocata: prima è `null`.
 DateTime? get activatedAt; DateTime? get expiresAt; int? get matchesTotal; int get matchesReserved; int get matchesUsed; int? get matchesAvailable;
/// Create a copy of PlayerSubscription
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerSubscriptionCopyWith<PlayerSubscription> get copyWith => _$PlayerSubscriptionCopyWithImpl<PlayerSubscription>(this as PlayerSubscription, _$identity);

  /// Serializes this PlayerSubscription to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerSubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.status, status) || other.status == status)&&(identical(other.activatedAt, activatedAt) || other.activatedAt == activatedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.matchesTotal, matchesTotal) || other.matchesTotal == matchesTotal)&&(identical(other.matchesReserved, matchesReserved) || other.matchesReserved == matchesReserved)&&(identical(other.matchesUsed, matchesUsed) || other.matchesUsed == matchesUsed)&&(identical(other.matchesAvailable, matchesAvailable) || other.matchesAvailable == matchesAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,planName,planType,status,activatedAt,expiresAt,matchesTotal,matchesReserved,matchesUsed,matchesAvailable);

@override
String toString() {
  return 'PlayerSubscription(id: $id, planName: $planName, planType: $planType, status: $status, activatedAt: $activatedAt, expiresAt: $expiresAt, matchesTotal: $matchesTotal, matchesReserved: $matchesReserved, matchesUsed: $matchesUsed, matchesAvailable: $matchesAvailable)';
}


}

/// @nodoc
abstract mixin class $PlayerSubscriptionCopyWith<$Res>  {
  factory $PlayerSubscriptionCopyWith(PlayerSubscription value, $Res Function(PlayerSubscription) _then) = _$PlayerSubscriptionCopyWithImpl;
@useResult
$Res call({
 String id, String planName,@JsonKey(unknownEnumValue: PlanType.unknown) PlanType planType,@JsonKey(unknownEnumValue: SubscriptionStatus.unknown) SubscriptionStatus status, DateTime? activatedAt, DateTime? expiresAt, int? matchesTotal, int matchesReserved, int matchesUsed, int? matchesAvailable
});




}
/// @nodoc
class _$PlayerSubscriptionCopyWithImpl<$Res>
    implements $PlayerSubscriptionCopyWith<$Res> {
  _$PlayerSubscriptionCopyWithImpl(this._self, this._then);

  final PlayerSubscription _self;
  final $Res Function(PlayerSubscription) _then;

/// Create a copy of PlayerSubscription
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? planName = null,Object? planType = null,Object? status = null,Object? activatedAt = freezed,Object? expiresAt = freezed,Object? matchesTotal = freezed,Object? matchesReserved = null,Object? matchesUsed = null,Object? matchesAvailable = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,planName: null == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as PlanType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SubscriptionStatus,activatedAt: freezed == activatedAt ? _self.activatedAt : activatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,matchesTotal: freezed == matchesTotal ? _self.matchesTotal : matchesTotal // ignore: cast_nullable_to_non_nullable
as int?,matchesReserved: null == matchesReserved ? _self.matchesReserved : matchesReserved // ignore: cast_nullable_to_non_nullable
as int,matchesUsed: null == matchesUsed ? _self.matchesUsed : matchesUsed // ignore: cast_nullable_to_non_nullable
as int,matchesAvailable: freezed == matchesAvailable ? _self.matchesAvailable : matchesAvailable // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerSubscription].
extension PlayerSubscriptionPatterns on PlayerSubscription {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerSubscription value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerSubscription() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerSubscription value)  $default,){
final _that = this;
switch (_that) {
case _PlayerSubscription():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerSubscription value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerSubscription() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String planName, @JsonKey(unknownEnumValue: PlanType.unknown)  PlanType planType, @JsonKey(unknownEnumValue: SubscriptionStatus.unknown)  SubscriptionStatus status,  DateTime? activatedAt,  DateTime? expiresAt,  int? matchesTotal,  int matchesReserved,  int matchesUsed,  int? matchesAvailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerSubscription() when $default != null:
return $default(_that.id,_that.planName,_that.planType,_that.status,_that.activatedAt,_that.expiresAt,_that.matchesTotal,_that.matchesReserved,_that.matchesUsed,_that.matchesAvailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String planName, @JsonKey(unknownEnumValue: PlanType.unknown)  PlanType planType, @JsonKey(unknownEnumValue: SubscriptionStatus.unknown)  SubscriptionStatus status,  DateTime? activatedAt,  DateTime? expiresAt,  int? matchesTotal,  int matchesReserved,  int matchesUsed,  int? matchesAvailable)  $default,) {final _that = this;
switch (_that) {
case _PlayerSubscription():
return $default(_that.id,_that.planName,_that.planType,_that.status,_that.activatedAt,_that.expiresAt,_that.matchesTotal,_that.matchesReserved,_that.matchesUsed,_that.matchesAvailable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String planName, @JsonKey(unknownEnumValue: PlanType.unknown)  PlanType planType, @JsonKey(unknownEnumValue: SubscriptionStatus.unknown)  SubscriptionStatus status,  DateTime? activatedAt,  DateTime? expiresAt,  int? matchesTotal,  int matchesReserved,  int matchesUsed,  int? matchesAvailable)?  $default,) {final _that = this;
switch (_that) {
case _PlayerSubscription() when $default != null:
return $default(_that.id,_that.planName,_that.planType,_that.status,_that.activatedAt,_that.expiresAt,_that.matchesTotal,_that.matchesReserved,_that.matchesUsed,_that.matchesAvailable);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayerSubscription extends PlayerSubscription {
  const _PlayerSubscription({required this.id, required this.planName, @JsonKey(unknownEnumValue: PlanType.unknown) this.planType = PlanType.unknown, @JsonKey(unknownEnumValue: SubscriptionStatus.unknown) this.status = SubscriptionStatus.unknown, this.activatedAt, this.expiresAt, this.matchesTotal, this.matchesReserved = 0, this.matchesUsed = 0, this.matchesAvailable}): super._();
  factory _PlayerSubscription.fromJson(Map<String, dynamic> json) => _$PlayerSubscriptionFromJson(json);

@override final  String id;
@override final  String planName;
@override@JsonKey(unknownEnumValue: PlanType.unknown) final  PlanType planType;
@override@JsonKey(unknownEnumValue: SubscriptionStatus.unknown) final  SubscriptionStatus status;
/// La validità parte dalla prima partita giocata: prima è `null`.
@override final  DateTime? activatedAt;
@override final  DateTime? expiresAt;
@override final  int? matchesTotal;
@override@JsonKey() final  int matchesReserved;
@override@JsonKey() final  int matchesUsed;
@override final  int? matchesAvailable;

/// Create a copy of PlayerSubscription
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerSubscriptionCopyWith<_PlayerSubscription> get copyWith => __$PlayerSubscriptionCopyWithImpl<_PlayerSubscription>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerSubscriptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerSubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.planType, planType) || other.planType == planType)&&(identical(other.status, status) || other.status == status)&&(identical(other.activatedAt, activatedAt) || other.activatedAt == activatedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.matchesTotal, matchesTotal) || other.matchesTotal == matchesTotal)&&(identical(other.matchesReserved, matchesReserved) || other.matchesReserved == matchesReserved)&&(identical(other.matchesUsed, matchesUsed) || other.matchesUsed == matchesUsed)&&(identical(other.matchesAvailable, matchesAvailable) || other.matchesAvailable == matchesAvailable));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,planName,planType,status,activatedAt,expiresAt,matchesTotal,matchesReserved,matchesUsed,matchesAvailable);

@override
String toString() {
  return 'PlayerSubscription(id: $id, planName: $planName, planType: $planType, status: $status, activatedAt: $activatedAt, expiresAt: $expiresAt, matchesTotal: $matchesTotal, matchesReserved: $matchesReserved, matchesUsed: $matchesUsed, matchesAvailable: $matchesAvailable)';
}


}

/// @nodoc
abstract mixin class _$PlayerSubscriptionCopyWith<$Res> implements $PlayerSubscriptionCopyWith<$Res> {
  factory _$PlayerSubscriptionCopyWith(_PlayerSubscription value, $Res Function(_PlayerSubscription) _then) = __$PlayerSubscriptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String planName,@JsonKey(unknownEnumValue: PlanType.unknown) PlanType planType,@JsonKey(unknownEnumValue: SubscriptionStatus.unknown) SubscriptionStatus status, DateTime? activatedAt, DateTime? expiresAt, int? matchesTotal, int matchesReserved, int matchesUsed, int? matchesAvailable
});




}
/// @nodoc
class __$PlayerSubscriptionCopyWithImpl<$Res>
    implements _$PlayerSubscriptionCopyWith<$Res> {
  __$PlayerSubscriptionCopyWithImpl(this._self, this._then);

  final _PlayerSubscription _self;
  final $Res Function(_PlayerSubscription) _then;

/// Create a copy of PlayerSubscription
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? planName = null,Object? planType = null,Object? status = null,Object? activatedAt = freezed,Object? expiresAt = freezed,Object? matchesTotal = freezed,Object? matchesReserved = null,Object? matchesUsed = null,Object? matchesAvailable = freezed,}) {
  return _then(_PlayerSubscription(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,planName: null == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String,planType: null == planType ? _self.planType : planType // ignore: cast_nullable_to_non_nullable
as PlanType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SubscriptionStatus,activatedAt: freezed == activatedAt ? _self.activatedAt : activatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,matchesTotal: freezed == matchesTotal ? _self.matchesTotal : matchesTotal // ignore: cast_nullable_to_non_nullable
as int?,matchesReserved: null == matchesReserved ? _self.matchesReserved : matchesReserved // ignore: cast_nullable_to_non_nullable
as int,matchesUsed: null == matchesUsed ? _self.matchesUsed : matchesUsed // ignore: cast_nullable_to_non_nullable
as int,matchesAvailable: freezed == matchesAvailable ? _self.matchesAvailable : matchesAvailable // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
