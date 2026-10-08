// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'padel_match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MatchPlayer _$MatchPlayerFromJson(Map<String, dynamic> json) => _MatchPlayer(
  userId: json['user_id'] as String?,
  playerRef: json['player_ref'] as String?,
  name: json['name'] as String,
  participantType: json['participant_type'] as String?,
);

Map<String, dynamic> _$MatchPlayerToJson(_MatchPlayer instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'player_ref': instance.playerRef,
      'name': instance.name,
      'participant_type': instance.participantType,
    };

_PadelMatch _$PadelMatchFromJson(Map<String, dynamic> json) => _PadelMatch(
  id: json['id'] as String,
  bookingId: json['booking_id'] as String?,
  date: DateTime.parse(json['date'] as String),
  courtName: json['court_name'] as String? ?? '',
  timeSlot: json['time_slot'] as String,
  status:
      $enumDecodeNullable(
        _$MatchStatusEnumMap,
        json['status'],
        unknownValue: MatchStatus.unknown,
      ) ??
      MatchStatus.unknown,
  matchType:
      $enumDecodeNullable(
        _$MatchTypeEnumMap,
        json['match_type'],
        unknownValue: MatchType.unknown,
      ) ??
      MatchType.unknown,
  level:
      $enumDecodeNullable(
        _$MatchLevelEnumMap,
        json['level'],
        unknownValue: MatchLevel.qualsiasi,
      ) ??
      MatchLevel.qualsiasi,
  organizerRef: json['organizer_ref'] as String?,
  organizerName: json['organizer_name'] as String?,
  maxPlayers: (json['max_players'] as num?)?.toInt() ?? 4,
  scoreTeam1: json['score_team1'] as String?,
  winnerTeam: json['winner_team'] as String?,
  players:
      (json['players'] as List<dynamic>?)
          ?.map((e) => MatchPlayer.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$PadelMatchToJson(_PadelMatch instance) =>
    <String, dynamic>{
      'id': instance.id,
      'booking_id': instance.bookingId,
      'date': instance.date.toIso8601String(),
      'court_name': instance.courtName,
      'time_slot': instance.timeSlot,
      'status': _$MatchStatusEnumMap[instance.status]!,
      'match_type': _$MatchTypeEnumMap[instance.matchType]!,
      'level': _$MatchLevelEnumMap[instance.level]!,
      'organizer_ref': instance.organizerRef,
      'organizer_name': instance.organizerName,
      'max_players': instance.maxPlayers,
      'score_team1': instance.scoreTeam1,
      'winner_team': instance.winnerTeam,
      'players': instance.players.map((e) => e.toJson()).toList(),
    };

const _$MatchStatusEnumMap = {
  MatchStatus.open: 'open',
  MatchStatus.inProgress: 'in_progress',
  MatchStatus.pendingResult: 'pending_result',
  MatchStatus.completed: 'completed',
  MatchStatus.notPlayed: 'not_played',
  MatchStatus.cancelled: 'cancelled',
  MatchStatus.unknown: 'unknown',
};

const _$MatchTypeEnumMap = {
  MatchType.ranking: 'ranking',
  MatchType.friendly: 'friendly',
  MatchType.tournament: 'tournament',
  MatchType.unknown: 'unknown',
};

const _$MatchLevelEnumMap = {
  MatchLevel.principiante: 'principiante',
  MatchLevel.intermedio: 'intermedio',
  MatchLevel.avanzato: 'avanzato',
  MatchLevel.qualsiasi: 'qualsiasi',
};
