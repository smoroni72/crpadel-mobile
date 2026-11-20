import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crpadel_mobile/features/profile/data/player_card_pdf.dart';
import 'package:crpadel_mobile/features/profile/presentation/widgets/player_expected_performance.dart';
import 'package:crpadel_mobile/features/profile/data/profile_repository.dart';
import 'package:crpadel_mobile/features/profile/domain/profile_models.dart';
import '../../helpers/fake_http.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final expectation = {
    'status': 'ready',
    'matches_played': 25,
    'wins': 19,
    'expected_wins': 16.1,
    'extra_wins_per_10': 1.16,
    'provisional': true,
  };
  testWidgets('rendimento mostra il confronto senza etichette sperimentali', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PlayerExpectedPerformance(value: expectation)),
      ),
    );
    expect(find.text('+1,16'), findsOneWidget);
    expect(find.text('Vittorie attese'), findsOneWidget);
    expect(find.textContaining('Sperimentale'), findsNothing);
    expect(find.textContaining('provvisorio'), findsNothing);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PlayerExpectedPerformance(value: {'status': 'no_matches'}),
        ),
      ),
    );
    expect(find.textContaining('Nessuna partita Ranking'), findsOneWidget);
    expect(find.text('+0,00'), findsNothing);
  });
  test(
    'profilo pubblico legge il rendimento del periodo restituito dal server',
    () async {
      final repo = ApiProfileRepository(
        fakeApiClient(
          FakeAdapter(
            (_) => (
              200,
              {
                'data': {
                  'period': {},
                  'performance_expectation': {'period': expectation},
                },
              },
            ),
          ),
        ),
      );
      final stats = await repo.publicStats(
        player: const PlayerRanking(playerRef: 'p', playerName: 'Giocatore'),
      );
      expect(stats.performanceExpectation, {
        ...expectation,
        'excluded_details': [],
      });
    },
  );
  test(
    'carta PDF genera un documento anche senza foto, ranking o risultati',
    () async {
      final bytes = await buildPlayerCardPdf(
        {
          'card': {
            'player': {'name': 'Giocatore senza incontri'},
          },
        },
        font: await rootBundle.load('assets/fonts/Inter-Regular.ttf'),
        bold: await rootBundle.load('assets/fonts/Inter-SemiBold.ttf'),
      );
      expect(ascii.decode(bytes.take(4).toList()), '%PDF');
      expect(bytes.length, greaterThan(10000));
    },
  );
  final fixture = Platform.environment['PLAYER_CARD_QA_FIXTURE'];
  if (fixture != null) {
    test('render QA dei profili reali', () async {
      final cards = jsonDecode(await File(fixture).readAsString()) as List;
      for (var i = 0; i < cards.length; i++) {
        final data = Map<String, dynamic>.from(cards[i] as Map);
        final bytes = await buildPlayerCardPdf(
          data,
          font: await rootBundle.load('assets/fonts/Inter-Regular.ttf'),
          bold: await rootBundle.load('assets/fonts/Inter-SemiBold.ttf'),
          heading: await rootBundle.load('assets/fonts/SpaceGrotesk-Bold.ttf'),
          mono: await rootBundle.load('assets/fonts/JetBrainsMono-Medium.ttf'),
          animal: data['qa_animal_path'] == null
              ? null
              : await File(data['qa_animal_path'] as String).readAsBytes(),
          photo: data['qa_photo_path'] == null
              ? null
              : await File(data['qa_photo_path'] as String).readAsBytes(),
          logo: (await rootBundle.load(
            'assets/brand/crpadel_logo.png',
          )).buffer.asUint8List(),
        );
        await File('/tmp/player-card-mobile-qa-$i.pdf').writeAsBytes(bytes);
      }
    });
  }
}
