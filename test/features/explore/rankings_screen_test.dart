import 'package:crpadel_mobile/features/explore/presentation/rankings_screen.dart';
import 'package:crpadel_mobile/core/theme/app_theme.dart';
import 'package:crpadel_mobile/features/profile/data/fake_profile_repository.dart';
import 'package:crpadel_mobile/features/profile/data/profile_repository.dart';
import 'package:crpadel_mobile/features/profile/domain/profile_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  setUpAll(() => initializeDateFormatting('it_IT'));

  testWidgets(
    'classifica presenze mostra storico ed esiti su schermo telefono',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = FakeProfileRepository(
        matchSummary: const RankingMatchSummary(
          totalPlayed: 470,
          since: '2026-06-01',
        ),
        mostPlayed: const MostPlayedRankingResult(
          since: '2026-06-01',
          players: [
            MostPlayedPlayer(
              position: 1,
              playerRef: 'directory-1',
              ranking: PlayerRanking(
                playerRef: 'user-1',
                playerName: 'Giocatore Storico',
                eloScore: 1187.25,
              ),
              name: 'Giocatore Storico',
              matchesPlayed: 97,
              wins: 79,
              losses: 18,
              tiebreaksPlayed: 7,
              tiebreaksWon: 5,
              setsWon: 29,
              setsLost: 4,
              gamesWon: 177,
              gamesLost: 105,
              matchesWithScore: 15,
              difficultyLevel: 'Altissimo',
              underdogMatches: 12,
              underdogWins: 8,
              underdogMatchPercentage: 80,
              matchesWithCoefficients: 15,
            ),
            MostPlayedPlayer(
              position: 8,
              playerRef: 'directory-2',
              name: 'Altro Giocatore',
              matchesPlayed: 10,
              wins: 4,
              losses: 6,
              setsWon: 7,
              setsLost: 12,
              gamesWon: 60,
              gamesLost: 90,
              matchesWithScore: 10,
              difficultyLevel: 'Bassissimo',
              underdogMatchPercentage: 0,
              matchesWithCoefficients: 10,
            ),
            MostPlayedPlayer(
              position: 9,
              playerRef: 'directory-3',
              name: 'Coefficienti assenti',
              matchesPlayed: 4,
              wins: 0,
              losses: 4,
              setsWon: 0,
              setsLost: 0,
              gamesWon: 0,
              gamesLost: 0,
              matchesWithScore: 1,
            ),
          ],
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [profileRepositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(
            theme: AppTheme.light(),
            locale: const Locale('it', 'IT'),
            home: const RankingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('470'), findsOneWidget);
      expect(find.textContaining('Dal 1 giugno 2026'), findsOneWidget);
      await tester.tap(find.text('Chi ha giocato di più'));
      await tester.pumpAndSettle();
      expect(find.text('Classifica presenze Ranking'), findsOneWidget);
      expect(find.text('Giocatore Storico'), findsOneWidget);
      expect(find.text('97'), findsOneWidget);
      expect(find.text('Vittorie  79'), findsOneWidget);
      expect(find.text('Sconfitte  18'), findsOneWidget);
      expect(find.text('Set vinti  29'), findsOneWidget);
      expect(find.text('Set persi  4'), findsOneWidget);
      expect(find.text('Game vinti  177'), findsOneWidget);
      expect(find.text('Game persi  105'), findsOneWidget);
      expect(find.text('Tie-break giocati  7'), findsOneWidget);
      expect(find.text('Tie-break vinti  5'), findsOneWidget);
      expect(
        find.text('Set, game e tie-break: 15 partite con dettaglio'),
        findsOneWidget,
      );
      expect(find.text('80% — Altissimo'), findsOneWidget);
      expect(
        find.text('12 da sfavorito su 15 partite con coefficienti'),
        findsOneWidget,
      );
      expect(find.text('Non disponibile'), findsOneWidget);
      expect(find.text('0% — Bassissimo'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final search = find.byKey(const ValueKey('attendance-player-search'));
      await tester.enterText(search, 'altro');
      await tester.pumpAndSettle();
      expect(find.text('Altro Giocatore'), findsOneWidget);
      expect(find.text('Giocatore Storico'), findsNothing);
      expect(find.text('8°'), findsOneWidget);
      await tester.enterText(search, 'nessun-nome');
      await tester.pumpAndSettle();
      expect(find.text('Nessun giocatore trovato'), findsOneWidget);
      await tester.tap(find.byTooltip('Cancella ricerca'));
      await tester.pumpAndSettle();
      expect(find.text('Altro Giocatore'), findsOneWidget);
      expect(find.text('Giocatore Storico'), findsOneWidget);
      await tester.enterText(search, '  storico GIOCATORE ');
      await tester.pumpAndSettle();
      expect(find.text('Altro Giocatore'), findsNothing);
      await tester.ensureVisible(find.text('Giocatore Storico'));
      await tester.tap(find.text('Giocatore Storico'));
      await tester.pumpAndSettle();
      expect(find.text('Statistiche giocatore'), findsOneWidget);
      expect(find.text('1187.25'), findsOneWidget);
      expect(repository.publicStatsRequests.single.playerRef, 'directory-1');
      expect(repository.publicStatsRequests.single.position, 0);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('  storico GIOCATORE '), findsOneWidget);
      expect(find.text('Altro Giocatore'), findsNothing);
      await tester.ensureVisible(search);
      await tester.tap(find.byTooltip('Cancella ricerca'));
      await tester.pumpAndSettle();
      final sort = find.byKey(const ValueKey('attendance-sort'));
      await tester.ensureVisible(sort);
      await tester.tap(sort);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Da sfavorito: % più bassa').last);
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('Altro Giocatore')).dy,
        lessThan(tester.getTopLeft(find.text('Giocatore Storico')).dy),
      );
      await tester.enterText(search, 'storico');
      await tester.pumpAndSettle();
      expect(find.text('2°'), findsOneWidget);
      expect(find.text('Altro Giocatore'), findsNothing);
    },
  );

  testWidgets('permette di scegliere classifica generale, mensile e decadi', (
    tester,
  ) async {
    final repository = FakeProfileRepository(
      matchSummary: const RankingMatchSummary(
        totalPlayed: 132,
        since: '2026-10-01',
      ),
      rankings: const [
        PlayerRanking(
          playerRef: 'p1',
          playerName: 'Mario Rossi',
          position: 1,
          eloScore: 1180,
          matchesPlayed: 12,
          matchesWon: 8,
          recentForm: ['V', 'S', 'V', 'V', 'S'],
        ),
      ],
      monthlyRankings: const MonthlyRankingResult(
        month: '2026-10',
        minimumMatches: 2,
        players: [
          MonthlyRanking(
            position: 1,
            playerRef: 'p1',
            playerName: 'Mario Rossi',
            pointsEarned: 48,
            monthlyScore: 160,
            matchesPlayed: 3,
            matchesWon: 2,
            classificationDelta: 4.2,
            generalLeaderboardQualified: true,
            playerOfMonthEligible: true,
          ),
          MonthlyRanking(
            position: 2,
            playerRef: 'p2',
            playerName: 'Luigi Bianchi',
            pointsEarned: 39.5,
            monthlyScore: 131.7,
            matchesPlayed: 3,
            matchesWon: 3,
            classificationDelta: 8,
          ),
        ],
      ),
      decadeRankings: const DecadeRankingResult(
        periodStart: '2026-10-21',
        periodEnd: '2026-10-31',
        frozenAt: '2026-10-31',
        periodClosed: true,
        minimumMatches: 7,
        availablePeriods: [
          RankingDecadePeriod(start: '2026-10-21', end: '2026-10-31'),
          RankingDecadePeriod(start: '2026-10-11', end: '2026-10-20'),
        ],
        players: [
          DecadeRankingPlayer(
            playerRef: 'p1',
            playerName: 'Mario Rossi',
            position: 1,
            eloScore: 1175.4,
            coefficient: 7,
            rankingBandName: 'Viola',
            rankingBandColor: '#CC00DD',
          ),
        ],
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [profileRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('it', 'IT'),
          home: const RankingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('PARTITE GIOCATE'), findsOneWidget);
    expect(find.text('132'), findsOneWidget);
    expect(find.textContaining('Dal 1 ottobre 2026'), findsOneWidget);
    repository.matchSummary = const RankingMatchSummary(
      totalPlayed: 133,
      since: '2026-10-01',
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(find.text('133'), findsOneWidget);
    expect(find.text('Ultime 5'), findsOneWidget);
    expect(find.text('V'), findsNWidgets(3));
    expect(find.text('S'), findsNWidgets(2));

    expect(find.text('Generale'), findsOneWidget);
    expect(find.text('Mensile'), findsOneWidget);
    expect(find.text('Decadi'), findsOneWidget);
    expect(find.text('Classifica generale'), findsOneWidget);
    expect(find.text('1180.0'), findsOneWidget);
    expect(find.text('Classifica mensile'), findsNothing);

    await tester.tap(find.text('Mario Rossi'));
    await tester.pumpAndSettle();
    expect(find.text('Statistiche giocatore'), findsOneWidget);
    expect(find.text('Rendimento'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Analisi ranking'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Analisi ranking'), findsOneWidget);
    expect(find.textContaining('Punti classifica'), findsNothing);
    expect(find.textContaining('Media classifica'), findsNothing);
    await tester.drag(find.byType(ListView).last, const Offset(0, -1300));
    await tester.pumpAndSettle();
    expect(find.textContaining('pagamenti'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mensile'));
    await tester.pumpAndSettle();

    expect(find.text('Classifica mensile'), findsOneWidget);
    expect(find.text('GIOCATORE DEL MESE'), findsOneWidget);
    expect(find.text('Ordina per'), findsNothing);
    expect(find.text('PR totali'), findsNothing);
    expect(find.text('+8,0'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Luigi Bianchi')).dy,
      lessThan(tester.getTopLeft(find.text('Mario Rossi').last).dy),
      reason:
          'La graduatoria deve seguire il delta anche quando i PR sono più bassi',
    );
    expect(find.text('Solo idonei'), findsOneWidget);
    expect(find.text('Mario Rossi'), findsWidgets);
    expect(find.text('Luigi Bianchi'), findsOneWidget);
    expect(find.text('Classifica generale'), findsNothing);

    await tester.tap(find.text('Solo idonei'));
    await tester.pumpAndSettle();
    expect(find.text('Mario Rossi'), findsWidgets);
    expect(find.text('Luigi Bianchi'), findsNothing);

    await tester.tap(find.byIcon(Icons.calendar_month_outlined).last);
    await tester.pumpAndSettle();

    expect(find.text('Seleziona il mese'), findsOneWidget);
    expect(find.byType(CalendarDatePicker), findsNothing);
    final now = DateTime.now();
    final futureLabel = DateFormat(
      'MMMM yyyy',
      'it_IT',
    ).format(DateTime(now.year + 1, now.month));
    expect(find.text(futureLabel), findsNothing);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Decadi'));
    await tester.pumpAndSettle();

    expect(find.text('Classifiche delle decadi'), findsOneWidget);
    expect(
      find.text('Fotografia ufficiale congelata al 31 ottobre 2026'),
      findsOneWidget,
    );
    expect(find.text('Viola · coeff. 7,00'), findsOneWidget);
    expect(find.text('Decade conclusa'), findsOneWidget);
    expect(find.text('Decade in corso'), findsNothing);

    await tester.tap(find.text('21 ott – 31 ottobre 2026'));
    await tester.pumpAndSettle();
    expect(find.text('Seleziona la decade'), findsOneWidget);
    expect(find.text('11 ott – 20 ottobre 2026'), findsOneWidget);
  });
  testWidgets('la decade in corso mostra la chiusura precedente', (
    tester,
  ) async {
    final repository = FakeProfileRepository(
      decadeRankings: const DecadeRankingResult(
        periodStart: '2026-11-01',
        periodEnd: '2026-11-10',
        frozenAt: '2026-10-31',
        minimumMatches: 8,
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [profileRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const RankingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Decadi'));
    await tester.pumpAndSettle();
    expect(find.text('Decade in corso'), findsOneWidget);
    expect(find.text('Decade conclusa'), findsNothing);
    expect(
      find.text('Fotografia ufficiale congelata al 31 ottobre 2026'),
      findsOneWidget,
    );
    expect(
      find.textContaining('sono mostrati i risultati della decade precedente'),
      findsOneWidget,
    );
  });
}
