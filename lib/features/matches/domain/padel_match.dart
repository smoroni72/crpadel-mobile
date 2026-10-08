import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/time_slot.dart';

part 'padel_match.freezed.dart';
part 'padel_match.g.dart';

/// Stato calcolato dal server: il client non lo ricalcola.
@JsonEnum(fieldRename: FieldRename.snake)
enum MatchStatus {
  open,
  inProgress,
  pendingResult,
  completed,
  notPlayed,
  cancelled,
  unknown,
}

enum MatchType { ranking, friendly, tournament, unknown }

enum MatchLevel { principiante, intermedio, avanzato, qualsiasi }

@freezed
abstract class MatchPlayer with _$MatchPlayer {
  const factory MatchPlayer({
    String? userId,
    String? playerRef,
    required String name,
    String? participantType,
  }) = _MatchPlayer;

  factory MatchPlayer.fromJson(Map<String, dynamic> json) =>
      _$MatchPlayerFromJson(json);
}

/// Partita di padel (`Match` è già un tipo di `dart:core`).
@freezed
abstract class PadelMatch with _$PadelMatch {
  const PadelMatch._();

  const factory PadelMatch({
    required String id,
    String? bookingId,
    required DateTime date,
    @Default('') String courtName,
    required String timeSlot,
    @JsonKey(unknownEnumValue: MatchStatus.unknown)
    @Default(MatchStatus.unknown)
    MatchStatus status,
    @JsonKey(unknownEnumValue: MatchType.unknown)
    @Default(MatchType.unknown)
    MatchType matchType,
    @JsonKey(unknownEnumValue: MatchLevel.qualsiasi)
    @Default(MatchLevel.qualsiasi)
    MatchLevel level,

    /// Id dell'organizzatore se registrato, altrimenti un hash dell'email.
    String? organizerRef,
    String? organizerName,
    @Default(4) int maxPlayers,

    /// Punteggio dal punto di vista della squadra A, es. `"6-4 6-3"`.
    String? scoreTeam1,
    String? winnerTeam,

    /// In ordine di posizione: 0–1 squadra A, 2–3 squadra B.
    @Default([]) List<MatchPlayer> players,
  }) = _PadelMatch;

  factory PadelMatch.fromJson(Map<String, dynamic> json) =>
      _$PadelMatchFromJson(json);

  TimeSlot? get slot => TimeSlot.tryParse(timeSlot);

  DateTime get start => slot?.startOn(date) ?? date;

  bool get hasFreeSpots =>
      status == MatchStatus.open && players.length < maxPlayers;

  /// L'utente organizza la partita o ci gioca.
  bool involves(String userId) =>
      organizerRef == userId || players.any((p) => p.userId == userId);

  List<MatchPlayer> get teamA => players.take(2).toList();

  List<MatchPlayer> get teamB => players.skip(2).take(2).toList();
}
