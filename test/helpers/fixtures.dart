import 'package:crpadel_mobile/features/bookings/domain/booking.dart';
import 'package:crpadel_mobile/features/matches/domain/padel_match.dart';
import 'package:crpadel_mobile/features/subscriptions/domain/player_subscription.dart';

/// "Oggi" nei test: mercoledì 7 ottobre 2026, ore 12.
final testNow = DateTime(2026, 10, 7, 12);

const myId = 'user-1';

Booking booking({
  String id = 'b1',
  DateTime? date,
  String slot = '18:30-20:00',
  String court = 'Campo 2',
  BookingType type = BookingType.court,
  BookingStatus status = BookingStatus.confirmed,
  String? coach,
}) => Booking(
  id: id,
  courtName: court,
  date: date ?? DateTime(2026, 10, 8),
  timeSlot: slot,
  status: status,
  bookingType: type,
  coachName: coach,
);

MatchPlayer player(String name, {String? userId}) =>
    MatchPlayer(name: name, userId: userId);

PadelMatch match({
  String id = 'm1',
  String? bookingId,
  DateTime? date,
  String slot = '19:00-20:30',
  String court = 'Campo 3',
  MatchStatus status = MatchStatus.open,
  MatchType type = MatchType.ranking,
  MatchLevel level = MatchLevel.intermedio,
  String? organizerRef = 'altro',
  List<MatchPlayer> players = const [],
  String? score,
}) => PadelMatch(
  id: id,
  bookingId: bookingId,
  date: date ?? DateTime(2026, 10, 7),
  timeSlot: slot,
  courtName: court,
  status: status,
  matchType: type,
  level: level,
  organizerRef: organizerRef,
  players: players,
  scoreTeam1: score,
);

PlayerSubscription package({
  int total = 10,
  int available = 6,
  DateTime? expiresAt,
  SubscriptionStatus status = SubscriptionStatus.active,
}) => PlayerSubscription(
  id: 's1',
  planName: 'Mattina 10',
  planType: PlanType.package,
  status: status,
  matchesTotal: total,
  matchesAvailable: available,
  expiresAt: expiresAt ?? DateTime(2026, 12, 12),
);
