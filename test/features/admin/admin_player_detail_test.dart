import 'package:crpadel_mobile/app/routes.dart';
import 'package:crpadel_mobile/features/admin/data/admin_repository.dart';
import 'package:crpadel_mobile/features/admin/presentation/admin_screens.dart';
import 'package:crpadel_mobile/features/admin/presentation/admin_player_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import '../../helpers/app_overrides.dart';
import '../../helpers/fake_http.dart';

void main() {
  testWidgets(
    'il tocco apre il giocatore e le sue partite, poi il dettaglio partita',
    (tester) async {
      final requests = <String>[];
      final repository = AdminRepository(
        fakeApiClient(
          FakeAdapter((options) {
            requests.add(options.path);
            if (options.path == '/players') {
              return (
                200,
                {
                  'data': [
                    {
                      'id': 'audino',
                      'full_name': 'AUDINO GIULIANO',
                      'email': 'giuliano@example.com',
                      'phone': '123456',
                      'ranking_matches_played': 56,
                      'ranking_matches_won': 27,
                      'ranking_real_points': '1008.40',
                      'registration_status': 'member',
                    },
                  ],
                },
              );
            }
            expect(options.path, '/players/audino/statistics');
            return (
              200,
              {
                'data': {
                  'totals': {'matches_played': 56, 'wins': 27, 'losses': 29},
                  'matches': [
                    {
                      'id': 'match-1',
                      'date': '2026-11-08',
                      'time_slot': '18:00-19:30',
                      'court_name': 'Campo 1',
                      'score_team1': '6-4 6-3',
                      'status': 'completed',
                      'players': [
                        {'name': 'AUDINO GIULIANO'},
                        {'name': 'Avversario'},
                      ],
                    },
                  ],
                },
              },
            );
          }),
        ),
      );
      final router = GoRouter(
        initialLocation: '/players',
        routes: [
          GoRoute(
            path: '/players',
            builder: (_, _) => const AdminPlayersScreen(),
          ),
          GoRoute(
            path: '/players/:id',
            name: AppRoutes.adminPlayerDetail,
            builder: (_, state) => AdminPlayerDetailScreen(
              playerId: state.pathParameters['id']!,
              player: state.extra as AdminPlayer,
            ),
          ),
          GoRoute(
            path: '/match/:id',
            name: AppRoutes.matchDetail,
            builder: (_, state) =>
                Scaffold(body: Text('Partita ${state.pathParameters['id']}')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...FakeBackend().overrides,
            adminRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('AUDINO GIULIANO'));
      await tester.pumpAndSettle();
      expect(find.text('Dettaglio giocatore'), findsOneWidget);
      expect(find.text('giuliano@example.com'), findsOneWidget);
      expect(
        find.text('56 partite · 27 vittorie · 29 sconfitte'),
        findsOneWidget,
      );
      expect(find.textContaining('6-4 6-3'), findsOneWidget);
      expect(requests, ['/players', '/players/audino/statistics']);
      await tester.tap(find.textContaining('08/11/2026'));
      await tester.pumpAndSettle();
      expect(find.text('Partita match-1'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('Giocatori'), findsOneWidget);
    },
  );
}
