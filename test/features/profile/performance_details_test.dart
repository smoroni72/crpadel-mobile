import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crpadel_mobile/features/profile/domain/performance_details.dart';
import 'package:crpadel_mobile/features/profile/data/profile_repository.dart';
import 'package:crpadel_mobile/features/profile/presentation/widgets/player_expected_performance.dart';
import '../../helpers/fake_http.dart';
import 'package:crpadel_mobile/features/profile/domain/profile_models.dart';

void main() {
  test(
    'time expired remains a ranking loss and also appears as a non-concluded match',
    () async {
      final expired = {
        'id': 'expired',
        'status': 'completed',
        'match_type': 'ranking',
        'result_outcome': 'time_expired',
      };
      expect(
        countTimeExpired([
          expired,
          expired,
          {...expired, 'id': 'pending', 'status': 'pending_result'},
          {...expired, 'id': 'unfinished', 'result_outcome': 'unfinished'},
        ]),
        1,
      );
      final repo = ApiProfileRepository(
        fakeApiClient(
          FakeAdapter(
            (_) => (
              200,
              {
                'data': {
                  'period': {
                    'matches_played': 20,
                    'wins': 14,
                    'losses': 6,
                    'undecided': 0,
                    'unfinished_ranking_matches': 0,
                  },
                  'matches': [expired],
                },
              },
            ),
          ),
        ),
      );
      final stats = await repo.publicStats(
        player: const PlayerRanking(playerName: 'Stefano', playerRef: 'p'),
      );
      expect(stats.matchesPlayed, 20);
      expect(stats.matchesLost, 6);
      expect(stats.undecided, 0);
      expect(stats.nonConcludedMatches, 1);
      expect(stats.nonConcludedRankingMatches, 1);
      expect(stats.nonConcludedDetails, '0 senza esito · 1 tempo scaduto');
    },
  );
  test(
    'linked user ranking supplies score and band when email lookup returns no row',
    () async {
      final repo = ApiProfileRepository(
        fakeApiClient(
          FakeAdapter((o) {
            if (o.path.endsWith('/directory')) {
              return (
                200,
                {
                  'data': [
                    {
                      'id': 'player',
                      'full_name': 'Stefano Del Giovane',
                      'is_self': true,
                    },
                  ],
                },
              );
            }
            if (o.path.endsWith('/statistics')) {
              return (
                200,
                {
                  'data': {
                    'period': {'matches_played': 20, 'wins': 14, 'losses': 6},
                  },
                },
              );
            }
            if (o.queryParameters.containsKey('player_email')) {
              return (200, {'data': []});
            }
            return (
              200,
              {
                'data': [
                  {
                    'player_ref': 'other',
                    'player_name': 'Stefano Del Giovane',
                    'elo_score': 999,
                  },
                  {
                    'player_ref': 'user',
                    'player_name': 'DEL GIOVANE STEFANO',
                    'elo_score': '1167.80',
                    'ranking_band_name': 'Viola',
                    'ranking_band_color': '#cd0fe6',
                  },
                ],
              },
            );
          }),
        ),
      );
      final stats = await repo.stats(userId: 'user', email: 'new@example.com');
      expect(stats.position, 2);
      expect(stats.currentRankingScore, 1167.8);
      expect(stats.bandName, 'Viola');
      expect(stats.matchesPlayed, 20);
      expect(stats.matchesWon, 14);
      expect(stats.matchesLost, 6);
    },
  );
  testWidgets(
    '19 evaluated matches explain the twentieth as time expired without changing attendance',
    (tester) async {
      final e = performanceDetails({
        'performance_expectation': {
          'period': {
            'status': 'ready',
            'matches_played': 19,
            'wins': 14,
            'expected_wins': 11.117,
            'extra_wins_per_10': 1.517,
            'excluded_matches': 1,
          },
        },
        'matches': [
          {
            'id': 'expired',
            'date': '2026-11-11',
            'time_slot': '12:30-14:00',
            'status': 'completed',
            'match_type': 'ranking',
            'result_outcome': 'time_expired',
          },
          {
            'id': 'normal',
            'status': 'completed',
            'match_type': 'ranking',
            'result_outcome': 'normal',
            'winner_team': 'team1',
            'team_coefficients': {'A': 14, 'B': 14},
          },
        ],
      });
      expect(e!['matches_played'], 19);
      expect((e['excluded_details'] as List).length, 1);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PlayerExpectedPerformance(value: e),
            ),
          ),
        ),
      );
      expect(find.text('19'), findsOneWidget);
      expect(find.text('+1,52'), findsOneWidget);
      await tester.tap(find.text('Vedi le partite escluse'));
      await tester.pumpAndSettle();
      expect(find.text('11/11/2026 · 12:30-14:00'), findsOneWidget);
      expect(find.text('Tempo scaduto, senza vincitore'), findsOneWidget);
    },
  );
}
