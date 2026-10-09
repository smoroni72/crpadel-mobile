// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CourtRef {

 String get id; String get name;
/// Create a copy of CourtRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CourtRefCopyWith<CourtRef> get copyWith => _$CourtRefCopyWithImpl<CourtRef>(this as CourtRef, _$identity);

  /// Serializes this CourtRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CourtRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'CourtRef(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $CourtRefCopyWith<$Res>  {
  factory $CourtRefCopyWith(CourtRef value, $Res Function(CourtRef) _then) = _$CourtRefCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$CourtRefCopyWithImpl<$Res>
    implements $CourtRefCopyWith<$Res> {
  _$CourtRefCopyWithImpl(this._self, this._then);

  final CourtRef _self;
  final $Res Function(CourtRef) _then;

/// Create a copy of CourtRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CourtRef].
extension CourtRefPatterns on CourtRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CourtRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CourtRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CourtRef value)  $default,){
final _that = this;
switch (_that) {
case _CourtRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CourtRef value)?  $default,){
final _that = this;
switch (_that) {
case _CourtRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CourtRef() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _CourtRef():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _CourtRef() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CourtRef implements CourtRef {
  const _CourtRef({required this.id, required this.name});
  factory _CourtRef.fromJson(Map<String, dynamic> json) => _$CourtRefFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of CourtRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CourtRefCopyWith<_CourtRef> get copyWith => __$CourtRefCopyWithImpl<_CourtRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CourtRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CourtRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'CourtRef(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$CourtRefCopyWith<$Res> implements $CourtRefCopyWith<$Res> {
  factory _$CourtRefCopyWith(_CourtRef value, $Res Function(_CourtRef) _then) = __$CourtRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$CourtRefCopyWithImpl<$Res>
    implements _$CourtRefCopyWith<$Res> {
  __$CourtRefCopyWithImpl(this._self, this._then);

  final _CourtRef _self;
  final $Res Function(_CourtRef) _then;

/// Create a copy of CourtRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_CourtRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Court {

 String get id; String get name; String? get type; String? get surface;
/// Create a copy of Court
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CourtCopyWith<Court> get copyWith => _$CourtCopyWithImpl<Court>(this as Court, _$identity);

  /// Serializes this Court to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Court&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.surface, surface) || other.surface == surface));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,surface);

@override
String toString() {
  return 'Court(id: $id, name: $name, type: $type, surface: $surface)';
}


}

/// @nodoc
abstract mixin class $CourtCopyWith<$Res>  {
  factory $CourtCopyWith(Court value, $Res Function(Court) _then) = _$CourtCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? type, String? surface
});




}
/// @nodoc
class _$CourtCopyWithImpl<$Res>
    implements $CourtCopyWith<$Res> {
  _$CourtCopyWithImpl(this._self, this._then);

  final Court _self;
  final $Res Function(Court) _then;

/// Create a copy of Court
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = freezed,Object? surface = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,surface: freezed == surface ? _self.surface : surface // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Court].
extension CourtPatterns on Court {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Court value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Court() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Court value)  $default,){
final _that = this;
switch (_that) {
case _Court():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Court value)?  $default,){
final _that = this;
switch (_that) {
case _Court() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? type,  String? surface)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Court() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.surface);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? type,  String? surface)  $default,) {final _that = this;
switch (_that) {
case _Court():
return $default(_that.id,_that.name,_that.type,_that.surface);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? type,  String? surface)?  $default,) {final _that = this;
switch (_that) {
case _Court() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.surface);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Court extends Court {
  const _Court({required this.id, required this.name, this.type, this.surface}): super._();
  factory _Court.fromJson(Map<String, dynamic> json) => _$CourtFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? type;
@override final  String? surface;

/// Create a copy of Court
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CourtCopyWith<_Court> get copyWith => __$CourtCopyWithImpl<_Court>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CourtToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Court&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.surface, surface) || other.surface == surface));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,surface);

@override
String toString() {
  return 'Court(id: $id, name: $name, type: $type, surface: $surface)';
}


}

/// @nodoc
abstract mixin class _$CourtCopyWith<$Res> implements $CourtCopyWith<$Res> {
  factory _$CourtCopyWith(_Court value, $Res Function(_Court) _then) = __$CourtCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? type, String? surface
});




}
/// @nodoc
class __$CourtCopyWithImpl<$Res>
    implements _$CourtCopyWith<$Res> {
  __$CourtCopyWithImpl(this._self, this._then);

  final _Court _self;
  final $Res Function(_Court) _then;

/// Create a copy of Court
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = freezed,Object? surface = freezed,}) {
  return _then(_Court(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,surface: freezed == surface ? _self.surface : surface // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ScheduleEvent {

 String get id; String? get bookingId; String get courtId;/// `booking` o `match`.
 String get source;@JsonKey(unknownEnumValue: ScheduleKind.unknown) ScheduleKind get kind; String? get label;/// Ore decimali (18.5 = 18:30), intervallo `[inizio, fine)`.
 double get startHour; double get endHour;/// L'impegno è dell'utente.
 bool get isOwner;/// L'utente può usarlo (es. aprirci una partita).
 bool get canUse;
/// Create a copy of ScheduleEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduleEventCopyWith<ScheduleEvent> get copyWith => _$ScheduleEventCopyWithImpl<ScheduleEvent>(this as ScheduleEvent, _$identity);

  /// Serializes this ScheduleEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduleEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.courtId, courtId) || other.courtId == courtId)&&(identical(other.source, source) || other.source == source)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.label, label) || other.label == label)&&(identical(other.startHour, startHour) || other.startHour == startHour)&&(identical(other.endHour, endHour) || other.endHour == endHour)&&(identical(other.isOwner, isOwner) || other.isOwner == isOwner)&&(identical(other.canUse, canUse) || other.canUse == canUse));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bookingId,courtId,source,kind,label,startHour,endHour,isOwner,canUse);

@override
String toString() {
  return 'ScheduleEvent(id: $id, bookingId: $bookingId, courtId: $courtId, source: $source, kind: $kind, label: $label, startHour: $startHour, endHour: $endHour, isOwner: $isOwner, canUse: $canUse)';
}


}

/// @nodoc
abstract mixin class $ScheduleEventCopyWith<$Res>  {
  factory $ScheduleEventCopyWith(ScheduleEvent value, $Res Function(ScheduleEvent) _then) = _$ScheduleEventCopyWithImpl;
@useResult
$Res call({
 String id, String? bookingId, String courtId, String source,@JsonKey(unknownEnumValue: ScheduleKind.unknown) ScheduleKind kind, String? label, double startHour, double endHour, bool isOwner, bool canUse
});




}
/// @nodoc
class _$ScheduleEventCopyWithImpl<$Res>
    implements $ScheduleEventCopyWith<$Res> {
  _$ScheduleEventCopyWithImpl(this._self, this._then);

  final ScheduleEvent _self;
  final $Res Function(ScheduleEvent) _then;

/// Create a copy of ScheduleEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? bookingId = freezed,Object? courtId = null,Object? source = null,Object? kind = null,Object? label = freezed,Object? startHour = null,Object? endHour = null,Object? isOwner = null,Object? canUse = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,courtId: null == courtId ? _self.courtId : courtId // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ScheduleKind,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,startHour: null == startHour ? _self.startHour : startHour // ignore: cast_nullable_to_non_nullable
as double,endHour: null == endHour ? _self.endHour : endHour // ignore: cast_nullable_to_non_nullable
as double,isOwner: null == isOwner ? _self.isOwner : isOwner // ignore: cast_nullable_to_non_nullable
as bool,canUse: null == canUse ? _self.canUse : canUse // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduleEvent].
extension ScheduleEventPatterns on ScheduleEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduleEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduleEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduleEvent value)  $default,){
final _that = this;
switch (_that) {
case _ScheduleEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduleEvent value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduleEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? bookingId,  String courtId,  String source, @JsonKey(unknownEnumValue: ScheduleKind.unknown)  ScheduleKind kind,  String? label,  double startHour,  double endHour,  bool isOwner,  bool canUse)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduleEvent() when $default != null:
return $default(_that.id,_that.bookingId,_that.courtId,_that.source,_that.kind,_that.label,_that.startHour,_that.endHour,_that.isOwner,_that.canUse);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? bookingId,  String courtId,  String source, @JsonKey(unknownEnumValue: ScheduleKind.unknown)  ScheduleKind kind,  String? label,  double startHour,  double endHour,  bool isOwner,  bool canUse)  $default,) {final _that = this;
switch (_that) {
case _ScheduleEvent():
return $default(_that.id,_that.bookingId,_that.courtId,_that.source,_that.kind,_that.label,_that.startHour,_that.endHour,_that.isOwner,_that.canUse);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? bookingId,  String courtId,  String source, @JsonKey(unknownEnumValue: ScheduleKind.unknown)  ScheduleKind kind,  String? label,  double startHour,  double endHour,  bool isOwner,  bool canUse)?  $default,) {final _that = this;
switch (_that) {
case _ScheduleEvent() when $default != null:
return $default(_that.id,_that.bookingId,_that.courtId,_that.source,_that.kind,_that.label,_that.startHour,_that.endHour,_that.isOwner,_that.canUse);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduleEvent extends ScheduleEvent {
  const _ScheduleEvent({required this.id, this.bookingId, required this.courtId, this.source = 'booking', @JsonKey(unknownEnumValue: ScheduleKind.unknown) this.kind = ScheduleKind.unknown, this.label, required this.startHour, required this.endHour, this.isOwner = false, this.canUse = false}): super._();
  factory _ScheduleEvent.fromJson(Map<String, dynamic> json) => _$ScheduleEventFromJson(json);

@override final  String id;
@override final  String? bookingId;
@override final  String courtId;
/// `booking` o `match`.
@override@JsonKey() final  String source;
@override@JsonKey(unknownEnumValue: ScheduleKind.unknown) final  ScheduleKind kind;
@override final  String? label;
/// Ore decimali (18.5 = 18:30), intervallo `[inizio, fine)`.
@override final  double startHour;
@override final  double endHour;
/// L'impegno è dell'utente.
@override@JsonKey() final  bool isOwner;
/// L'utente può usarlo (es. aprirci una partita).
@override@JsonKey() final  bool canUse;

/// Create a copy of ScheduleEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduleEventCopyWith<_ScheduleEvent> get copyWith => __$ScheduleEventCopyWithImpl<_ScheduleEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduleEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduleEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.courtId, courtId) || other.courtId == courtId)&&(identical(other.source, source) || other.source == source)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.label, label) || other.label == label)&&(identical(other.startHour, startHour) || other.startHour == startHour)&&(identical(other.endHour, endHour) || other.endHour == endHour)&&(identical(other.isOwner, isOwner) || other.isOwner == isOwner)&&(identical(other.canUse, canUse) || other.canUse == canUse));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,bookingId,courtId,source,kind,label,startHour,endHour,isOwner,canUse);

@override
String toString() {
  return 'ScheduleEvent(id: $id, bookingId: $bookingId, courtId: $courtId, source: $source, kind: $kind, label: $label, startHour: $startHour, endHour: $endHour, isOwner: $isOwner, canUse: $canUse)';
}


}

/// @nodoc
abstract mixin class _$ScheduleEventCopyWith<$Res> implements $ScheduleEventCopyWith<$Res> {
  factory _$ScheduleEventCopyWith(_ScheduleEvent value, $Res Function(_ScheduleEvent) _then) = __$ScheduleEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String? bookingId, String courtId, String source,@JsonKey(unknownEnumValue: ScheduleKind.unknown) ScheduleKind kind, String? label, double startHour, double endHour, bool isOwner, bool canUse
});




}
/// @nodoc
class __$ScheduleEventCopyWithImpl<$Res>
    implements _$ScheduleEventCopyWith<$Res> {
  __$ScheduleEventCopyWithImpl(this._self, this._then);

  final _ScheduleEvent _self;
  final $Res Function(_ScheduleEvent) _then;

/// Create a copy of ScheduleEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? bookingId = freezed,Object? courtId = null,Object? source = null,Object? kind = null,Object? label = freezed,Object? startHour = null,Object? endHour = null,Object? isOwner = null,Object? canUse = null,}) {
  return _then(_ScheduleEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,bookingId: freezed == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String?,courtId: null == courtId ? _self.courtId : courtId // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ScheduleKind,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,startHour: null == startHour ? _self.startHour : startHour // ignore: cast_nullable_to_non_nullable
as double,endHour: null == endHour ? _self.endHour : endHour // ignore: cast_nullable_to_non_nullable
as double,isOwner: null == isOwner ? _self.isOwner : isOwner // ignore: cast_nullable_to_non_nullable
as bool,canUse: null == canUse ? _self.canUse : canUse // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$DaySchedule {

 String get date; List<CourtRef> get courts; List<ScheduleEvent> get events;
/// Create a copy of DaySchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DayScheduleCopyWith<DaySchedule> get copyWith => _$DayScheduleCopyWithImpl<DaySchedule>(this as DaySchedule, _$identity);

  /// Serializes this DaySchedule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DaySchedule&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.courts, courts)&&const DeepCollectionEquality().equals(other.events, events));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,const DeepCollectionEquality().hash(courts),const DeepCollectionEquality().hash(events));

@override
String toString() {
  return 'DaySchedule(date: $date, courts: $courts, events: $events)';
}


}

/// @nodoc
abstract mixin class $DayScheduleCopyWith<$Res>  {
  factory $DayScheduleCopyWith(DaySchedule value, $Res Function(DaySchedule) _then) = _$DayScheduleCopyWithImpl;
@useResult
$Res call({
 String date, List<CourtRef> courts, List<ScheduleEvent> events
});




}
/// @nodoc
class _$DayScheduleCopyWithImpl<$Res>
    implements $DayScheduleCopyWith<$Res> {
  _$DayScheduleCopyWithImpl(this._self, this._then);

  final DaySchedule _self;
  final $Res Function(DaySchedule) _then;

/// Create a copy of DaySchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? courts = null,Object? events = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,courts: null == courts ? _self.courts : courts // ignore: cast_nullable_to_non_nullable
as List<CourtRef>,events: null == events ? _self.events : events // ignore: cast_nullable_to_non_nullable
as List<ScheduleEvent>,
  ));
}

}


/// Adds pattern-matching-related methods to [DaySchedule].
extension DaySchedulePatterns on DaySchedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DaySchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DaySchedule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DaySchedule value)  $default,){
final _that = this;
switch (_that) {
case _DaySchedule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DaySchedule value)?  $default,){
final _that = this;
switch (_that) {
case _DaySchedule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  List<CourtRef> courts,  List<ScheduleEvent> events)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DaySchedule() when $default != null:
return $default(_that.date,_that.courts,_that.events);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  List<CourtRef> courts,  List<ScheduleEvent> events)  $default,) {final _that = this;
switch (_that) {
case _DaySchedule():
return $default(_that.date,_that.courts,_that.events);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  List<CourtRef> courts,  List<ScheduleEvent> events)?  $default,) {final _that = this;
switch (_that) {
case _DaySchedule() when $default != null:
return $default(_that.date,_that.courts,_that.events);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DaySchedule extends DaySchedule {
  const _DaySchedule({required this.date, final  List<CourtRef> courts = const [], final  List<ScheduleEvent> events = const []}): _courts = courts,_events = events,super._();
  factory _DaySchedule.fromJson(Map<String, dynamic> json) => _$DayScheduleFromJson(json);

@override final  String date;
 final  List<CourtRef> _courts;
@override@JsonKey() List<CourtRef> get courts {
  if (_courts is EqualUnmodifiableListView) return _courts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_courts);
}

 final  List<ScheduleEvent> _events;
@override@JsonKey() List<ScheduleEvent> get events {
  if (_events is EqualUnmodifiableListView) return _events;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_events);
}


/// Create a copy of DaySchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DayScheduleCopyWith<_DaySchedule> get copyWith => __$DayScheduleCopyWithImpl<_DaySchedule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DayScheduleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DaySchedule&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other._courts, _courts)&&const DeepCollectionEquality().equals(other._events, _events));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,const DeepCollectionEquality().hash(_courts),const DeepCollectionEquality().hash(_events));

@override
String toString() {
  return 'DaySchedule(date: $date, courts: $courts, events: $events)';
}


}

/// @nodoc
abstract mixin class _$DayScheduleCopyWith<$Res> implements $DayScheduleCopyWith<$Res> {
  factory _$DayScheduleCopyWith(_DaySchedule value, $Res Function(_DaySchedule) _then) = __$DayScheduleCopyWithImpl;
@override @useResult
$Res call({
 String date, List<CourtRef> courts, List<ScheduleEvent> events
});




}
/// @nodoc
class __$DayScheduleCopyWithImpl<$Res>
    implements _$DayScheduleCopyWith<$Res> {
  __$DayScheduleCopyWithImpl(this._self, this._then);

  final _DaySchedule _self;
  final $Res Function(_DaySchedule) _then;

/// Create a copy of DaySchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? courts = null,Object? events = null,}) {
  return _then(_DaySchedule(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,courts: null == courts ? _self._courts : courts // ignore: cast_nullable_to_non_nullable
as List<CourtRef>,events: null == events ? _self._events : events // ignore: cast_nullable_to_non_nullable
as List<ScheduleEvent>,
  ));
}


}


/// @nodoc
mixin _$AvailabilitySlot {

 String get timeSlot; String get startTime; double get startHour; List<CourtRef> get availableCourts;
/// Create a copy of AvailabilitySlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvailabilitySlotCopyWith<AvailabilitySlot> get copyWith => _$AvailabilitySlotCopyWithImpl<AvailabilitySlot>(this as AvailabilitySlot, _$identity);

  /// Serializes this AvailabilitySlot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AvailabilitySlot&&(identical(other.timeSlot, timeSlot) || other.timeSlot == timeSlot)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.startHour, startHour) || other.startHour == startHour)&&const DeepCollectionEquality().equals(other.availableCourts, availableCourts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timeSlot,startTime,startHour,const DeepCollectionEquality().hash(availableCourts));

@override
String toString() {
  return 'AvailabilitySlot(timeSlot: $timeSlot, startTime: $startTime, startHour: $startHour, availableCourts: $availableCourts)';
}


}

/// @nodoc
abstract mixin class $AvailabilitySlotCopyWith<$Res>  {
  factory $AvailabilitySlotCopyWith(AvailabilitySlot value, $Res Function(AvailabilitySlot) _then) = _$AvailabilitySlotCopyWithImpl;
@useResult
$Res call({
 String timeSlot, String startTime, double startHour, List<CourtRef> availableCourts
});




}
/// @nodoc
class _$AvailabilitySlotCopyWithImpl<$Res>
    implements $AvailabilitySlotCopyWith<$Res> {
  _$AvailabilitySlotCopyWithImpl(this._self, this._then);

  final AvailabilitySlot _self;
  final $Res Function(AvailabilitySlot) _then;

/// Create a copy of AvailabilitySlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? timeSlot = null,Object? startTime = null,Object? startHour = null,Object? availableCourts = null,}) {
  return _then(_self.copyWith(
timeSlot: null == timeSlot ? _self.timeSlot : timeSlot // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,startHour: null == startHour ? _self.startHour : startHour // ignore: cast_nullable_to_non_nullable
as double,availableCourts: null == availableCourts ? _self.availableCourts : availableCourts // ignore: cast_nullable_to_non_nullable
as List<CourtRef>,
  ));
}

}


/// Adds pattern-matching-related methods to [AvailabilitySlot].
extension AvailabilitySlotPatterns on AvailabilitySlot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AvailabilitySlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AvailabilitySlot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AvailabilitySlot value)  $default,){
final _that = this;
switch (_that) {
case _AvailabilitySlot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AvailabilitySlot value)?  $default,){
final _that = this;
switch (_that) {
case _AvailabilitySlot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String timeSlot,  String startTime,  double startHour,  List<CourtRef> availableCourts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AvailabilitySlot() when $default != null:
return $default(_that.timeSlot,_that.startTime,_that.startHour,_that.availableCourts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String timeSlot,  String startTime,  double startHour,  List<CourtRef> availableCourts)  $default,) {final _that = this;
switch (_that) {
case _AvailabilitySlot():
return $default(_that.timeSlot,_that.startTime,_that.startHour,_that.availableCourts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String timeSlot,  String startTime,  double startHour,  List<CourtRef> availableCourts)?  $default,) {final _that = this;
switch (_that) {
case _AvailabilitySlot() when $default != null:
return $default(_that.timeSlot,_that.startTime,_that.startHour,_that.availableCourts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AvailabilitySlot extends AvailabilitySlot {
  const _AvailabilitySlot({required this.timeSlot, required this.startTime, required this.startHour, final  List<CourtRef> availableCourts = const []}): _availableCourts = availableCourts,super._();
  factory _AvailabilitySlot.fromJson(Map<String, dynamic> json) => _$AvailabilitySlotFromJson(json);

@override final  String timeSlot;
@override final  String startTime;
@override final  double startHour;
 final  List<CourtRef> _availableCourts;
@override@JsonKey() List<CourtRef> get availableCourts {
  if (_availableCourts is EqualUnmodifiableListView) return _availableCourts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableCourts);
}


/// Create a copy of AvailabilitySlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AvailabilitySlotCopyWith<_AvailabilitySlot> get copyWith => __$AvailabilitySlotCopyWithImpl<_AvailabilitySlot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AvailabilitySlotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AvailabilitySlot&&(identical(other.timeSlot, timeSlot) || other.timeSlot == timeSlot)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.startHour, startHour) || other.startHour == startHour)&&const DeepCollectionEquality().equals(other._availableCourts, _availableCourts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,timeSlot,startTime,startHour,const DeepCollectionEquality().hash(_availableCourts));

@override
String toString() {
  return 'AvailabilitySlot(timeSlot: $timeSlot, startTime: $startTime, startHour: $startHour, availableCourts: $availableCourts)';
}


}

/// @nodoc
abstract mixin class _$AvailabilitySlotCopyWith<$Res> implements $AvailabilitySlotCopyWith<$Res> {
  factory _$AvailabilitySlotCopyWith(_AvailabilitySlot value, $Res Function(_AvailabilitySlot) _then) = __$AvailabilitySlotCopyWithImpl;
@override @useResult
$Res call({
 String timeSlot, String startTime, double startHour, List<CourtRef> availableCourts
});




}
/// @nodoc
class __$AvailabilitySlotCopyWithImpl<$Res>
    implements _$AvailabilitySlotCopyWith<$Res> {
  __$AvailabilitySlotCopyWithImpl(this._self, this._then);

  final _AvailabilitySlot _self;
  final $Res Function(_AvailabilitySlot) _then;

/// Create a copy of AvailabilitySlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? timeSlot = null,Object? startTime = null,Object? startHour = null,Object? availableCourts = null,}) {
  return _then(_AvailabilitySlot(
timeSlot: null == timeSlot ? _self.timeSlot : timeSlot // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,startHour: null == startHour ? _self.startHour : startHour // ignore: cast_nullable_to_non_nullable
as double,availableCourts: null == availableCourts ? _self._availableCourts : availableCourts // ignore: cast_nullable_to_non_nullable
as List<CourtRef>,
  ));
}


}

// dart format on
