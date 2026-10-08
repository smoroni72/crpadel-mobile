import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dates.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../matches/domain/padel_match.dart';
import '../../../matches/presentation/match_labels.dart';
import '../../domain/booking.dart';
import '../upcoming_bookings_provider.dart';

/// Card di una prenotazione futura in "Le tue prenotazioni".
class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.item});

  final UpcomingBooking item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final booking = item.booking;
    final textStyle = TextStyle(
      color: colors.primaryText,
      fontWeight: FontWeight.w600,
    );
    return InfoCard(
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
