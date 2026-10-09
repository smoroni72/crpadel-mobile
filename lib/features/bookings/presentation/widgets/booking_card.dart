import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dates.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../matches/domain/padel_match.dart';
import '../../../matches/presentation/match_labels.dart';
import '../../domain/booking.dart';
import '../cancel_booking.dart';
import '../upcoming_bookings_provider.dart';

/// Card di una prenotazione futura in "Le tue prenotazioni".
class BookingCard extends ConsumerWidget {
  const BookingCard({super.key, required this.item});

  final UpcomingBooking item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final booking = item.booking;
    final textStyle = TextStyle(
      color: colors.primaryText,
      fontWeight: FontWeight.w600,
    );
    return InfoCard(
      onTap: () => _showActions(context, ref),
      leading: LeadingBox(
        background: colors.primaryTint,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Dates.weekdayBadge(booking.date),
              style: textStyle.copyWith(fontSize: 11),
            ),
            Text(
              '${booking.date.day}',
              style: context.fonts
                  .monoStyle(fontSize: 18, fontWeight: FontWeight.w600)
                  .copyWith(color: colors.primaryText),
            ),
          ],
        ),
      ),
      title:
          '${booking.courtName} · ${booking.slot?.label ?? booking.timeSlot}',
      subtitle: _subtitle(booking, item.match),
    );
  }

  Future<void> _showActions(BuildContext context, WidgetRef ref) async {
    final booking = item.booking;
    final description = bookingDescription(booking);
    final cancel = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(description, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(_subtitle(booking, item.match)),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.pop(context, true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.primaryText,
                ),
                child: const Text('Annulla prenotazione'),
              ),
            ],
          ),
        ),
      ),
    );
    if (cancel != true || !context.mounted) return;
    await confirmAndCancelBooking(
      context,
      ref,
      bookingId: booking.id,
      date: booking.date,
      description: description,
      hasOpenMatch: item.match?.status == MatchStatus.open,
    );
  }

  static String _subtitle(Booking booking, PadelMatch? match) {
    if (match != null) {
      return switch (match.status) {
        MatchStatus.open when match.hasFreeSpots =>
          'Partita aperta · ${match.playersLabel}',
        MatchStatus.open => 'Partita al completo · ${match.playersLabel}',
        _ => 'Partita · ${match.statusLabel.toLowerCase()}',
      };
    }
    final coach = booking.coachName;
    return switch (booking.bookingType) {
      BookingType.lesson => coach == null ? 'Lezione' : 'Lezione · $coach',
      BookingType.training =>
        coach == null ? 'Allenamento' : 'Allenamento · $coach',
      BookingType.court => 'Campo prenotato',
    };
  }
}
