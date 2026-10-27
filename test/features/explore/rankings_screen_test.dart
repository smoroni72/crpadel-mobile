import 'package:crpadel_mobile/features/explore/presentation/rankings_screen.dart';
import 'package:crpadel_mobile/core/theme/app_theme.dart';
import 'package:crpadel_mobile/features/profile/data/fake_profile_repository.dart';
import 'package:crpadel_mobile/features/profile/data/profile_repository.dart';
import 'package:crpadel_mobile/features/profile/domain/profile_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('it_IT'));

  testWidgets('mostra classifica mensile e giocatore del mese', (tester) async {
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

    expect(find.text('Classifica mensile'), findsOneWidget);
    expect(find.text('GIOCATORE DEL MESE'), findsOneWidget);
    expect(
      find.text('Servono almeno 2 partite nel mese per comparire'),
      findsOneWidget,
    );
    expect(find.text('Mario Rossi'), findsWidgets);
    expect(find.text('Classifica generale'), findsOneWidget);
  });
}
