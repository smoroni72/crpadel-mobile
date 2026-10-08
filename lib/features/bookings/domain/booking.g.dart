// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Booking _$BookingFromJson(Map<String, dynamic> json) => _Booking(
  id: json['id'] as String,
  courtId: json['court_id'] as String?,
  courtName: json['court_name'] as String? ?? '',
  date: DateTime.parse(json['date'] as String),
  timeSlot: json['time_slot'] as String,
  status:
      $enumDecodeNullable(
        _$BookingStatusEnumMap,
        json['status'],
        unknownValue: BookingStatus.unknown,
      ) ??
      BookingStatus.unknown,
  bookingType:
      $enumDecodeNullable(
        _$BookingTypeEnumMap,
        json['booking_type'],
        unknownValue: BookingType.court,
      ) ??
      BookingType.court,
  coachName: json['coach_name'] as String?,
  playerEmail: json['player_email'] as String?,
);

Map<String, dynamic> _$BookingToJson(_Booking instance) => <String, dynamic>{
  'id': instance.id,
  'court_id': instance.courtId,
  'court_name': instance.courtName,
  'date': instance.date.toIso8601String(),
  'time_slot': instance.timeSlot,
  'status': _$BookingStatusEnumMap[instance.status]!,
  'booking_type': _$BookingTypeEnumMap[instance.bookingType]!,
  'coach_name': instance.coachName,
  'player_email': instance.playerEmail,
};

const _$BookingStatusEnumMap = {
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.completed: 'completed',
  BookingStatus.unknown: 'unknown',
};

const _$BookingTypeEnumMap = {
  BookingType.court: 'court',
  BookingType.lesson: 'lesson',
  BookingType.training: 'training',
};
