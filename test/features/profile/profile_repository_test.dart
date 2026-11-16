import 'package:crpadel_mobile/features/auth/data/auth_repository.dart';
import 'package:crpadel_mobile/features/profile/data/profile_repository.dart';
import 'package:crpadel_mobile/features/profile/domain/profile_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_http.dart';

Map<String, dynamic> _row(
  String ref,
  String name, {
  int played = 0,
  int won = 0,
}) => {
  'player_ref': ref,
  'player_name': name,
  // Con il filtro per giocatore il server risponde sempre 1.
  'position': 1,
  'ranking_band_name': 'Oro',
  'ranking_band_color': '#E8C468',
  'matches_played': played,
  'matches_won': won,
  'elo_score': '1180.50',
};

void main() {
  test(
    'ordina per quota da sfavorito nelle due direzioni, senza usare le vittorie',
    () {
      MostPlayedPlayer row(
        String name,
        int played,
        int wins,
        double? percentage,
      ) => MostPlayedPlayer(
        position: 1,
        name: name,
        playerRef: name,
        matchesPlayed: played,
        wins: wins,
        losses: played - wins,
        setsWon: 0,
        setsLost: 0,
        gamesWon: 0,
        gamesLost: 0,
        matchesWithScore: 0,
        underdogMatchPercentage: percentage,
      );
      final players = [
        row('A', 100, 90, 20),
        row('C', 40, 40, 0),
        row('B', 20, 0, 80),
        row('D', 10, 9, null),
      ];
      expect(
        sortMostPlayedPlayers(
          players,
          MostPlayedSort.underdogDescending,
        ).map((p) => p.name),
        ['B', 'A', 'C', 'D'],
      );
      expect(
        sortMostPlayedPlayers(
          players,
          MostPlayedSort.underdogAscending,
        ).map((p) => p.name),
        ['C', 'A', 'B', 'D'],
      );
      expect(
        sortMostPlayedPlayers(
          players,
          MostPlayedSort.matchesPlayed,
        ).map((p) => p.name),
        ['A', 'C', 'B', 'D'],
      );
      expect(players.map((p) => p.name), ['A', 'C', 'B', 'D']);
    },
  );

  test(
    'classifica presenze legge tutti gli esiti e la copertura dei punteggi',
    () async {
      final adapter = FakeAdapter(
        (_) => (
          200,
          {
            'meta': {'since': '2026-06-01'},
            'data': [
              {
                'position': 1,
                'player_name': 'Giocatore Storico',
                'player_ref': 'directory-1',
                'ranking': {
                  'player_ref': 'user-1',
                  'player_name': 'Giocatore Storico',
                  'elo_score': 1187.25,
                  'ranking_band_name': 'Rosso',
                  'ranking_band_color': '#ff0000',
                },
                'player_photo_url': null,
                'matches_played': 97,
                'wins': 79,
                'losses': 18,
                'sets_won': 29,
                'sets_lost': 4,
                'games_won': 177,
                'games_lost': 105,
                'matches_with_score': 15,
                'difficulty_level': 'Altissimo',
                'underdog_matches': 12,
                'underdog_wins': 8,
                'underdog_match_percentage': 80.0,
                'matches_with_coefficients': 15,
              },
            ],
          },
        ),
      );
      final result = await ApiProfileRepository(
        fakeApiClient(adapter),
      ).mostPlayedLeaderboard();
      expect(result.since, '2026-06-01');
      final player = result.players.single;
      expect(player.matchesPlayed, 97);
      expect(player.wins, 79);
      expect(player.losses, 18);
      expect(player.setsWon, 29);
      expect(player.setsLost, 4);
      expect(player.gamesWon, 177);
      expect(player.gamesLost, 105);
      expect(player.matchesWithScore, 15);
      expect(player.difficultyLevel, 'Altissimo');
      expect(player.underdogMatches, 12);
      expect(player.underdogWins, 8);
      expect(player.underdogMatchPercentage, 80);
      expect(player.playerRef, 'directory-1');
      expect(player.ranking?.playerRef, 'user-1');
      expect(player.ranking?.eloScore, 1187.25);
      expect(adapter.requests.single.path, '/rankings/most-played');
    },
  );

  test(
    'legge il totale delle partite dal riepilogo, senza sommare le presenze',
    () async {
      final adapter = FakeAdapter(
        (_) => (
          200,
          {
            'data': {
              'total_played': 132,
              'since': '2026-10-01',
              'through': '2026-11-16',
            },
          },
        ),
      );
      final result = await ApiProfileRepository(
        fakeApiClient(adapter),
      ).rankingMatchSummary();
      expect(result.totalPlayed, 132);
      expect(result.since, '2026-10-01');
      expect(adapter.requests.single.path, '/rankings/match-summary');
    },
  );

  for (final position in [0, 1, 2, 3]) {
    test('storico: punteggio dalla prospettiva del posto $position', () async {
      const scores = ['5-7 6-4 TB 10-4', '6-4 6-3', '6-4 6-7', ''];
      final adapter = FakeAdapter(
        (_) => (
          200,
          {
            'data': {
              'totals': <String, dynamic>{},
              'matches': [
                for (var i = 0; i < scores.length; i++)
                  {
                    'id': 'm$i',
                    'status': 'completed',
                    'position': position,
                    'winner_team': i == 2 ? null : 'team1',
                    'result_outcome': i == 2 ? 'time_expired' : 'normal',
                    'score_team1': scores[i],
                    'players': [
                      {'name': 'Mario Rossi', 'team': position < 2 ? 'A' : 'B'},
                      {'name': 'Compagno', 'team': position < 2 ? 'A' : 'B'},
                      {
                        'name': 'Avversario 1',
                        'team': position < 2 ? 'B' : 'A',
                      },
                      {
                        'name': 'Avversario 2',
                        'team': position < 2 ? 'B' : 'A',
                      },
                    ],
                  },
              ],
            },
          },
        ),
      );
      final stats = await ApiProfileRepository(fakeApiClient(adapter))
          .publicStats(
            player: const PlayerRanking(
              playerRef: 'p1',
              playerName: 'Mario Rossi',
              position: 1,
              eloScore: 1180,
              matchesPlayed: 4,
              matchesWon: 2,
            ),
          );

      expect(
        stats.recentHistory.map((match) => match.score),
        position < 2 ? scores : ['7-5 4-6 TB 4-10', '4-6 3-6', '4-6 7-6', ''],
      );
      expect(stats.recentHistory.first.won, position < 2);
      expect(
        stats.recentHistory.first.resultLabel,
        position < 2 ? 'Vittoria' : 'Sconfitta',
      );
      expect(stats.recentHistory.first.teamMates, ['Compagno']);
      expect(stats.recentHistory.first.opponents, [
        'Avversario 1',
        'Avversario 2',
      ]);
      expect(stats.recentHistory[2].resultLabel, 'Tempo scaduto');
    });
  }

  test('la posizione viene dalla classifica completa', () async {
    final adapter = FakeAdapter((options) {
      if (options.queryParameters.containsKey('player_email')) {
        return (
          200,
          {
            'data': [_row('user-1', 'Mario Rossi', played: 24, won: 15)],
          },
        );
      }
      return (
        200,
        {
          'data': [
            _row('a', 'Primo'),
            _row('b', 'Secondo'),
            _row('user-1', 'Mario Rossi'),
          ],
        },
      );
    });
    final repository = ApiProfileRepository(fakeApiClient(adapter));

    final stats = await repository.stats(
      userId: 'user-1',
      email: 'mario@example.com',
    );

    expect(stats.position, 3);
    expect(stats.matchesPlayed, 24);
    expect(stats.matchesWon, 15);
    expect(stats.winRate, 63);
    expect(stats.bandName, 'Oro');
  });

  test('fuori classifica: nessuna posizione', () async {
    final adapter = FakeAdapter((_) => (200, {'data': <Object>[]}));
    final repository = ApiProfileRepository(fakeApiClient(adapter));

    final stats = await repository.stats(userId: 'user-1', email: 'x@y.it');

    expect(stats.position, isNull);
    expect(stats.winRate, 0);
  });

  test(
    'statistiche pubbliche usano le partite registrate e non i contatori importati',
    () async {
      final adapter = FakeAdapter(
        (_) => (
          200,
          {
            'data': {
              'totals': {'matches_played': 26, 'wins': 19, 'losses': 7},
              'period': {
                'matches_played': 2,
                'wins': 2,
                'losses': 0,
                'ranking_matches': 2,
              },
              'matches': [
                {
                  'id': 'm2',
                  'date': '2026-11-10',
                  'status': 'completed',
                  'winner_team': 'team1',
                  'position': 0,
                  'players': <Object>[],
                },
                {
                  'id': 'm1',
                  'date': '2026-11-01',
                  'status': 'completed',
                  'winner_team': 'team2',
                  'position': 2,
                  'players': <Object>[],
                },
              ],
            },
          },
        ),
      );
      final repository = ApiProfileRepository(fakeApiClient(adapter));

      final stats = await repository.publicStats(
        player: const PlayerRanking(
          playerRef: 'player-1',
          playerName: 'Fabio Di Costantini',
          position: 3,
          eloScore: 1178.04,
          matchesPlayed: 26,
          matchesWon: 19,
        ),
      );

      expect(stats.matchesPlayed, 2);
      expect(stats.matchesWon, 2);
      expect(stats.matchesLost, 0);
      expect(stats.recentMatches, 2);
      expect(stats.recentHistory, hasLength(2));
    },
  );

  test(
    'carica tutte le statistiche personali e calcola la forma recente',
    () async {
      final adapter = FakeAdapter((options) {
        if (options.path == '/players/directory') {
          return (
            200,
            {
              'data': [
                {'id': 'player-1', 'full_name': 'Mario Rossi', 'is_self': true},
              ],
            },
          );
        }
        if (options.path == '/players/player-1/statistics') {
          return (
            200,
            {
              'data': {
                'highlights': {
                  'current_streak': {'type': 'win', 'count': 3},
                  'best_partner': {
                    'name': 'Luca Bianchi',
                    'matches': 6,
                    'wins': 5,
                    'losses': 1,
                    'win_rate': 83.3,
                  },
                  'most_faced_opponent': {
                    'name': 'Paolo Verdi',
                    'matches': 4,
                    'wins': 2,
                    'losses': 2,
                    'win_rate': 50,
                  },
                  'badges': ['In forma', 'Serie vincente'],
                },
                'ranking_alerts': {
                  'period_start': '2026-11-01',
                  'period_end': '2026-11-10',
                  'days_remaining': 4,
                  'favorite_rule_enabled': true,
                  'favorite_streak': 3,
                  'favorite_threshold': 3,
                  'favorite_points_after_threshold': '0,10',
                  'favorite_risk': true,
                  'inactivity_rule_enabled': true,
                  'matches_played_in_decade': 0,
                  'matches_scheduled_in_decade': 1,
                  'inactivity_minimum_matches': 1,
                  'inactivity_penalty_points': -1,
                  'inactivity_risk': true,
                  'injury_exempt': false,
                },
                'totals': {
                  'matches_played': 20,
                  'wins': 12,
                  'losses': 8,
                  'undecided': 0,
                  'ranking_matches': 18,
                  'friendly_matches': 2,
                  'tournament_matches': 0,
                  'sets_won': 28,
                  'sets_lost': 19,
                  'games_won': 210,
                  'games_lost': 180,
                  'underdog_matches': 5,
                  'underdog_wins': 3,
                  'favorite_matches': 8,
                  'favorite_wins': 6,
                  'ranking_points_earned': 230.5,
                  'ranking_points_average': 12.81,
                },
                'matches': [
                  {
                    'status': 'completed',
                    'winner_team': 'team1',
                    'position': 0,
                  },
                  {
                    'status': 'completed',
                    'winner_team': 'team2',
                    'position': 0,
                  },
                  {
                    'status': 'completed',
                    'winner_team': 'team2',
                    'position': 2,
                  },
                  {
                    'status': 'completed',
                    'winner_team': 'team1',
                    'position': 0,
                  },
                  {
                    'status': 'completed',
                    'winner_team': 'team1',
                    'position': 2,
                  },
                ],
              },
            },
          );
        }
        if (options.queryParameters.containsKey('player_email')) {
          return (
            200,
            {
              'data': [_row('user-1', 'Mario Rossi', played: 18, won: 11)],
            },
          );
        }
        return (
          200,
          {
            'data': [_row('user-1', 'Mario Rossi')],
          },
        );
      });
      final repository = ApiProfileRepository(fakeApiClient(adapter));

      final stats = await repository.stats(
        userId: 'user-1',
        email: 'mario@example.com',
      );

      expect(stats.matchesPlayed, 20);
      expect(stats.matchesWon, 12);
      expect(stats.matchesLost, 8);
      expect(stats.gamesWon, 210);
      expect(stats.underdogMatches, 5);
      expect(stats.favoriteWins, 6);
      expect(stats.rankingPointsAverage, 12.81);
      expect(stats.recentMatches, 5);
      expect(stats.recentWins, 3);
      expect(stats.recentFormRate, 60);
      expect(stats.formLabel, 'Buona');
      expect(stats.trendLabel, 'Stabile');
      expect(stats.rankingAlerts.favoriteRisk, isTrue);
      expect(stats.rankingAlerts.favoriteStreak, 3);
      expect(stats.rankingAlerts.favoritePointsAfterThreshold, 0.1);
      expect(stats.rankingAlerts.inactivityRisk, isTrue);
      expect(stats.rankingAlerts.matchesScheduledInDecade, 1);
      expect(stats.currentStreakType, 'win');
      expect(stats.currentStreakCount, 3);
      expect(stats.bestPartner?.name, 'Luca Bianchi');
      expect(stats.bestPartner?.winRate, 83.3);
      expect(stats.mostFacedOpponent?.name, 'Paolo Verdi');
      expect(stats.badges, ['In forma', 'Serie vincente']);
    },
  );

  test('classifica mensile: legge soglia, PR e punteggio', () async {
    final adapter = FakeAdapter(
      (_) => (
        200,
        {
          'data': [
            {
              'position': 1,
              'player_ref': 'p1',
              'player_name': 'Mario Rossi',
              'points_earned': 39.5,
              'monthly_score': 131.67,
              'matches_played': 3,
              'matches_won': 2,
              'classification_delta': 4.21,
              'general_leaderboard_qualified': true,
              'player_of_month_eligible': true,
            },
          ],
          'meta': {
            'month': '2026-10',
            'minimum_matches': 3,
            'player_of_month_minimum_matches': 3,
            'general_leaderboard_minimum_matches': 6,
          },
        },
      ),
    );
    final repository = ApiProfileRepository(fakeApiClient(adapter));

    final result = await repository.monthlyLeaderboard(month: '2026-10');

    expect(result.month, '2026-10');
    expect(result.minimumMatches, 3);
    expect(result.playerOfTheMonth?.playerName, 'Mario Rossi');
    expect(result.players.single.monthlyScore, 131.67);
    expect(result.players.single.classificationDelta, 4.21);
    expect(result.players.single.playerOfMonthEligible, isTrue);
    expect(adapter.requests.single.path, '/rankings/monthly');
  });

  test('classifica decadi: legge periodi, fotografia e coefficienti', () async {
    final adapter = FakeAdapter(
      (_) => (
        200,
        {
          'data': [
            {
              'player_ref': 'p1',
              'player_name': 'Mario Rossi',
              'position': 3,
              'elo_score': 1172.4,
              'ranking_band_name': 'Blu',
              'ranking_band_color': '#0066FF',
              'coefficient': 6.5,
            },
          ],
          'meta': {
            'period_start': '2026-10-21',
            'period_end': '2026-10-31',
            'frozen_at': '2026-10-31',
            'period_closed': true,
            'snapshot_available': true,
            'minimum_matches': 7,
            'available_periods': [
              {'period_start': '2026-10-21', 'period_end': '2026-10-31'},
              {'period_start': '2026-10-11', 'period_end': '2026-10-20'},
            ],
          },
        },
      ),
    );
    final repository = ApiProfileRepository(fakeApiClient(adapter));

    final result = await repository.decadeLeaderboard(
      periodStart: '2026-10-21',
    );

    expect(result.frozenAt, '2026-10-31');
    expect(result.periodClosed, isTrue);
    expect(result.snapshotAvailable, isTrue);
    expect(result.minimumMatches, 7);
    expect(result.availablePeriods, hasLength(2));
    expect(result.players.single.rankingBandName, 'Blu');
    expect(result.players.single.coefficient, 6.5);
    expect(adapter.requests.single.path, '/rankings/decades');
    expect(adapter.requests.single.queryParameters, {
      'period_start': '2026-10-21',
    });
  });

  test('storico prenotazioni e lezioni dalla più recente', () async {
    final adapter = FakeAdapter((options) {
      if (options.path == '/lessons') {
        return (
          200,
          {
            'data': [
              {
                'id': 'l1',
                'coach_name': 'Luca',
                'date': '2026-10-08',
                'time_slot': '10:00-11:00',
                'status': 'confirmed',
              },
            ],
          },
        );
      }
      return (200, {'data': <Object>[]});
    });
    final repository = ApiProfileRepository(fakeApiClient(adapter));

    await repository.bookingHistory(email: 'mario@example.com');
    final lessons = await repository.lessons();
    await repository.cancelLesson('l1');

    expect(adapter.requests[0].queryParameters, {
      'sort': '-date',
      'limit': 20,
      'player_email': 'mario@example.com',
    });
    expect(lessons.single.status, LessonStatus.confirmed);
    expect(adapter.requests.last.method, 'PATCH');
    expect(adapter.requests.last.path, '/lessons/l1');
    expect(adapter.requests.last.data, {'status': 'cancelled'});
  });

  test('cambio password: invia le due password e chiude la sessione', () async {
    final adapter = FakeAdapter(
      (_) => (200, {'success': true, 'reauthentication_required': true}),
    );
    final api = fakeApiClient(adapter);
    await api.setAccessToken('token');
    final repository = ApiAuthRepository(api);

    await repository.changePassword(
      currentPassword: 'vecchia-password',
      newPassword: 'nuova-password-lunga',
    );

    expect(adapter.requests.single.path, '/auth/change-password');
    expect(adapter.requests.single.data, {
      'current_password': 'vecchia-password',
      'new_password': 'nuova-password-lunga',
    });
  });
}
