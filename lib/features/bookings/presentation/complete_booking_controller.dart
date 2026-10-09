import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/utils/dates.dart';
import '../../matches/data/matches_repository.dart';
import '../../matches/domain/directory_player.dart';
import '../../matches/presentation/day_matches_provider.dart';
import '../data/bookings_repository.dart';
import '../domain/booking.dart';
import '../domain/booking_request.dart';
import '../domain/schedule.dart';
import 'book_providers.dart';
import 'upcoming_bookings_provider.dart';

/// Spazio libero scelto nella griglia o nei campi liberi.
class BookingSlot {
  const BookingSlot({
    required this.court,
    required this.date,
    required this.startMinutes,
    required this.freeMinutes,
  });

  final CourtRef court;
  final DateTime date;
  final int startMinutes;

  /// Minuti liberi da [startMinutes] al prossimo impegno o alla chiusura.
  final int freeMinutes;

  @override
  bool operator ==(Object other) =>
      other is BookingSlot &&
      other.court == court &&
      other.date == date &&
      other.startMinutes == startMinutes &&
      other.freeMinutes == freeMinutes;

  @override
  int get hashCode => Object.hash(court, date, startMinutes, freeMinutes);
}

class CompleteBookingState {
  const CompleteBookingState({
    this.type = BookingType.court,
    this.coachId,
    this.players = const [null, null, null, null],
    this.matchType = 'ranking',
    this.submitting = false,
    this.error,
  });

  final BookingType type;
  final String? coachId;

  /// 4 posti: 0–1 squadra A, 2–3 squadra B.
  final List<DirectoryPlayer?> players;
  final String matchType;
  final bool submitting;

  /// Messaggio da mostrare sotto il pulsante di conferma.
  final String? error;

  int get playerCount => players.whereType<DirectoryPlayer>().length;

  bool get playsToo => players.any((p) => p?.isSelf ?? false);

  CompleteBookingState copyWith({
    BookingType? type,
    String? Function()? coachId,
    List<DirectoryPlayer?>? players,
    String? matchType,
    bool? submitting,
    String? Function()? error,
  }) => CompleteBookingState(
    type: type ?? this.type,
    coachId: coachId != null ? coachId() : this.coachId,
    players: players ?? this.players,
    matchType: matchType ?? this.matchType,
    submitting: submitting ?? this.submitting,
    error: error != null ? error() : this.error,
  );
}

/// Esito della conferma, per decidere dove portare l'utente.
sealed class BookingOutcome {
  const BookingOutcome();
}

/// Prenotazione (e partita, se richiesta) create.
class BookingConfirmed extends BookingOutcome {
  const BookingConfirmed(this.booking);
  final Booking booking;
}

/// Lo spazio è stato occupato nel frattempo (409): si torna alla griglia.
class BookingConflict extends BookingOutcome {
  const BookingConflict(this.message);
  final String message;
}

/// La prenotazione c'è, ma la partita non è stata aperta.
class MatchNotOpened extends BookingOutcome {
  const MatchNotOpened(this.booking, this.message);
  final Booking booking;
  final String message;
}

final completeBookingProvider = NotifierProvider.autoDispose
    .family<CompleteBookingController, CompleteBookingState, BookingSlot>(
      CompleteBookingController.new,
    );

class CompleteBookingController extends Notifier<CompleteBookingState> {
  CompleteBookingController(this.slot);

  final BookingSlot slot;

  @override
  CompleteBookingState build() => CompleteBookingState(
    // Se non c'è spazio per 90' si parte dalla lezione da 60'.
    type: slot.freeMinutes >= BookingType.court.minutes
        ? BookingType.court
        : BookingType.lesson,
  );

  bool get fits => state.type.minutes <= slot.freeMinutes;

  bool get canSubmit =>
      !state.submitting &&
      fits &&
      (!state.type.needsCoach || state.coachId != null);

  void setType(BookingType type) =>
      state = state.copyWith(type: type, error: () => null);

  void setCoach(String? coachId) =>
      state = state.copyWith(coachId: () => coachId, error: () => null);

  void setMatchType(String code) => state = state.copyWith(matchType: code);

  /// Mette o toglie l'utente dal primo posto libero ("Gioco anch'io").
  void setPlaysToo(bool value, DirectoryPlayer? self) {
    final players = [...state.players];
    if (value) {
      if (self == null || state.playsToo) return;
      final free = players.indexOf(null);
      if (free < 0) return;
      players[free] = self;
    } else {
      for (var i = 0; i < players.length; i++) {
        if (players[i]?.isSelf ?? false) players[i] = null;
      }
    }
    state = state.copyWith(players: players);
  }

  void setPlayer(int position, DirectoryPlayer? player) {
    final players = [...state.players];
    if (player != null && players.any((p) => p?.id == player.id)) return;
    players[position] = player;
    state = state.copyWith(players: players);
  }

  Future<BookingOutcome?> submit() async {
    if (!canSubmit) return null;
    state = state.copyWith(submitting: true, error: () => null);
    final request = NewBooking(
      courtId: slot.court.id,
      date: slot.date,
      startMinutes: slot.startMinutes,
      type: state.type,
      coachId: state.type.needsCoach ? state.coachId : null,
    );
    final Booking booking;
    try {
      booking = await ref.read(bookingsRepositoryProvider).create(request);
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        _refresh();
        state = state.copyWith(submitting: false);
        return BookingConflict(e.message);
      }
      state = state.copyWith(submitting: false, error: () => e.message);
      return null;
    } catch (_) {
      state = state.copyWith(
        submitting: false,
        error: () => 'Prenotazione non riuscita. Controlla la connessione.',
      );
      return null;
    }

    BookingOutcome outcome = BookingConfirmed(booking);
    if (state.type == BookingType.court) {
      try {
        await ref
            .read(matchesRepositoryProvider)
            .create(
              NewMatch(
                bookingId: booking.id,
                date: Dates.api(slot.date),
                courtId: slot.court.id,
                timeSlot: request.timeSlot,
                matchType: state.matchType,
                players: state.players.whereType<DirectoryPlayer>().toList(),
              ),
            );
      } catch (e) {
        outcome = MatchNotOpened(
          booking,
          e is ApiException ? e.message : 'Partita non aperta',
        );
      }
    }
    _refresh();
    if (ref.mounted) state = state.copyWith(submitting: false);
    return outcome;
  }

  void _refresh() {
    ref.invalidate(scheduleProvider(slot.date));
    ref.invalidate(availabilityProvider);
    ref.invalidate(upcomingBookingsProvider);
    ref.invalidate(dayMatchesProvider(slot.date));
  }
}
