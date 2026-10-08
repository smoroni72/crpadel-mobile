import 'package:crpadel_mobile/core/network/api_client.dart';
import 'package:crpadel_mobile/core/theme/app_theme.dart';
import 'package:crpadel_mobile/core/utils/dates.dart';
import 'package:crpadel_mobile/features/bookings/data/fake_bookings_repository.dart';
import 'package:crpadel_mobile/features/bookings/domain/booking.dart';
import 'package:crpadel_mobile/features/bookings/presentation/widgets/booking_card.dart';
import 'package:crpadel_mobile/features/home/presentation/home_screen.dart';
import 'package:crpadel_mobile/features/matches/data/fake_matches_repository.dart';
import 'package:crpadel_mobile/features/matches/domain/padel_match.dart';
import 'package:crpadel_mobile/features/subscriptions/data/fake_subscriptions_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/app_overrides.dart';
import '../../helpers/fixtures.dart';

void main() {
  setUpAll(() => initializeDateFormatting(Dates.locale));

  Future<void> pumpHome(WidgetTester tester, FakeBackend backend) async {
    tester.view.physicalSize = const Size(1170, 3600);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: backend.overrides,
        retry: (_, _) => null,
        child: MaterialApp(theme: AppTheme.light(), home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('intestazione con data di oggi e nome', (tester) async {
    await pumpHome(tester, FakeBackend());

    expect(find.text('Mercoledì 7 ottobre'), findsOneWidget);
    expect(find.text('Ciao, Mario'), findsOneWidget);
  });

  testWidgets('senza pacchetti il riferimento non compare', (tester) async {
    await pumpHome(tester, FakeBackend());
    expect(find.textContaining('partite nel pacchetto'), findsNothing);
  });

  testWidgets('con un pacchetto compare il riferimento', (tester) async {
    await pumpHome(
      tester,
      FakeBackend(subscriptions: FakeSubscriptionsRepository([package()])),
    );
    expect(find.textContaining('partite nel pacchetto'), findsOneWidget);
    expect(find.text('Mattina 10 · scade 12/12'), findsOneWidget);
  });

  testWidgets('prenotazioni future con la partita collegata', (tester) async {
    await pumpHome(
      tester,
      FakeBackend(
        bookings: FakeBookingsRepository([
          booking(id: 'b1'),
          booking(
            id: 'b2',
            date: DateTime(2026, 10, 9),
            slot: '10:00-11:00',
            court: 'Campo 1',
            type: BookingType.lesson,
            coach: 'Luca',
          ),
        ]),
        matches: FakeMatchesRepository(
          matches: [
            match(
              bookingId: 'b1',
              date: DateTime(2026, 10, 8),
              organizerRef: myId,
              players: [
                player('Mario Rossi', userId: myId),
                player('A B'),
              ],
            ),
          ],
        ),
      ),
    );

    expect(find.text('Campo 2 · 18:30–20:00'), findsOneWidget);
    expect(find.text('Partita aperta · 2/4'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BookingCard).first,
        matching: find.text('GIO'),
      ),
      findsOneWidget,
    );
    expect(find.text('Campo 1 · 10:00–11:00'), findsOneWidget);
    expect(find.text('Lezione · Luca'), findsOneWidget);
  });

  testWidgets('senza prenotazioni invita a prenotare', (tester) async {
    await pumpHome(tester, FakeBackend());

    expect(find.text('Nessuna prenotazione in programma'), findsOneWidget);
    expect(find.text('Prenota un campo'), findsOneWidget);
  });

  testWidgets('partite del giorno per stato e cambio giorno', (tester) async {
    final matches = FakeMatchesRepository(
      matches: [
        match(
          id: 'conclusa',
          slot: '10:00-11:30',
          court: 'Campo 1',
          status: MatchStatus.completed,
          score: '6-4 6-3',
          players: [
            player('Anna Rossi'),
            player('Bea Bianchi'),
            player('Carla Verdi'),
            player('Dora Neri'),
          ],
        ),
        match(id: 'aperta', players: [player('X Y'), player('Z W')]),
        match(
          id: 'domani',
          date: DateTime(2026, 10, 8),
          court: 'Campo 4',
          type: MatchType.friendly,
        ),
      ],
    );
    await pumpHome(tester, FakeBackend(matches: matches));

    expect(find.text('Campo 1 · conclusa'), findsOneWidget);
    expect(find.text('Rossi/Bianchi vs Verdi/Neri'), findsOneWidget);
    expect(find.text('6-4 6-3'), findsOneWidget);
    expect(find.text('Campo 3 · ranking'), findsOneWidget);
    expect(find.text('Aperta · 2/4 · intermedio'), findsOneWidget);
    expect(find.text('Campo 4 · amichevole'), findsNothing);

    await tester.tap(find.byTooltip('Giorno successivo'));
    await tester.pumpAndSettle();

    expect(find.text('Campo 4 · amichevole'), findsOneWidget);
    expect(find.text('Campo 1 · conclusa'), findsNothing);
    expect(matches.requestedDays.last, DateTime(2026, 10, 8));
  });

  testWidgets('errore di caricamento con Riprova', (tester) async {
    final matches = FakeMatchesRepository(
      error: const ApiException('Server non raggiungibile', statusCode: 503),
    );
    await pumpHome(tester, FakeBackend(matches: matches));

    expect(
      find.text('Non riesco a caricare le partite: Server non raggiungibile'),
      findsOneWidget,
    );

    matches.error = null;
    matches.matches = [match()];
    await tester.tap(find.text('Riprova').last);
    await tester.pumpAndSettle();
    expect(find.text('Campo 3 · ranking'), findsOneWidget);
  });
}
