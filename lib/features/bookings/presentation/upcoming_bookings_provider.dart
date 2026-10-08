import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../matches/data/matches_repository.dart';
import '../../matches/domain/padel_match.dart';
import '../data/bookings_repository.dart';
import '../domain/booking.dart';

/// Prenotazione futura con l'eventuale partita aperta sopra.
class UpcomingBooking {
  const UpcomingBooking(this.booking, [this.match]);
  final Booking booking;
  final PadelMatch? match;
}

final upcomingBookingsProvider = FutureProvider<List<UpcomingBooking>>((
  ref,
) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return const [];
  final now = ref.read(clockProvider)();
  final (bookings, matches) = await (
    ref
        .read(bookingsRepositoryProvider)
        .upcoming(playerEmail: user.email, now: now),
    ref.read(matchesRepositoryProvider).mine(email: user.email),
  ).wait;
  final matchByBooking = {
    for (final match in matches)
      if (match.bookingId != null && match.status != MatchStatus.cancelled)
        match.bookingId!: match,
  };
  return [
    for (final booking in bookings)
      UpcomingBooking(booking, matchByBooking[booking.id]),
  ];
});
