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
  String text => double.tryParse(text.trim().replaceAll(',', '.')) ?? 0,
  _ => 0,
};

class RankingAlerts {
  const RankingAlerts({
    this.currentDate = '',
    this.periodStart = '',
    this.periodEnd = '',
    this.daysRemaining = 0,
    this.favoriteRuleEnabled = false,
    this.favoriteStreak = 0,
    this.favoriteThreshold = 3,
    this.favoritePointsAfterThreshold = 0,
    this.favoriteRisk = false,
    this.inactivityRuleEnabled = false,
    this.matchesPlayedInDecade = 0,
    this.matchesScheduledInDecade = 0,
    this.inactivityMinimumMatches = 1,
    this.inactivityPenaltyPoints = -1,
    this.inactivityRisk = false,
    this.injuryExempt = false,
    this.injuryExemptSince,
  });

  final String currentDate;
  final String periodStart;
  final String periodEnd;
  final int daysRemaining;
  final bool favoriteRuleEnabled;
  final int favoriteStreak;
  final int favoriteThreshold;
  final double favoritePointsAfterThreshold;
  final bool favoriteRisk;
  final bool inactivityRuleEnabled;
  final int matchesPlayedInDecade;
  final int matchesScheduledInDecade;
  final int inactivityMinimumMatches;
  final double inactivityPenaltyPoints;
  final bool inactivityRisk;
  final bool injuryExempt;
  final String? injuryExemptSince;

  bool get hasRisk => favoriteRisk || inactivityRisk;

  factory RankingAlerts.fromJson(Map<String, dynamic> json) => RankingAlerts(
    currentDate: json['current_date'] as String? ?? '',
    periodStart: json['period_start'] as String? ?? '',
    periodEnd: json['period_end'] as String? ?? '',
    daysRemaining: (json['days_remaining'] as num?)?.toInt() ?? 0,
    favoriteRuleEnabled: json['favorite_rule_enabled'] == true,
    favoriteStreak: (json['favorite_streak'] as num?)?.toInt() ?? 0,
    favoriteThreshold: (json['favorite_threshold'] as num?)?.toInt() ?? 3,
    favoritePointsAfterThreshold: _number(
      json['favorite_points_after_threshold'],
    ),
    favoriteRisk: json['favorite_risk'] == true,
    inactivityRuleEnabled: json['inactivity_rule_enabled'] == true,
    matchesPlayedInDecade:
        (json['matches_played_in_decade'] as num?)?.toInt() ?? 0,
    matchesScheduledInDecade:
        (json['matches_scheduled_in_decade'] as num?)?.toInt() ?? 0,
    inactivityMinimumMatches:
        (json['inactivity_minimum_matches'] as num?)?.toInt() ?? 1,
    inactivityPenaltyPoints: _number(json['inactivity_penalty_points']),
    inactivityRisk: json['inactivity_risk'] == true,
    injuryExempt: json['injury_exempt'] == true,
    injuryExemptSince: json['injury_exempt_since'] as String?,
  );
}

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
    this.rankingAlerts = const RankingAlerts(),
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
  final RankingAlerts rankingAlerts;

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
    this.classificationDelta = 0,
    this.generalLeaderboardQualified = false,
    this.playerOfMonthEligible = false,
  });

  final int position;
  final String playerRef;
  final String playerName;
  final double pointsEarned;
  final double monthlyScore;
  final int matchesPlayed;
  final int matchesWon;
  final double classificationDelta;
  final bool generalLeaderboardQualified;
  final bool playerOfMonthEligible;

  int get matchesLost => matchesPlayed - matchesWon;

  factory MonthlyRanking.fromJson(Map<String, dynamic> json) => MonthlyRanking(
    position: (json['position'] as num?)?.toInt() ?? 0,
    playerRef: json['player_ref'] as String? ?? '',
    playerName: json['player_name'] as String? ?? '',
    pointsEarned: _number(json['points_earned']),
    monthlyScore: _number(json['monthly_score']),
    matchesPlayed: (json['matches_played'] as num?)?.toInt() ?? 0,
    matchesWon: (json['matches_won'] as num?)?.toInt() ?? 0,
    classificationDelta: _number(json['classification_delta']),
    generalLeaderboardQualified: json['general_leaderboard_qualified'] == true,
    playerOfMonthEligible: json['player_of_month_eligible'] == true,
  );
}

class MonthlyRankingResult {
  const MonthlyRankingResult({
    required this.month,
    required this.minimumMatches,
    this.playerOfMonthMinimumMatches = 4,
    this.generalLeaderboardMinimumMatches = 0,
    this.playerOfMonthRequiresGeneralLeaderboard = true,
    this.players = const [],
  });

  final String month;
  final int minimumMatches;
  final int playerOfMonthMinimumMatches;
  final int generalLeaderboardMinimumMatches;
  final bool playerOfMonthRequiresGeneralLeaderboard;
  final List<MonthlyRanking> players;

  MonthlyRanking? get playerOfTheMonth =>
      players.where((player) => player.playerOfMonthEligible).firstOrNull;
}

class RankingDecadePeriod {
  const RankingDecadePeriod({required this.start, required this.end});

  final String start;
  final String end;

  factory RankingDecadePeriod.fromJson(Map<String, dynamic> json) =>
      RankingDecadePeriod(
        start: json['period_start'] as String? ?? '',
        end: json['period_end'] as String? ?? '',
      );
}

class DecadeRankingPlayer {
  const DecadeRankingPlayer({
    required this.playerRef,
    required this.playerName,
    required this.position,
    required this.eloScore,
    required this.coefficient,
    this.rankingBandName,
    this.rankingBandColor,
  });

  final String playerRef;
  final String playerName;
  final int position;
  final double eloScore;
  final double coefficient;
  final String? rankingBandName;
  final String? rankingBandColor;

  factory DecadeRankingPlayer.fromJson(Map<String, dynamic> json) =>
      DecadeRankingPlayer(
        playerRef: json['player_ref'] as String? ?? '',
        playerName: json['player_name'] as String? ?? '',
        position: (json['position'] as num?)?.toInt() ?? 0,
        eloScore: _number(json['elo_score']),
        coefficient: _number(json['coefficient']),
        rankingBandName: json['ranking_band_name'] as String?,
        rankingBandColor: json['ranking_band_color'] as String?,
      );
}

class DecadeRankingResult {
  const DecadeRankingResult({
    this.periodStart = '',
    this.periodEnd = '',
    this.frozenAt = '',
    this.periodClosed = false,
    this.snapshotAvailable = true,
    this.minimumMatches = 0,
    this.availablePeriods = const [],
    this.players = const [],
  });

  final String periodStart;
  final String periodEnd;
  final String frozenAt;
  final bool periodClosed;
  final bool snapshotAvailable;
  final int minimumMatches;
  final List<RankingDecadePeriod> availablePeriods;
  final List<DecadeRankingPlayer> players;
}

double _number(Object? value) => switch (value) {
  num number => number.toDouble(),
  String text => double.tryParse(text.trim().replaceAll(',', '.')) ?? 0,
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
