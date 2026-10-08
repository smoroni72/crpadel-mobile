import '../domain/booking.dart';
import 'bookings_repository.dart';

/// Repository in memoria per test e sviluppo senza backend.
class FakeBookingsRepository implements BookingsRepository {
  FakeBookingsRepository([this.bookings = const [], this.error]);

  List<Booking> bookings;

  /// Se impostato, ogni chiamata fallisce con questo errore.
  Object? error;

  @override
  Future<List<Booking>> upcoming({
    required String playerEmail,
    required DateTime now,
  }) async {
    if (error != null) throw error!;
    return bookings
        .where((b) => b.status == BookingStatus.confirmed && b.end.isAfter(now))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }
}
