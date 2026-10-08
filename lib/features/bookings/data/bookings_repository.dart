import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../domain/booking.dart';

final bookingsRepositoryProvider = Provider<BookingsRepository>(
  (ref) => ApiBookingsRepository(ref.watch(apiClientProvider)),
);

abstract interface class BookingsRepository {
  /// Prenotazioni confermate dell'utente non ancora terminate, dalla più
  /// vicina.
  Future<List<Booking>> upcoming({
    required String playerEmail,
    required DateTime now,
  });
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
}

List<Map<String, dynamic>> _list(Object? body) =>
    ((body as Map<String, dynamic>)['data'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
