import 'package:freezed_annotation/freezed_annotation.dart';

part 'directory_player.freezed.dart';
part 'directory_player.g.dart';

/// Giocatore della rubrica del circolo (`GET /players/directory`).
@freezed
abstract class DirectoryPlayer with _$DirectoryPlayer {
  const factory DirectoryPlayer({
    required String id,
    required String fullName,

    /// `member` (iscritto all'app) o `guest`.
    String? registrationStatus,

    /// È l'utente stesso.
    @Default(false) bool isSelf,
    String? rankingBandName,
    String? rankingBandColor,
  }) = _DirectoryPlayer;

  factory DirectoryPlayer.fromJson(Map<String, dynamic> json) =>
      _$DirectoryPlayerFromJson(json);
}

/// Dati per `POST /matches`, aperta sulla prenotazione appena creata.
class NewMatch {
  const NewMatch({
    required this.bookingId,
    required this.date,
    required this.courtId,
    required this.timeSlot,
    required this.matchType,
    this.players = const [],
  });

  final String bookingId;

  /// `YYYY-MM-DD`
  final String date;
  final String courtId;
  final String timeSlot;

  /// `ranking` o `friendly`.
  final String matchType;

  /// In ordine di posizione: 0–1 squadra A, 2–3 squadra B.
  final List<DirectoryPlayer> players;

  Map<String, dynamic> toJson() => {
    'booking_id': bookingId,
    'date': date,
    'court_id': courtId,
    'time_slot': timeSlot,
    'match_type': matchType,
    'level': 'qualsiasi',
    'max_players': 4,
    'players': [
      for (final p in players) {'club_player_id': p.id, 'name': p.fullName},
    ],
  };
}
