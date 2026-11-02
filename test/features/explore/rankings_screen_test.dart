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

  testWidgets('permette di scegliere classifica generale, mensile e decadi', (
    tester,
  ) async {
    final repository = FakeProfileRepository(
      rankings: const [
        PlayerRanking(
          playerRef: 'p1',
          playerName: 'Mario Rossi',
          position: 1,
          eloScore: 1180,
          matchesPlayed: 12,
          matchesWon: 8,
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
            pointsEarned: 39.5,
            monthlyScore: 131.7,
            matchesPlayed: 3,
            matchesWon: 2,
          ),
        ],
      ),
      decadeRankings: const DecadeRankingResult(
        periodStart: '2026-10-21',
        periodEnd: '2026-10-31',
        frozenAt: '2026-10-20',
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

    expect(find.text('Generale'), findsOneWidget);
    expect(find.text('Mensile'), findsOneWidget);
    expect(find.text('Decadi'), findsOneWidget);
    expect(find.text('Classifica generale'), findsOneWidget);
    expect(find.text('1180.0'), findsOneWidget);
    expect(find.text('Classifica mensile'), findsNothing);

    await tester.tap(find.text('Mensile'));
    await tester.pumpAndSettle();

    expect(find.text('Classifica mensile'), findsOneWidget);
    expect(find.text('GIOCATORE DEL MESE'), findsOneWidget);
    expect(
      find.text('Servono almeno 2 partite nel mese per comparire'),
      findsOneWidget,
    );
    expect(find.text('Mario Rossi'), findsWidgets);
    expect(find.text('Classifica generale'), findsNothing);

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
      find.text('Fotografia ufficiale congelata al 20 ottobre 2026'),
      findsOneWidget,
    );
    expect(find.text('Viola · coeff. 7,00'), findsOneWidget);

    await tester.tap(find.text('21 ott – 31 ottobre 2026'));
    await tester.pumpAndSettle();
    expect(find.text('Seleziona la decade'), findsOneWidget);
    expect(find.text('11 ott – 20 ottobre 2026'), findsOneWidget);
  });
}
