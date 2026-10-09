// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CourtRef _$CourtRefFromJson(Map<String, dynamic> json) =>
    _CourtRef(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$CourtRefToJson(_CourtRef instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

_Court _$CourtFromJson(Map<String, dynamic> json) => _Court(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String?,
  surface: json['surface'] as String?,
);

Map<String, dynamic> _$CourtToJson(_Court instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'surface': instance.surface,
};

_ScheduleEvent _$ScheduleEventFromJson(Map<String, dynamic> json) =>
    _ScheduleEvent(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String?,
      courtId: json['court_id'] as String,
      source: json['source'] as String? ?? 'booking',
      kind:
          $enumDecodeNullable(
            _$ScheduleKindEnumMap,
            json['kind'],
            unknownValue: ScheduleKind.unknown,
          ) ??
          ScheduleKind.unknown,
      label: json['label'] as String?,
      startHour: (json['start_hour'] as num).toDouble(),
      endHour: (json['end_hour'] as num).toDouble(),
      isOwner: json['is_owner'] as bool? ?? false,
      canUse: json['can_use'] as bool? ?? false,
    );

Map<String, dynamic> _$ScheduleEventToJson(_ScheduleEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'booking_id': instance.bookingId,
      'court_id': instance.courtId,
      'source': instance.source,
      'kind': _$ScheduleKindEnumMap[instance.kind]!,
      'label': instance.label,
      'start_hour': instance.startHour,
      'end_hour': instance.endHour,
      'is_owner': instance.isOwner,
      'can_use': instance.canUse,
    };

const _$ScheduleKindEnumMap = {
  ScheduleKind.court: 'court',
  ScheduleKind.lesson: 'lesson',
  ScheduleKind.training: 'training',
  ScheduleKind.match: 'match',
  ScheduleKind.unknown: 'unknown',
};

_DaySchedule _$DayScheduleFromJson(Map<String, dynamic> json) => _DaySchedule(
  date: json['date'] as String,
  courts:
      (json['courts'] as List<dynamic>?)
          ?.map((e) => CourtRef.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  events:
      (json['events'] as List<dynamic>?)
          ?.map((e) => ScheduleEvent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$DayScheduleToJson(_DaySchedule instance) =>
    <String, dynamic>{
      'date': instance.date,
      'courts': instance.courts.map((e) => e.toJson()).toList(),
      'events': instance.events.map((e) => e.toJson()).toList(),
    };

_AvailabilitySlot _$AvailabilitySlotFromJson(Map<String, dynamic> json) =>
    _AvailabilitySlot(
      timeSlot: json['time_slot'] as String,
      startTime: json['start_time'] as String,
      startHour: (json['start_hour'] as num).toDouble(),
      availableCourts:
          (json['available_courts'] as List<dynamic>?)
              ?.map((e) => CourtRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AvailabilitySlotToJson(
  _AvailabilitySlot instance,
) => <String, dynamic>{
  'time_slot': instance.timeSlot,
  'start_time': instance.startTime,
  'start_hour': instance.startHour,
  'available_courts': instance.availableCourts.map((e) => e.toJson()).toList(),
};
