import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule.freezed.dart';
part 'schedule.g.dart';

/// Campo così come lo restituiscono griglia e disponibilità.
@freezed
abstract class CourtRef with _$CourtRef {
  const factory CourtRef({required String id, required String name}) =
      _CourtRef;

  factory CourtRef.fromJson(Map<String, dynamic> json) =>
      _$CourtRefFromJson(json);
}

/// Campo con i dettagli di `GET /courts` (tipo e superficie).
@freezed
abstract class Court with _$Court {
  const Court._();

  const factory Court({
    required String id,
    required String name,
    String? type,
    String? surface,
  }) = _Court;

  factory Court.fromJson(Map<String, dynamic> json) => _$CourtFromJson(json);

  /// "outdoor · cemento", vuoto se il circolo non li ha indicati.
  String get details => [
    type,
    surface,
  ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' · ');
}

/// Cosa occupa un campo nella griglia.
enum ScheduleKind { court, lesson, training, match, unknown }

@freezed
abstract class ScheduleEvent with _$ScheduleEvent {
  const ScheduleEvent._();

  const factory ScheduleEvent({
    required String id,
    String? bookingId,
    required String courtId,

    /// `booking` o `match`.
    @Default('booking') String source,
    @JsonKey(unknownEnumValue: ScheduleKind.unknown)
    @Default(ScheduleKind.unknown)
    ScheduleKind kind,
    String? label,

    /// Ore decimali (18.5 = 18:30), intervallo `[inizio, fine)`.
    required double startHour,
    required double endHour,

    /// L'impegno è dell'utente.
    @Default(false) bool isOwner,

    /// L'utente può usarlo (es. aprirci una partita).
    @Default(false) bool canUse,
  }) = _ScheduleEvent;

  factory ScheduleEvent.fromJson(Map<String, dynamic> json) =>
      _$ScheduleEventFromJson(json);

  int get startMinutes => (startHour * 60).round();

  int get endMinutes => (endHour * 60).round();

  bool overlaps(int fromMinutes, int toMinutes) =>
      startMinutes < toMinutes && endMinutes > fromMinutes;
}

/// Griglia di un giorno: campi del circolo e impegni.
@freezed
abstract class DaySchedule with _$DaySchedule {
  const DaySchedule._();

  const factory DaySchedule({
    required String date,
    @Default([]) List<CourtRef> courts,
    @Default([]) List<ScheduleEvent> events,
  }) = _DaySchedule;

  factory DaySchedule.fromJson(Map<String, dynamic> json) =>
      _$DayScheduleFromJson(json);

  List<ScheduleEvent> eventsFor(String courtId) =>
      events.where((e) => e.courtId == courtId).toList()
        ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

  /// Il campo è libero in `[fromMinutes, toMinutes)`.
  bool isFree(String courtId, int fromMinutes, int toMinutes) => !events.any(
    (e) => e.courtId == courtId && e.overlaps(fromMinutes, toMinutes),
  );

  /// Minuti liberi consecutivi da [fromMinutes] fino al prossimo impegno o
  /// alla chiusura.
  int freeMinutesFrom(String courtId, int fromMinutes, int closingMinutes) {
    var end = closingMinutes;
    for (final e in eventsFor(courtId)) {
      if (e.endMinutes <= fromMinutes) continue;
      if (e.startMinutes <= fromMinutes) return 0;
      end = e.startMinutes < end ? e.startMinutes : end;
    }
    return end - fromMinutes;
  }
}

/// Un orario di inizio con i campi liberi per tutta la durata richiesta.
@freezed
abstract class AvailabilitySlot with _$AvailabilitySlot {
  const AvailabilitySlot._();

  const factory AvailabilitySlot({
    required String timeSlot,
    required String startTime,
    required double startHour,
    @Default([]) List<CourtRef> availableCourts,
  }) = _AvailabilitySlot;

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) =>
      _$AvailabilitySlotFromJson(json);

  int get startMinutes => (startHour * 60).round();
}
