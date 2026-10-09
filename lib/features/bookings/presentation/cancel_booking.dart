import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/utils/dates.dart';
import '../../matches/presentation/day_matches_provider.dart';
import '../data/bookings_repository.dart';
import '../domain/booking.dart';
import 'book_providers.dart';
import 'upcoming_bookings_provider.dart';

/// Chiede conferma e annulla una propria prenotazione futura.
/// Restituisce `true` se l'annullamento è riuscito.
Future<bool> confirmAndCancelBooking(
  BuildContext context,
  WidgetRef ref, {
  required String bookingId,
  required DateTime date,
  required String description,
  bool hasOpenMatch = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Annullare la prenotazione?'),
      content: Text(
        hasOpenMatch
            ? '$description\n\nAnche la partita aperta su questa prenotazione '
                  'verrà annullata.'
            : description,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('No, tienila'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Annulla prenotazione'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return false;
  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(bookingsRepositoryProvider).cancel(bookingId);
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          e is ApiException ? e.message : 'Annullamento non riuscito',
        ),
      ),
    );
    return false;
  }
  ref
    ..invalidate(upcomingBookingsProvider)
    ..invalidate(scheduleProvider(dateOnly(date)))
    ..invalidate(availabilityProvider)
    ..invalidate(dayMatchesProvider(dateOnly(date)));
  messenger.showSnackBar(
    const SnackBar(content: Text('Prenotazione annullata')),
  );
  return true;
}

/// Descrizione breve, es. "Campo 2 · Gio 8 ott · 18:30–20:00".
String bookingDescription(Booking booking) => [
  booking.courtName,
  Dates.shortDay(booking.date),
  booking.slot?.label ?? booking.timeSlot,
].where((s) => s.isNotEmpty).join(' · ');
