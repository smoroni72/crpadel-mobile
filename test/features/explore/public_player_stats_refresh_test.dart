import 'package:crpadel_mobile/core/theme/app_theme.dart';
import 'package:crpadel_mobile/features/explore/presentation/public_player_stats_screen.dart';
import 'package:crpadel_mobile/features/profile/data/fake_profile_repository.dart';
import 'package:crpadel_mobile/features/profile/data/profile_repository.dart';
import 'package:crpadel_mobile/features/profile/domain/profile_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

const _general = PlayerRanking(
  playerRef: 'account-id',
  playerName: 'Edoardo De Grandis',
  position: 71,
  eloScore: 1144.2,
);
const _attendance = PlayerRanking(
  playerRef: 'directory-id',
  playerName: 'Edoardo De Grandis',
  position: 71,
  eloScore: 1144.2,
);
const _beforeImport = ProfileStats(
  matchesPlayed: 7,
  matchesWon: 1,
  matchesLost: 6,
);
const _afterImport = ProfileStats(
  matchesPlayed: 11,
  matchesWon: 4,
  matchesLost: 7,
);

Future<void> _openHarness(
  WidgetTester tester,
  FakeProfileRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                for (final entry in [
                  ('Generale', _general),
                  ('Presenze', _attendance),
                ])
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            PublicPlayerStatsScreen(player: entry.$2),
                      ),
                    ),
                    child: Text(entry.$1),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => initializeDateFormatting('it_IT'));

  testWidgets('reopening from either ranking fetches statistics after import', (
    tester,
  ) async {
    final repository = FakeProfileRepository(profileStats: _beforeImport);
    await _openHarness(tester, repository);
    await tester.tap(find.text('Generale'));
    await tester.pumpAndSettle();
    expect(
      find.text('Dati sulle 7 partite registrate nel sistema'),
      findsOneWidget,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    repository.profileStats = _afterImport;
    for (final entry in ['Presenze', 'Generale']) {
      await tester.tap(find.text(entry));
      await tester.pumpAndSettle();
      expect(
        find.text('Dati sulle 11 partite registrate nel sistema'),
        findsOneWidget,
      );
      expect(
        find.text('Dati sulle 7 partite registrate nel sistema'),
        findsNothing,
      );
      expect(find.text('36%'), findsWidgets);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    expect(repository.publicStatsRequests.map((p) => p.playerRef), [
      'account-id',
      'directory-id',
      'account-id',
    ]);
  });

  testWidgets('returning to the app refreshes a player screen left open', (
    tester,
  ) async {
    final repository = FakeProfileRepository(profileStats: _beforeImport);
    await _openHarness(tester, repository);
    await tester.tap(find.text('Generale'));
    await tester.pumpAndSettle();
    expect(repository.publicStatsRequests.length, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    repository.profileStats = _afterImport;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(
      find.text('Dati sulle 11 partite registrate nel sistema'),
      findsOneWidget,
    );
    expect(repository.publicStatsRequests.length, 2);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'recent form and incomplete-result totals use the fetched history, not the stale ranking card',
    (tester) async {
      final stats = ProfileStats(
        matchesPlayed: 26,
        matchesWon: 19,
        matchesLost: 6,
        undecided: 1,
        recentMatches: 5,
        recentWins: 4,
        recentHistory: List.generate(
          5,
          (i) => RecentPlayerMatch(
            id: 'match-$i',
            date: '2026-11-${12 - i}',
            timeSlot: '13:30-15:00',
            courtName: 'Campo 3',
            score: '6-3 6-3',
            resultLabel: i == 3 ? 'Sconfitta' : 'Vittoria',
            won: i != 3,
            teamMates: const [],
            opponents: const [],
            rankingScoreDelta: null,
          ),
        ),
      );
      final repository = FakeProfileRepository(profileStats: stats);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [profileRepositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const PublicPlayerStatsScreen(
              player: PlayerRanking(
                playerRef: 'fabio',
                playerName: 'DI COSTANTINI FABIO',
                position: 3,
                eloScore: 1178.04,
                rankingBandName: 'Arancio',
                rankingBandColor: '#f2a807',
                recentForm: ['V', 'V'],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('FORMA RECENTE · ULTIME 5'), findsOneWidget);
      expect(find.text('V'), findsNWidgets(4));
      expect(find.text('S'), findsOneWidget);
      expect(find.text('76%'), findsWidgets);
      await tester.scrollUntilVisible(
        find.text('Non terminate'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Non terminate'), findsOneWidget);
      expect(find.text('Con esito'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'ranking analysis displays four categories and explains missing coefficients',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const stats = ProfileStats(
        bandName: 'Arancio',
        underdogMatches: 1,
        favoriteMatches: 17,
        equalMatches: 4,
        equalWins: 3,
        unfinishedRankingMatches: 1,
        rankingMatchesWithoutCoefficients: 3,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(
              FakeProfileRepository(profileStats: stats),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const PublicPlayerStatsScreen(
              player: PlayerRanking(playerRef: 'fabio', playerName: 'Fabio'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Analisi ranking'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      final section = find
          .ancestor(
            of: find.text('Analisi ranking'),
            matching: find.byType(Container),
          )
          .first;
      for (final label in [
        'Da sfavorito',
        'Da favorito',
        'A parità',
        'Non terminate',
      ]) {
        expect(
          find.descendant(of: section, matching: find.text(label)),
          findsOneWidget,
        );
      }
      expect(
        find.descendant(of: section, matching: find.text('4')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: section, matching: find.text('3 vittorie')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: section, matching: find.text('Senza esito')),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.textContaining('3 partite Ranking senza coefficienti'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.textContaining('3 partite Ranking senza coefficienti'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
