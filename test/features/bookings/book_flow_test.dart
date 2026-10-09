import 'package:crpadel_mobile/app/app.dart';
import 'package:crpadel_mobile/app/bottom_bar.dart';
import 'package:crpadel_mobile/core/utils/dates.dart';
import 'package:crpadel_mobile/features/bookings/data/fake_bookings_repository.dart';
import 'package:crpadel_mobile/features/bookings/data/preferred_time_repository.dart';
import 'package:crpadel_mobile/features/bookings/domain/schedule.dart';
import 'package:crpadel_mobile/features/bookings/presentation/book_screen.dart';
import 'package:crpadel_mobile/features/bookings/presentation/complete_booking_screen.dart';
import 'package:crpadel_mobile/features/bookings/presentation/free_courts_screen.dart';
import 'package:crpadel_mobile/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/app_overrides.dart';
import '../../helpers/fixtures.dart';

void main() {
  setUpAll(() => initializeDateFormatting(Dates.locale));

  /// Avvia l'app già autenticata e apre la tab Prenota.
  Future<FakeBackend> openBook(
    WidgetTester tester, {
    FakeBackend? backend,
  }) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final b = backend ?? FakeBackend();
    await tester.pumpWidget(
      ProviderScope(
        overrides: b.overrides,
        retry: (_, _) => null,
        child: const CrPadelApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AppBottomBar),
        matching: find.text('Prenota'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BookScreen), findsOneWidget);
    return b;
  }

  Finder freeAt(String time) =>
      find.bySemanticsLabel('Libero alle $time, prenota');

  Future<void> tapFree(WidgetTester tester, String time) async {
    await tester.ensureVisible(freeAt(time));
    await tester.pumpAndSettle();
    await tester.tap(freeAt(time));
    await tester.pumpAndSettle();
  }

  testWidgets('griglia: campi, impegni e cambio campo', (tester) async {
    final backend = FakeBackend();
    backend.bookings.otherEvents = {
      '2026-10-07': [
        const ScheduleEvent(
          id: 'x',
          courtId: 'c2',
          kind: ScheduleKind.lesson,
          startHour: 17,
          endHour: 18,
        ),
      ],
    };
    await openBook(tester, backend: backend);

    expect(find.text('Mer 7 ott'), findsOneWidget);
    expect(find.text('Campo 1'), findsWidgets);
    // "Lezione" compare già una volta nella legenda.
    expect(find.text('Lezione'), findsOneWidget);

    await tester.tap(find.text('Campo 2 ›'));
    await tester.pumpAndSettle();
    expect(find.text('Lezione'), findsNWidgets(2));
    // Alle 12 di oggi gli orari passati non si prenotano.
    expect(freeAt('11:30'), findsNothing);
    expect(freeAt('12:00'), findsOneWidget);
  });

  testWidgets('prenota uno spazio libero e lo ritrova in Home', (tester) async {
    final backend = await openBook(tester);

    await tapFree(tester, '18:00');
    expect(find.byType(CompleteBookingScreen), findsOneWidget);
    expect(find.text('Mer 7 ott · 18:00–19:30'), findsOneWidget);
    expect(find.text('Mario Rossi (tu)'), findsOneWidget);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );

    await tester.tap(find.text('Conferma prenotazione'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Prenotazione confermata'), findsOneWidget);
    expect(find.text('Campo 1 · 18:00–19:30'), findsOneWidget);
    expect(backend.matches.created, hasLength(1));
  });

  testWidgets('spazio occupato nel frattempo: torna alla griglia', (
    tester,
  ) async {
    final backend = await openBook(tester);
    backend.bookings.conflictOnCreate = true;

    await tapFree(tester, '18:00');
    await tester.tap(find.text('Conferma prenotazione'));
    await tester.pumpAndSettle();

    expect(find.byType(CompleteBookingScreen), findsNothing);
    expect(find.byType(BookScreen), findsOneWidget);
    expect(
      find.textContaining('appena occupato da un altro giocatore'),
      findsOneWidget,
    );
  });

  testWidgets('poco spazio prima di un impegno: messaggio chiaro', (
    tester,
  ) async {
    final backend = FakeBackend();
    backend.bookings.otherEvents = {
      '2026-10-07': [
        const ScheduleEvent(
          id: 'x',
          courtId: 'c1',
          startHour: 18.5,
          endHour: 20,
        ),
      ],
    };
    await openBook(tester, backend: backend);

    await tapFree(tester, '18:00');

    expect(find.byType(CompleteBookingScreen), findsNothing);
    expect(find.textContaining('solo 30 minuti liberi'), findsOneWidget);
  });

  testWidgets('campi liberi all\'orario preferito', (tester) async {
    await openBook(
      tester,
      backend: FakeBackend(preferredTime: const PreferredTime(1140, 1200)),
    );
    expect(find.text('Solo campi liberi alle 19:00'), findsOneWidget);

    await tester.tap(find.text('Solo campi liberi alle 19:00'));
    await tester.pumpAndSettle();

    expect(find.byType(FreeCourtsScreen), findsOneWidget);
    expect(find.text('3 campi liberi alle 19:00'), findsOneWidget);
    expect(find.text('19:00 ★'), findsOneWidget);

    await tester.tap(find.text('Prenota').first);
    await tester.pumpAndSettle();
    expect(find.byType(CompleteBookingScreen), findsOneWidget);
    expect(find.text('Mer 7 ott · 19:00–20:30'), findsOneWidget);
  });

  testWidgets('annulla una propria prenotazione dalla Home', (tester) async {
    final backend = FakeBackend(
      bookings: FakeBookingsRepository([booking(id: 'b1')]),
    );
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

    await tester.tap(find.text('Campo 2 · 18:30–20:00'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annulla prenotazione'));
    await tester.pumpAndSettle();
    // Finestra di conferma.
    await tester.tap(find.text('Annulla prenotazione').last);
    await tester.pumpAndSettle();

    expect(backend.bookings.cancelled, ['b1']);
    expect(find.text('Prenotazione annullata'), findsOneWidget);
    expect(find.text('Nessuna prenotazione in programma'), findsOneWidget);
  });
}
