import 'package:crpadel_mobile/app/app.dart';
import 'package:crpadel_mobile/app/bottom_bar.dart';
import 'package:crpadel_mobile/core/utils/dates.dart';
import 'package:crpadel_mobile/features/matches/domain/padel_match.dart';
import 'package:crpadel_mobile/features/matches/presentation/matches_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/app_overrides.dart';
import '../../helpers/fixtures.dart';

void main() {
  setUpAll(() => initializeDateFormatting(Dates.locale));

  FakeBackend backendWith() {
    final b = FakeBackend();
    b.matches.matches = [
      match(
        id: 'mia',
        slot: '18:30-20:00',
        court: 'Campo 2',
        organizerRef: myId,
        bookingId: 'b1',
        players: [
          player('Mario Rossi', userId: myId),
          player('Luca Neri'),
        ],
      ),
      match(
        id: 'altrui',
        slot: '19:00-20:30',
        court: 'Campo 3',
        players: [player('X Y'), player('Z W')],
      ),
      match(
        id: 'con-me',
        slot: '20:30-22:00',
        court: 'Campo 1',
        type: MatchType.friendly,
        players: [
          player('A B'),
          player('Mario Rossi', userId: myId),
        ],
      ),
    ];
    return b;
  }

  Future<void> openMatches(WidgetTester tester, FakeBackend backend) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: backend.overrides,
        retry: (_, _) => null,
        child: const CrPadelApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AppBottomBar),
        matching: find.text('Partite'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MatchesScreen), findsOneWidget);
  }

  testWidgets('Partecipa dalla card: si entra subito', (tester) async {
    final backend = backendWith();
    await openMatches(tester, backend);

    expect(find.text('Partecipa'), findsOneWidget);
    await tester.tap(find.text('Partecipa'));
    await tester.pumpAndSettle();

    expect(backend.matches.joined, ['altrui']);
    expect(find.text('Sei nella partita delle 19:00'), findsOneWidget);
    expect(find.text('Partecipa'), findsNothing);
    expect(find.textContaining('Tua · Aperta · 3/4'), findsOneWidget);
  });

  testWidgets('dal dettaglio si sceglie la squadra', (tester) async {
    final backend = backendWith();
    await openMatches(tester, backend);

    await tester.tap(find.text('Campo 3 · ranking'));
    await tester.pumpAndSettle();
    expect(find.text('Partecipa in squadra A'), findsNothing);
    // X Y e Z W sono in squadra A: resta solo la B.
    await tester.tap(find.text('Partecipa'));
    await tester.pumpAndSettle();

    expect(backend.matches.joined, ['altrui']);
    expect(find.text('Sei nella squadra B'), findsOneWidget);
    expect(find.text('Abbandona partita'), findsOneWidget);
  });

  testWidgets("l'organizzatore non vede «Partecipa» né richieste", (
    tester,
  ) async {
    await openMatches(tester, backendWith());

    await tester.tap(find.text('Campo 2 · ranking'));
    await tester.pumpAndSettle();
    expect(find.text('Organizzi tu'), findsOneWidget);
    expect(find.textContaining('Partecipa'), findsNothing);
    expect(find.text('Richieste in attesa'), findsNothing);
    expect(find.text('Aggiungi giocatore'), findsOneWidget);
    expect(find.text('Annulla prenotazione'), findsOneWidget);
  });

  testWidgets('un partecipante abbandona la partita', (tester) async {
    final backend = backendWith();
    await openMatches(tester, backend);

    await tester.tap(find.text('Campo 1 · amichevole'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abbandona partita'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abbandona'));
    await tester.pumpAndSettle();

    expect(backend.matches.left, ['con-me']);
    expect(find.text('Hai lasciato la partita'), findsOneWidget);
  });

  testWidgets("l'organizzatore inserisce il risultato", (tester) async {
    final backend = backendWith();
    backend.matches.matches = [
      match(
        id: 'giocata',
        court: 'Campo 4',
        status: MatchStatus.pendingResult,
        organizerRef: myId,
        players: [
          player('Mario Rossi', userId: myId),
          player('B B'),
          player('C C'),
          player('D D'),
        ],
      ),
    ];
    await openMatches(tester, backend);

    await tester.tap(find.text('Campo 4 · ranking'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inserisci risultato'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '6');
    await tester.enterText(fields.at(1), '4');
    await tester.enterText(fields.at(2), '3');
    await tester.enterText(fields.at(3), '6');
    await tester.tap(find.text('Salva risultato'));
    await tester.pumpAndSettle();
    expect(find.textContaining('un set ciascuna'), findsOneWidget);

    await tester.tap(find.text('Tiebreak'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(4), '10');
    await tester.enterText(find.byType(TextField).at(5), '7');
    await tester.tap(find.text('Salva risultato'));
    await tester.pumpAndSettle();

    expect(backend.matches.results, {'giocata': '6-4 3-6 TB 10-7'});
    expect(find.text('6-4 3-6 TB 10-7'), findsOneWidget);
  });

  testWidgets('filtro Le mie', (tester) async {
    await openMatches(tester, backendWith());

    await tester.tap(find.text('Le mie'));
    await tester.pumpAndSettle();

    expect(find.text('Mercoledì 7 ottobre'), findsWidgets);
    expect(find.text('Campo 2 · ranking'), findsOneWidget);
    expect(find.text('Campo 1 · amichevole'), findsOneWidget);
    expect(find.text('Campo 3 · ranking'), findsNothing);
  });
}
