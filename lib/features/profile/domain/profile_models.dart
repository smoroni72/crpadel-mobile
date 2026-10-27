import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_models.freezed.dart';
part 'profile_models.g.dart';

/// Riga della classifica del circolo (`GET /rankings`).
@freezed
abstract class PlayerRanking with _$PlayerRanking {
  const factory PlayerRanking({
    /// Id utente, se registrato; altrimenti un altro riferimento stabile.
    String? playerRef,
    required String playerName,
    @Default(0) int position,
    String? rankingBandName,
    String? rankingBandColor,
    @JsonKey(fromJson: nullableRankingScoreFromJson)
    @Default(0)
    double eloScore,
    @Default(0) int matchesPlayed,
    @Default(0) int matchesWon,
  }) = _PlayerRanking;

  factory PlayerRanking.fromJson(Map<String, dynamic> json) =>
      _$PlayerRankingFromJson(json);
}

double nullableRankingScoreFromJson(Object? value) => switch (value) {
  num number => number.toDouble(),
  String text => double.tryParse(text) ?? 0,
  _ => 0,
};

/// Statistiche del Profilo, come i 4 riquadri del sito.
class ProfileStats {
  const ProfileStats({
    this.position,
    this.matchesPlayed = 0,
    this.matchesWon = 0,
    this.bandName,
    this.bandColor,
    this.matchesLost = 0,
    this.undecided = 0,
    this.rankingMatches = 0,
    this.friendlyMatches = 0,
    this.tournamentMatches = 0,
    this.setsWon = 0,
    this.setsLost = 0,
    this.gamesWon = 0,
    this.gamesLost = 0,
    this.underdogMatches = 0,
    this.underdogWins = 0,
    this.favoriteMatches = 0,
    this.favoriteWins = 0,
    this.rankingPointsEarned = 0,
    this.rankingPointsAverage = 0,
    this.recentMatches = 0,
    this.recentWins = 0,
  });

  /// Posizione in classifica; `null` se l'utente non è in classifica.
  final int? position;
  final int matchesPlayed;
  final int matchesWon;
  final String? bandName;
  final String? bandColor;
  final int matchesLost;
  final int undecided;
  final int rankingMatches;
  final int friendlyMatches;
  final int tournamentMatches;
  final int setsWon;
  final int setsLost;
  final int gamesWon;
  final int gamesLost;
  final int underdogMatches;
  final int underdogWins;
  final int favoriteMatches;
  final int favoriteWins;
  final double rankingPointsEarned;
  final double rankingPointsAverage;
  final int recentMatches;
  final int recentWins;

  /// Percentuale di vittorie arrotondata, come sul sito.
  int get winRate =>
      matchesPlayed == 0 ? 0 : (matchesWon * 100 / matchesPlayed).round();

  int get lossRate =>
      matchesPlayed == 0 ? 0 : (matchesLost * 100 / matchesPlayed).round();

  int get setWinRate => setsWon + setsLost == 0
      ? 0
      : (setsWon * 100 / (setsWon + setsLost)).round();

  int get gameWinRate => gamesWon + gamesLost == 0
      ? 0
      : (gamesWon * 100 / (gamesWon + gamesLost)).round();

  int get recentFormRate =>
      recentMatches == 0 ? 0 : (recentWins * 100 / recentMatches).round();

  int get trendDelta => recentMatches == 0 ? 0 : recentFormRate - winRate;

  String get formLabel => recentMatches == 0
      ? 'In attesa'
      : recentFormRate >= 70
      ? 'Ottima'
      : recentFormRate >= 55
      ? 'Buona'
      : recentFormRate >= 40
      ? 'Alterna'
      : 'Da recuperare';

  String get trendLabel => recentMatches == 0
      ? 'Nessun dato'
      : trendDelta > 5
      ? 'In crescita'
      : trendDelta < -5
      ? 'In calo'
      : 'Stabile';
}

class MonthlyRanking {
  const MonthlyRanking({
    required this.position,
    required this.playerRef,
    required this.playerName,
    required this.pointsEarned,
    required this.monthlyScore,
    required this.matchesPlayed,
    required this.matchesWon,
  });

  final int position;
  final String playerRef;
  final String playerName;
  final double pointsEarned;
  final double monthlyScore;
  final int matchesPlayed;
  final int matchesWon;

  int get matchesLost => matchesPlayed - matchesWon;

  factory MonthlyRanking.fromJson(Map<String, dynamic> json) => MonthlyRanking(
    position: (json['position'] as num?)?.toInt() ?? 0,
    playerRef: json['player_ref'] as String? ?? '',
    playerName: json['player_name'] as String? ?? '',
    pointsEarned: _number(json['points_earned']),
    monthlyScore: _number(json['monthly_score']),
    matchesPlayed: (json['matches_played'] as num?)?.toInt() ?? 0,
    matchesWon: (json['matches_won'] as num?)?.toInt() ?? 0,
  );
}

class MonthlyRankingResult {
  const MonthlyRankingResult({
    required this.month,
    required this.minimumMatches,
    this.players = const [],
  });

  final String month;
  final int minimumMatches;
  final List<MonthlyRanking> players;

  MonthlyRanking? get playerOfTheMonth => players.firstOrNull;
}

double _number(Object? value) => switch (value) {
  num number => number.toDouble(),
  String text => double.tryParse(text) ?? 0,
  _ => 0,
};

enum LessonStatus { confirmed, cancelled, completed, unknown }

@freezed
abstract class Lesson with _$Lesson {
  const factory Lesson({
    required String id,
    @Default('') String coachName,
    required DateTime date,
    @Default('') String timeSlot,
    @JsonKey(unknownEnumValue: LessonStatus.unknown)
    @Default(LessonStatus.unknown)
    LessonStatus status,
  }) = _Lesson;

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
}

/// Fascia di validità di un pacchetto in un giorno della settimana.
class SubscriptionWindow {
  const SubscriptionWindow({
    required this.weekday,
    required this.startTime,
    required this.latestStartTime,
  });

  /// 1 = lunedì … 7 = domenica.
  final int weekday;

  /// "07:00"
  final String startTime;

  /// Ultimo orario di inizio ammesso, es. "13:00".
  final String latestStartTime;
}

enum MovementType { purchase, reservation, consumption, release, other }

class SubscriptionMovement {
  const SubscriptionMovement({
    required this.type,
    required this.date,
    required this.delta,
    this.note,
  });

  final MovementType type;
  final DateTime date;

  /// Variazione delle partite disponibili (es. +10, -1).
  final int delta;
  final String? note;
}

/// Dettagli che `/subscriptions/mine` non espone ancora (lacuna n. 2).
class SubscriptionDetails {
  const SubscriptionDetails({
    this.windows = const [],
    this.allowedMatchTypes = const [],
    this.movements = const [],
  });

  final List<SubscriptionWindow> windows;

  /// Codici API: `ranking`, `friendly`, …
  final List<String> allowedMatchTypes;
  final List<SubscriptionMovement> movements;
}
