import '../../../core/network/api_client.dart';
import '../../../core/utils/dates.dart';
import '../domain/booking.dart';
import '../domain/booking_request.dart';
import '../domain/coach.dart';
import '../domain/schedule.dart';
import 'bookings_repository.dart';

/// Repository in memoria per test e sviluppo senza backend.
///
/// La griglia nasce dalle prenotazioni in [bookings] più gli impegni altrui
/// in [otherEvents]; prenotare aggiunge una prenotazione e rispetta le
/// sovrapposizioni come il server (409).
class FakeBookingsRepository implements BookingsRepository {
  FakeBookingsRepository([List<Booking> bookings = const [], this.error])
    : bookings = [...bookings];

  List<Booking> bookings;

  /// Se impostato, ogni chiamata fallisce con questo errore.
  Object? error;

  List<Court> courtList = const [
    Court(id: 'c1', name: 'Campo 1', type: 'outdoor', surface: 'cemento'),
    Court(id: 'c2', name: 'Campo 2', type: 'indoor', surface: 'erba'),
    Court(id: 'c3', name: 'Campo 3', type: 'outdoor', surface: 'cemento'),
  ];

  List<Coach> coachList = const [
    Coach(id: 'k1', name: 'Luca Bianchi'),
    Coach(id: 'k2', name: 'Sara Neri'),
  ];

  /// Impegni di altri giocatori, per giorno (`YYYY-MM-DD`).
  Map<String, List<ScheduleEvent>> otherEvents = {};

  /// Simula uno spazio occupato da qualcun altro proprio prima della
  /// conferma.
  bool conflictOnCreate = false;

  final created = <NewBooking>[];
  final cancelled = <String>[];
  var _nextId = 1;

  void _check() {
    if (error != null) throw error!;
  }

  @override
  Future<List<Booking>> upcoming({
    required String playerEmail,
    required DateTime now,
  }) async {
    _check();
    return bookings
        .where((b) => b.status == BookingStatus.confirmed && b.end.isAfter(now))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  @override
  Future<DaySchedule> schedule(DateTime day) async {
    _check();
    final key = Dates.api(day);
    final mine = bookings
        .where(
          (b) =>
              b.status == BookingStatus.confirmed &&
              Dates.api(b.date) == key &&
              b.slot != null,
        )
        .map(
          (b) => ScheduleEvent(
            id: b.id,
            bookingId: b.id,
            courtId: b.courtId ?? '',
            kind: switch (b.bookingType) {
              BookingType.court => ScheduleKind.court,
              BookingType.lesson => ScheduleKind.lesson,
              BookingType.training => ScheduleKind.training,
            },
            startHour: b.slot!.startMinutes / 60,
            endHour: b.slot!.endMinutes / 60,
            isOwner: true,
            canUse: true,
          ),
        );
    return DaySchedule(
      date: key,
      courts: [for (final c in courtList) CourtRef(id: c.id, name: c.name)],
      events: [...mine, ...?otherEvents[key]],
    );
  }

  @override
  Future<List<AvailabilitySlot>> availability(
    DateTime day, {
    required int slotMinutes,
  }) async {
    final grid = await schedule(day);
    return [
      for (
        var start = openingMinutes;
        start + slotMinutes <= closingMinutes;
        start += 30
      )
        AvailabilitySlot(
          timeSlot: '${hhmm(start)}-${hhmm(start + slotMinutes)}',
          startTime: hhmm(start),
          startHour: start / 60,
          availableCourts: [
            for (final c in grid.courts)
              if (grid.isFree(c.id, start, start + slotMinutes)) c,
          ],
        ),
    ];
  }

  @override
  Future<List<Court>> courts() async {
    _check();
    return courtList;
  }

  @override
  Future<List<Coach>> coaches() async {
    _check();
    return coachList;
  }

  @override
  Future<Booking> create(NewBooking request) async {
    _check();
    final grid = await schedule(request.date);
    if (conflictOnCreate ||
        !grid.isFree(
          request.courtId,
          request.startMinutes,
          request.endMinutes,
        )) {
      throw const ApiException(
        'La fascia oraria è già occupata',
        statusCode: 409,
      );
    }
    created.add(request);
    final booking = Booking(
      id: 'nuova-${_nextId++}',
      courtId: request.courtId,
      courtName: courtList.firstWhere((c) => c.id == request.courtId).name,
      date: DateTime(request.date.year, request.date.month, request.date.day),
      timeSlot: request.timeSlot,
      status: BookingStatus.confirmed,
      bookingType: request.type,
    );
    bookings.add(booking);
    return booking;
  }

  @override
  Future<void> cancel(String bookingId) async {
    _check();
    cancelled.add(bookingId);
    bookings = [
      for (final b in bookings)
        b.id == bookingId ? b.copyWith(status: BookingStatus.cancelled) : b,
    ];
  }
}
