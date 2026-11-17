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
}
