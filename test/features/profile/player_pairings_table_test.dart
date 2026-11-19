import 'package:crpadel_mobile/core/theme/app_theme.dart';
import 'package:crpadel_mobile/features/profile/data/profile_repository.dart';
import 'package:crpadel_mobile/features/profile/domain/profile_models.dart';
import 'package:crpadel_mobile/features/profile/presentation/widgets/player_pairings_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/fake_http.dart';

const _stats = ProfileStats(
  pairingsMatches: 31,
  partnersCount: 17,
  opponentsCount: 22,
  mostFrequentPartners: [
    PlayerHighlightPerson(
      name: 'ISOPI RICCARDO',
      matches: 4,
      wins: 3,
      losses: 1,
    ),
    PlayerHighlightPerson(
      name: 'CATTANEO GIULIO',
      matches: 4,
      wins: 2,
      losses: 2,
    ),
  ],
  bestPartner: PlayerHighlightPerson(
    name: 'STEFANO DEL GIOVANE',
    matches: 3,
    wins: 3,
  ),
  mostFacedOpponent: PlayerHighlightPerson(
    name: 'EDOARDO DE GRANDIS',
    matches: 8,
    wins: 6,
    losses: 2,
  ),
);
void main() {
  testWidgets(
    'five pairings rows retain tied partners on a narrow phone with enlarged text',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.4)),
            child: const Scaffold(
              body: SingleChildScrollView(
                child: PlayerPairingsTable(stats: _stats),
              ),
            ),
          ),
        ),
      );
      expect(find.text('17'), findsOneWidget);
      expect(find.text('22'), findsOneWidget);
      expect(find.text('ISOPI RICCARDO'), findsOneWidget);
      expect(find.text('CATTANEO GIULIO'), findsOneWidget);
      expect(find.text('3 partite · 3 V / 0 S'), findsOneWidget);
      expect(find.text('8 partite · 6 V / 2 S'), findsOneWidget);
      expect(tester.widget<Table>(find.byType(Table)).children.length, 6);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'empty profile shows zero distinct players and no invented pairings',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: PlayerPairingsTable(stats: ProfileStats()),
            ),
          ),
        ),
      );
      expect(find.text('0'), findsNWidgets(2));
      expect(find.text('—'), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    },
  );
  test(
    'public profile parses pairings summary and all tied partners',
    () async {
      final repository = ApiProfileRepository(
        fakeApiClient(
          FakeAdapter(
            (options) => (
              200,
              {
                'data': {
                  'highlights': {
                    'partners_count': 17,
                    'opponents_count': 22,
                    'pairings_matches': 31,
                    'most_frequent_partners': [
                      {
                        'name': 'ISOPI RICCARDO',
                        'matches': 4,
                        'wins': 3,
                        'losses': 1,
                      },
                      {
                        'name': 'CATTANEO GIULIO',
                        'matches': 4,
                        'wins': 2,
                        'losses': 2,
                      },
                    ],
                  },
                },
              },
            ),
          ),
        ),
      );
      final stats = await repository.publicStats(
        player: const PlayerRanking(
          playerRef: 'bertolin',
          playerName: 'BERTOLIN FEDERICO',
        ),
      );
      expect(stats.partnersCount, 17);
      expect(stats.opponentsCount, 22);
      expect(stats.pairingsMatches, 31);
      expect(stats.mostFrequentPartners.map((p) => p.name), [
        'ISOPI RICCARDO',
        'CATTANEO GIULIO',
      ]);
    },
  );
}
