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
  });

  /// Posizione in classifica; `null` se l'utente non è in classifica.
  final int? position;
  final int matchesPlayed;
  final int matchesWon;
  final String? bandName;
  final String? bandColor;

  /// Percentuale di vittorie arrotondata, come sul sito.
  int get winRate =>
      matchesPlayed == 0 ? 0 : (matchesWon * 100 / matchesPlayed).round();
}

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
