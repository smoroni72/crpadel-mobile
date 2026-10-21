import '../../bookings/domain/booking.dart';
import '../../matches/domain/padel_match.dart';
import '../../subscriptions/domain/player_subscription.dart';
import '../domain/profile_models.dart';

String bookingStatusLabel(BookingStatus status) => switch (status) {
  BookingStatus.confirmed => 'Confermata',
  BookingStatus.cancelled => 'Cancellata',
  BookingStatus.completed => 'Completata',
  BookingStatus.unknown => '',
};

String lessonStatusLabel(LessonStatus status) => switch (status) {
  LessonStatus.confirmed => 'Confermata',
  LessonStatus.cancelled => 'Cancellata',
  LessonStatus.completed => 'Completata',
  LessonStatus.unknown => '',
};

/// Stato breve in italiano (il sito oggi mostra il codice dell'API).
String matchStatusShort(MatchStatus status) => switch (status) {
  MatchStatus.open => 'Aperta',
  MatchStatus.inProgress => 'In corso',
  MatchStatus.pendingResult => 'Risultato atteso',
  MatchStatus.completed => 'Completata',
  MatchStatus.notPlayed => 'Non disputata',
  MatchStatus.cancelled => 'Annullata',
  MatchStatus.unknown => '',
};

/// Come il sito: "Da attivare", "Attivo"…
String subscriptionStatusLabel(SubscriptionStatus status) => switch (status) {
  SubscriptionStatus.pendingActivation => 'Da attivare',
  SubscriptionStatus.active => 'Attivo',
  SubscriptionStatus.expired => 'Scaduto',
  SubscriptionStatus.exhausted => 'Esaurito',
  SubscriptionStatus.cancelled => 'Annullato',
  SubscriptionStatus.refunded => 'Rimborsato',
  SubscriptionStatus.unknown => '',
};

String weekdayName(int weekday) => const [
  'Lunedì',
  'Martedì',
  'Mercoledì',
  'Giovedì',
  'Venerdì',
  'Sabato',
  'Domenica',
][(weekday - 1).clamp(0, 6)];

String movementLabel(MovementType type) => switch (type) {
  MovementType.purchase => 'Acquisto',
  MovementType.reservation => 'Riserva',
  MovementType.consumption => 'Partita giocata',
  MovementType.release => 'Riserva rilasciata',
  MovementType.other => 'Movimento',
};

String matchTypeCodeLabel(String code) => switch (code) {
  'ranking' => 'Ranking',
  'friendly' => 'Amichevole',
  'tournament' => 'Torneo',
  _ => 'Altro',
};
