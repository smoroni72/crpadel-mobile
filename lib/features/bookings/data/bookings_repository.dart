import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/utils/dates.dart';
import '../domain/booking.dart';
import '../domain/booking_request.dart';
import '../domain/coach.dart';
import '../domain/schedule.dart';

final bookingsRepositoryProvider = Provider<BookingsRepository>(
  (ref) => ApiBookingsRepository(ref.watch(apiClientProvider)),
);

/// Orari della griglia (`opening_hour`, `closing_hour` di `/bookings/schedule`).
const openingMinutes = 7 * 60;
const closingMinutes = 23 * 60;

abstract interface class BookingsRepository {
  /// Prenotazioni confermate dell'utente non ancora terminate, dalla più
  /// vicina.
  Future<List<Booking>> upcoming({
    required String playerEmail,
    required DateTime now,
  });

  /// Griglia del giorno: campi e impegni.
  Future<DaySchedule> schedule(DateTime day);

  /// Orari di inizio con i campi liberi per [slotMinutes] (60 o 90).
  Future<List<AvailabilitySlot>> availability(
    DateTime day, {
    required int slotMinutes,
  });

  /// Campi del circolo con tipo e superficie.
  Future<List<Court>> courts();

  /// Istruttori attivi, per lezioni e allenamenti.
  Future<List<Coach>> coaches();

  /// Crea la prenotazione. Lancia `ApiException` con `statusCode` 409 se lo
  /// spazio è stato occupato nel frattempo.
  Future<Booking> create(NewBooking request);

  /// Annulla una propria prenotazione (annulla anche la partita se aperta).
  Future<void> cancel(String bookingId);
}

class ApiBookingsRepository implements BookingsRepository {
  ApiBookingsRepository(this._api);
  final ApiClient _api;

  /// L'API non filtra per data: chiediamo le più recenti e scartiamo le
  /// passate. 100 basta per le prenotazioni future di un giocatore.
  static const _limit = 100;

  @override
  Future<List<Booking>> upcoming({
    required String playerEmail,
    required DateTime now,
  }) async {
    final response = await _api.get(
      '/bookings',
      query: {
        'status': 'confirmed',
        'sort': '-date',
        'limit': _limit,
        // Per un giocatore l'API filtra già sull'utente; per un admin del
        // circolo serve questo filtro, altrimenti arrivano tutte.
        'player_email': playerEmail,
      },
    );
    final bookings = _list(response.data)
        .map(Booking.fromJson)
        .where((booking) => booking.end.isAfter(now))
        .toList();
    bookings.sort((a, b) => a.start.compareTo(b.start));
    return bookings;
  }

  @override
  Future<DaySchedule> schedule(DateTime day) async {
    final response = await _api.get(
      '/bookings/schedule',
      query: {
        'date': Dates.api(day),
        'opening_hour': openingMinutes ~/ 60,
        'closing_hour': closingMinutes ~/ 60,
      },
    );
    return DaySchedule.fromJson(_data(response.data));
  }

  @override
  Future<List<AvailabilitySlot>> availability(
    DateTime day, {
    required int slotMinutes,
  }) async {
    final response = await _api.get(
      '/bookings/availability',
      query: {
        'from': Dates.api(day),
        'days': 1,
        'slot_minutes': slotMinutes,
        'opening_hour': openingMinutes ~/ 60,
        'closing_hour': closingMinutes ~/ 60,
      },
    );
    final days = _data(response.data)['days'] as List<dynamic>;
    if (days.isEmpty) return const [];
    return ((days.first as Map<String, dynamic>)['slots'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(AvailabilitySlot.fromJson)
        .toList();
  }

  @override
  Future<List<Court>> courts() async {
    final response = await _api.get('/courts', query: {'limit': 200});
    return _list(response.data).map(Court.fromJson).toList();
  }

  @override
  Future<List<Coach>> coaches() async {
    final response = await _api.get(
      '/coaches',
      query: {'is_active': 'true', 'limit': 200},
    );
    return _list(response.data).map(Coach.fromJson).toList();
  }

  @override
  Future<Booking> create(NewBooking request) async {
    final response = await _api.post('/bookings', data: request.toJson());
    return Booking.fromJson(_data(response.data));
  }

  @override
  Future<void> cancel(String bookingId) async {
    await _api.patch('/bookings/$bookingId', data: {'status': 'cancelled'});
  }
}

Map<String, dynamic> _data(Object? body) =>
    (body as Map<String, dynamic>)['data'] as Map<String, dynamic>;

List<Map<String, dynamic>> _list(Object? body) =>
    ((body as Map<String, dynamic>)['data'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
