// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlayerRanking _$PlayerRankingFromJson(Map<String, dynamic> json) =>
    _PlayerRanking(
      playerRef: json['player_ref'] as String?,
      playerName: json['player_name'] as String,
      position: (json['position'] as num?)?.toInt() ?? 0,
      rankingBandName: json['ranking_band_name'] as String?,
      rankingBandColor: json['ranking_band_color'] as String?,
      matchesPlayed: (json['matches_played'] as num?)?.toInt() ?? 0,
      matchesWon: (json['matches_won'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PlayerRankingToJson(_PlayerRanking instance) =>
    <String, dynamic>{
      'player_ref': instance.playerRef,
      'player_name': instance.playerName,
      'position': instance.position,
      'ranking_band_name': instance.rankingBandName,
      'ranking_band_color': instance.rankingBandColor,
      'matches_played': instance.matchesPlayed,
      'matches_won': instance.matchesWon,
    };

_Lesson _$LessonFromJson(Map<String, dynamic> json) => _Lesson(
  id: json['id'] as String,
  coachName: json['coach_name'] as String? ?? '',
  date: DateTime.parse(json['date'] as String),
  timeSlot: json['time_slot'] as String? ?? '',
  status:
      $enumDecodeNullable(
        _$LessonStatusEnumMap,
        json['status'],
        unknownValue: LessonStatus.unknown,
      ) ??
      LessonStatus.unknown,
);

Map<String, dynamic> _$LessonToJson(_Lesson instance) => <String, dynamic>{
  'id': instance.id,
  'coach_name': instance.coachName,
  'date': instance.date.toIso8601String(),
  'time_slot': instance.timeSlot,
  'status': _$LessonStatusEnumMap[instance.status]!,
};

const _$LessonStatusEnumMap = {
  LessonStatus.confirmed: 'confirmed',
  LessonStatus.cancelled: 'cancelled',
  LessonStatus.completed: 'completed',
  LessonStatus.unknown: 'unknown',
};
