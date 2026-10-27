import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../bookings/domain/booking.dart';
import '../domain/profile_models.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ApiProfileRepository(ref.watch(apiClientProvider)),
);

abstract interface class ProfileRepository {
  /// Prime posizioni della classifica ufficiale del circolo.
  Future<List<PlayerRanking>> leaderboard({int limit = 10});

  Future<MonthlyRankingResult> monthlyLeaderboard({required String month});

  /// Statistiche dell'utente in classifica.
  Future<ProfileStats> stats({required String userId, required String email});

  /// Ultime prenotazioni dell'utente, in ogni stato, dalla più recente.
  Future<List<Booking>> bookingHistory({required String email});

  /// Ultime lezioni dell'utente, dalla più recente.
  Future<List<Lesson>> lessons();

  /// Annulla una propria lezione confermata.
  Future<void> cancelLesson(String lessonId);
}

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._api);
  final ApiClient _api;

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
      players: (body['data'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(MonthlyRanking.fromJson)
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
    final totals = detail?['totals'] as Map<String, dynamic>? ?? const {};
    final matches = (detail?['matches'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .where(
          (match) =>
              match['status'] == 'completed' && match['winner_team'] != null,
        )
        .take(5)
        .toList();
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
      recentMatches: matches.length,
      recentWins: recentWins,
      bandName: own?.rankingBandName,
      bandColor: own?.rankingBandColor,
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
