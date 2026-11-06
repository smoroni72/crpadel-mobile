import 'package:freezed_annotation/freezed_annotation.dart';

import 'padel_match.dart';

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
    this.level = 'qualsiasi',
    this.players = const [],
    this.teamsByPlayerId = const {},
  });

  /// Prenotazione collegata, assente per le partite registrate direttamente
  /// dall'amministrazione dopo che sono state disputate.
  final String? bookingId;

  /// `YYYY-MM-DD`
  final String date;
  final String courtId;
  final String timeSlot;

  /// `ranking` o `friendly`.
  final String matchType;

  /// `principiante`, `intermedio`, `avanzato` o `qualsiasi`.
  final String level;

  /// In ordine di posizione: 0–1 squadra A, 2–3 squadra B.
  final List<DirectoryPlayer> players;

  /// Squadra scelta nella griglia, indicizzata per giocatore.
  final Map<String, String> teamsByPlayerId;

  Map<String, dynamic> toJson() => {
    if (bookingId != null) 'booking_id': bookingId,
    'date': date,
    'court_id': courtId,
    'time_slot': timeSlot,
    'match_type': matchType,
    'level': level,
    'max_players': 4,
    'players': [
      for (final p in players)
        {
          'club_player_id': p.id,
          'name': p.fullName,
          if (teamsByPlayerId[p.id] != null) 'team': teamsByPlayerId[p.id],
        },
    ],
  };
}

class UpdateMatch {
  const UpdateMatch({
    required this.date,
    required this.courtId,
    required this.timeSlot,
    this.players,
  });

  final String date;
  final String courtId;
  final String timeSlot;
  final List<MatchPlayer>? players;

  Map<String, dynamic> toJson() => {
    'date': date,
    'court_id': courtId,
    'time_slot': timeSlot,
    if (players != null)
      'players': [
        for (var index = 0; index < players!.length; index++)
          {
            if (players![index].clubPlayerId != null)
              'club_player_id': players![index].clubPlayerId,
            'name': players![index].name,
            'team': index < 2 ? 'A' : 'B',
            if (players![index].playingSide != null)
              'playing_side': players![index].playingSide,
          },
      ],
  };
}
