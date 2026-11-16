import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../bookings/domain/booking.dart';
import '../domain/profile_models.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ApiProfileRepository(ref.watch(apiClientProvider)),
);

abstract interface class ProfileRepository {
  Future<RankingMatchSummary> rankingMatchSummary();
  Future<MostPlayedRankingResult> mostPlayedLeaderboard();

  /// Prime posizioni della classifica ufficiale del circolo.
  Future<List<PlayerRanking>> leaderboard({int limit = 10});

  Future<MonthlyRankingResult> monthlyLeaderboard({required String month});

  Future<DecadeRankingResult> decadeLeaderboard({String? periodStart});

  /// Statistiche dell'utente in classifica.
  Future<ProfileStats> stats({required String userId, required String email});

  /// Statistiche sportive pubbliche di un giocatore della classifica.
  Future<ProfileStats> publicStats({required PlayerRanking player});

  /// Ultime prenotazioni dell'utente, in ogni stato, dalla più recente.
  Future<List<Booking>> bookingHistory({required String email});

  /// Ultime lezioni dell'utente, dalla più recente.
  Future<List<Lesson>> lessons();

  /// Annulla una propria lezione confermata.
  Future<void> cancelLesson(String lessonId);

  Future<ProfileStats> updatePhoto({
    Uint8List? jpeg,
    required bool publicConsent,
  });
}

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._api);
  final ApiClient _api;

  @override
  Future<MostPlayedRankingResult> mostPlayedLeaderboard() async {
    final response = await _api.get('/rankings/most-played');
    final body = response.data as Map<String, dynamic>;
    return MostPlayedRankingResult(
      since: (body['meta'] as Map<String, dynamic>)['since'] as String,
      players: (body['data'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(MostPlayedPlayer.fromJson)
          .toList(),
    );
  }

  @override
  Future<RankingMatchSummary> rankingMatchSummary() async {
    final response = await _api.get('/rankings/match-summary');
    return RankingMatchSummary.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  /// Il server restituisce al massimo 200 righe di classifica.
  static const _leaderboardLimit = 200;
  static const _historyLimit = 20;

  @override
  Future<List<PlayerRanking>> leaderboard({int limit = 10}) async {
    final response = await _api.get(
      '/rankings',
      query: {
        'sort': 'position',
        'limit': limit.clamp(1, _leaderboardLimit),
        'leaderboard_only': true,
      },
    );
    return _list(response.data).map(PlayerRanking.fromJson).toList();
  }

  @override
  Future<MonthlyRankingResult> monthlyLeaderboard({
    required String month,
  }) async {
    final response = await _api.get(
      '/rankings/monthly',
      query: {'month': month},
    );
    final body = response.data as Map<String, dynamic>;
    final meta = body['meta'] as Map<String, dynamic>? ?? const {};
    return MonthlyRankingResult(
      month: meta['month'] as String? ?? month,
      minimumMatches: (meta['minimum_matches'] as num?)?.toInt() ?? 1,
      playerOfMonthMinimumMatches:
          (meta['player_of_month_minimum_matches'] as num?)?.toInt() ?? 4,
      generalLeaderboardMinimumMatches:
          (meta['general_leaderboard_minimum_matches'] as num?)?.toInt() ?? 0,
      playerOfMonthRequiresGeneralLeaderboard:
          meta['player_of_month_requires_general_leaderboard'] != false,
      players: (body['data'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(MonthlyRanking.fromJson)
          .toList(),
    );
  }

  @override
  Future<DecadeRankingResult> decadeLeaderboard({String? periodStart}) async {
    final response = await _api.get(
      '/rankings/decades',
      query: {
        if (periodStart != null && periodStart.isNotEmpty)
          'period_start': periodStart,
      },
    );
    final body = response.data as Map<String, dynamic>;
    final meta = body['meta'] as Map<String, dynamic>? ?? const {};
    return DecadeRankingResult(
      periodStart: meta['period_start'] as String? ?? '',
      periodEnd: meta['period_end'] as String? ?? '',
      frozenAt: meta['frozen_at'] as String? ?? '',
      periodClosed: meta['period_closed'] == true,
      snapshotAvailable: meta['snapshot_available'] != false,
      minimumMatches: (meta['minimum_matches'] as num?)?.toInt() ?? 0,
      availablePeriods:
          (meta['available_periods'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>()
              .map(RankingDecadePeriod.fromJson)
              .toList(),
      players: (body['data'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(DecadeRankingPlayer.fromJson)
          .toList(),
    );
  }

  @override
  Future<ProfileStats> stats({
    required String userId,
    required String email,
  }) async {
    final (mine, board, directory) = await (
      _api.get('/rankings', query: {'player_email': email, 'limit': 1}),
      _api.get(
        '/rankings',
        query: {
          'sort': 'position',
          'limit': _leaderboardLimit,
          'leaderboard_only': true,
        },
      ),
      _api.get('/players/directory'),
    ).wait;
    final own = _list(mine.data).map(PlayerRanking.fromJson).firstOrNull;
    // Con il filtro per giocatore il server calcola la posizione solo sul
    // risultato filtrato (sempre 1): la prendiamo dalla classifica completa,
    // come fa il sito.
    final leaderboard = _list(board.data).map(PlayerRanking.fromJson);
    final index = leaderboard.toList().indexWhere((r) => r.playerRef == userId);
    final self = _list(
      directory.data,
    ).where((player) => player['is_self'] == true).firstOrNull;
    Map<String, dynamic>? detail;
    if (self != null) {
      final response = await _api.get('/players/${self['id']}/statistics');
      detail =
          (response.data as Map<String, dynamic>)['data']
              as Map<String, dynamic>?;
    }
    if (own == null && index < 0 && detail == null) return const ProfileStats();
    // Le statistiche sportive devono descrivere solo le partite delle quali
    // esiste uno storico nel sistema. `totals` include anche i contatori
    // iniziali importati nel ranking, mentre `period` viene ricostruito dalle
    // partite realmente registrate.
    final totals =
        detail?['period'] as Map<String, dynamic>? ??
        detail?['totals'] as Map<String, dynamic>? ??
        const {};
    final rankingAlertsJson =
        detail?['ranking_alerts'] as Map<String, dynamic>? ?? const {};
    final highlights =
        detail?['highlights'] as Map<String, dynamic>? ?? const {};
    final streak =
        highlights['current_streak'] as Map<String, dynamic>? ?? const {};
    final history = (detail?['matches'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final matches = history
        .where(
          (match) =>
              match['status'] == 'completed' &&
              (match['winner_team'] != null ||
                  match['result_outcome'] == 'time_expired'),
        )
        .take(5)
        .toList();
    final rankingScoreDeltas = matches
        .where((match) => match['ranking_score_delta'] != null)
        .map((match) => _double(match['ranking_score_delta']))
        .toList();
    final rankingScoreEarned = rankingScoreDeltas.fold<double>(
      0,
      (total, value) => total + value,
    );
    final recentHistory = _recentHistory(
      matches,
      self?['full_name'] as String? ?? '',
    );
    final recentWins = matches.where((match) {
      final ownTeam = ((match['position'] as num?)?.toInt() ?? 0) < 2
          ? 'team1'
          : 'team2';
      return match['winner_team'] == ownTeam;
    }).length;
    return ProfileStats(
      position: index < 0 ? null : index + 1,
      matchesPlayed:
          (totals['matches_played'] as num?)?.toInt() ??
          own?.matchesPlayed ??
          0,
      matchesWon: (totals['wins'] as num?)?.toInt() ?? own?.matchesWon ?? 0,
      matchesLost: (totals['losses'] as num?)?.toInt() ?? 0,
      undecided: (totals['undecided'] as num?)?.toInt() ?? 0,
      rankingMatches: (totals['ranking_matches'] as num?)?.toInt() ?? 0,
      friendlyMatches: (totals['friendly_matches'] as num?)?.toInt() ?? 0,
      tournamentMatches: (totals['tournament_matches'] as num?)?.toInt() ?? 0,
      setsWon: (totals['sets_won'] as num?)?.toInt() ?? 0,
      setsLost: (totals['sets_lost'] as num?)?.toInt() ?? 0,
      gamesWon: (totals['games_won'] as num?)?.toInt() ?? 0,
      gamesLost: (totals['games_lost'] as num?)?.toInt() ?? 0,
      underdogMatches: (totals['underdog_matches'] as num?)?.toInt() ?? 0,
      underdogWins: (totals['underdog_wins'] as num?)?.toInt() ?? 0,
      favoriteMatches: (totals['favorite_matches'] as num?)?.toInt() ?? 0,
      favoriteWins: (totals['favorite_wins'] as num?)?.toInt() ?? 0,
      rankingPointsEarned: _double(totals['ranking_points_earned']),
      rankingPointsAverage: _double(totals['ranking_points_average']),
      rankingScoreEarned: rankingScoreEarned,
      rankingScoreAverage: rankingScoreDeltas.isEmpty
          ? 0
          : rankingScoreEarned / rankingScoreDeltas.length,
      currentRankingScore: own?.eloScore ?? 0,
      recentMatches: matches.length,
      recentWins: recentWins,
      recentHistory: recentHistory,
      currentStreakType: streak['type'] as String?,
      currentStreakCount: (streak['count'] as num?)?.toInt() ?? 0,
      bestPartner: _highlightPerson(highlights['best_partner']),
      mostFacedOpponent: _highlightPerson(highlights['most_faced_opponent']),
      badges: (highlights['badges'] as List<dynamic>? ?? const [])
          .map((badge) => badge.toString())
          .toList(growable: false),
      bandName: own?.rankingBandName,
      bandColor: own?.rankingBandColor,
      rankingAlerts: RankingAlerts.fromJson(rankingAlertsJson),
      photoUrl: self?['photo_url'] as String?,
      photoStorageId: self?['photo_storage_id'] as String?,
      photoPublicConsent: self?['photo_public_consent'] == true,
    );
  }

  @override
  Future<ProfileStats> publicStats({required PlayerRanking player}) async {
    final reference = player.playerRef;
    if (reference == null || reference.isEmpty) {
      throw StateError('Riferimento giocatore non disponibile');
    }
    final response = await _api.get(
      '/players/$reference/statistics',
      query: {'public_view': true},
    );
    final detail =
        (response.data as Map<String, dynamic>)['data']
            as Map<String, dynamic>? ??
        const <String, dynamic>{};
    final totals =
        detail['period'] as Map<String, dynamic>? ??
        detail['totals'] as Map<String, dynamic>? ??
        const {};
    final history = (detail['matches'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final highlights =
        detail['highlights'] as Map<String, dynamic>? ?? const {};
    final streak =
        highlights['current_streak'] as Map<String, dynamic>? ?? const {};
    final rankingScoreDeltas = history
        .where(
          (match) =>
              match['status'] == 'completed' &&
              match['ranking_score_delta'] != null,
        )
        .take(5)
        .map((match) => _double(match['ranking_score_delta']))
        .toList();
    final rankingScoreEarned = rankingScoreDeltas.fold<double>(
      0,
      (total, value) => total + value,
    );
    final matches = history
        .where(
          (match) =>
              match['status'] == 'completed' &&
              (match['winner_team'] != null ||
                  match['result_outcome'] == 'time_expired'),
        )
        .take(5)
        .toList();
    final recentHistory = _recentHistory(matches, player.playerName);
    final recentWins = matches.where((match) {
      final ownTeam = ((match['position'] as num?)?.toInt() ?? 0) < 2
          ? 'team1'
          : 'team2';
      return match['winner_team'] == ownTeam;
    }).length;
    return ProfileStats(
      position: player.position > 0 ? player.position : null,
      matchesPlayed:
          (totals['matches_played'] as num?)?.toInt() ?? player.matchesPlayed,
      matchesWon: (totals['wins'] as num?)?.toInt() ?? player.matchesWon,
      matchesLost: (totals['losses'] as num?)?.toInt() ?? 0,
      undecided: (totals['undecided'] as num?)?.toInt() ?? 0,
      rankingMatches: (totals['ranking_matches'] as num?)?.toInt() ?? 0,
      friendlyMatches: (totals['friendly_matches'] as num?)?.toInt() ?? 0,
      tournamentMatches: (totals['tournament_matches'] as num?)?.toInt() ?? 0,
      setsWon: (totals['sets_won'] as num?)?.toInt() ?? 0,
      setsLost: (totals['sets_lost'] as num?)?.toInt() ?? 0,
      gamesWon: (totals['games_won'] as num?)?.toInt() ?? 0,
      gamesLost: (totals['games_lost'] as num?)?.toInt() ?? 0,
      underdogMatches: (totals['underdog_matches'] as num?)?.toInt() ?? 0,
      underdogWins: (totals['underdog_wins'] as num?)?.toInt() ?? 0,
      favoriteMatches: (totals['favorite_matches'] as num?)?.toInt() ?? 0,
      favoriteWins: (totals['favorite_wins'] as num?)?.toInt() ?? 0,
      rankingPointsEarned: _double(totals['ranking_points_earned']),
      rankingPointsAverage: _double(totals['ranking_points_average']),
      rankingScoreEarned: rankingScoreEarned,
      rankingScoreAverage: rankingScoreDeltas.isEmpty
          ? 0
          : rankingScoreEarned / rankingScoreDeltas.length,
      currentRankingScore: player.eloScore,
      recentMatches: matches.length,
      recentWins: recentWins,
      recentHistory: recentHistory,
      currentStreakType: streak['type'] as String?,
      currentStreakCount: (streak['count'] as num?)?.toInt() ?? 0,
      bestPartner: _highlightPerson(highlights['best_partner']),
      mostFacedOpponent: _highlightPerson(highlights['most_faced_opponent']),
      badges: (highlights['badges'] as List<dynamic>? ?? const [])
          .map((badge) => badge.toString())
          .toList(growable: false),
      bandName: player.rankingBandName,
      bandColor: player.rankingBandColor,
      photoUrl: player.playerPhotoUrl,
      photoPublicConsent: player.playerPhotoUrl != null,
    );
  }

  @override
  Future<ProfileStats> updatePhoto({
    Uint8List? jpeg,
    required bool publicConsent,
  }) async {
    Map<String, dynamic>? upload;
    if (jpeg != null) upload = await _api.uploadJpeg(jpeg);
    final current = await _api.get('/players/me');
    final player =
        (current.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    final response = await _api.patch(
      '/players/me/photo',
      data: {
        'photo_url': upload?['file_url'] ?? player['photo_url'],
        'photo_storage_id':
            upload?['storage_object_id'] ?? player['photo_storage_id'],
        'photo_public_consent': publicConsent,
      },
    );
    final updated =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ProfileStats(
      photoUrl: updated['photo_url'] as String?,
      photoStorageId: updated['photo_storage_id'] as String?,
      photoPublicConsent: updated['photo_public_consent'] == true,
    );
  }

  @override
  Future<List<Booking>> bookingHistory({required String email}) async {
    final response = await _api.get(
      '/bookings',
      query: {'sort': '-date', 'limit': _historyLimit, 'player_email': email},
    );
    return _list(response.data).map(Booking.fromJson).toList();
  }

  @override
  Future<List<Lesson>> lessons() async {
    final response = await _api.get(
      '/lessons',
      query: {'sort': '-date', 'limit': _historyLimit},
    );
    return _list(response.data).map(Lesson.fromJson).toList();
  }

  @override
  Future<void> cancelLesson(String lessonId) async {
    await _api.patch('/lessons/$lessonId', data: {'status': 'cancelled'});
  }
}

List<Map<String, dynamic>> _list(Object? body) =>
    ((body as Map<String, dynamic>)['data'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

double _double(Object? value) => switch (value) {
  num number => number.toDouble(),
  String text => double.tryParse(text) ?? 0,
  _ => 0,
};

PlayerHighlightPerson? _highlightPerson(Object? value) {
  if (value is! Map) return null;
  return PlayerHighlightPerson.fromJson(Map<String, dynamic>.from(value));
}

List<RecentPlayerMatch> _recentHistory(
  List<Map<String, dynamic>> matches,
  String playerName,
) => matches.map((match) {
  final position = (match['position'] as num?)?.toInt() ?? 0;
  final ownTeam = position < 2 ? 'A' : 'B';
  final playerTeam = position < 2 ? 'team1' : 'team2';
  final timeExpired = match['result_outcome'] == 'time_expired';
  final won = match['winner_team'] == playerTeam;
  final players = (match['players'] as List<dynamic>? ?? const [])
      .cast<Map<String, dynamic>>();
  List<String> namesFor(String team) => players
      .where((candidate) => candidate['team'] == team)
      .map((candidate) => candidate['name'] as String? ?? '')
      .where((name) => name.isNotEmpty && name != playerName)
      .toList();
  return RecentPlayerMatch(
    id: match['id'] as String? ?? '',
    date: match['date'] as String? ?? '',
    timeSlot: match['time_slot'] as String? ?? '',
    courtName: match['court_name'] as String? ?? '',
    // The API score is always team A first; history shows the player's team first.
    score: position < 2
        ? match['score_team1'] as String? ?? ''
        : (match['score_team1'] as String? ?? '').replaceAllMapped(
            RegExp(r'(\d+)\s*-\s*(\d+)'),
            (set) => '${set[2]}-${set[1]}',
          ),
    resultLabel: timeExpired
        ? 'Tempo scaduto'
        : won
        ? 'Vittoria'
        : 'Sconfitta',
    won: won,
    teamMates: namesFor(ownTeam),
    opponents: namesFor(ownTeam == 'A' ? 'B' : 'A'),
    rankingScoreDelta: match['ranking_score_delta'] == null
        ? null
        : _double(match['ranking_score_delta']),
  );
}).toList();
