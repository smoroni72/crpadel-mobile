import 'package:crpadel_mobile/app/app.dart';
import 'package:crpadel_mobile/app/bottom_bar.dart';
import 'package:crpadel_mobile/core/utils/dates.dart';
import 'package:crpadel_mobile/features/auth/data/account_deletion_repository.dart';
import 'package:crpadel_mobile/features/auth/presentation/login_screen.dart';
import 'package:crpadel_mobile/features/bookings/data/fake_bookings_repository.dart';
import 'package:crpadel_mobile/features/profile/data/fake_profile_repository.dart';
import 'package:crpadel_mobile/features/profile/domain/profile_models.dart';
import 'package:crpadel_mobile/features/profile/presentation/profile_screen.dart';
import 'package:crpadel_mobile/features/subscriptions/data/fake_subscriptions_repository.dart';
import 'package:crpadel_mobile/features/subscriptions/data/subscription_details_repository.dart';
import 'package:crpadel_mobile/features/subscriptions/presentation/subscription_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/app_overrides.dart';
import '../../helpers/fixtures.dart';

void main() {
  setUpAll(() => initializeDateFormatting(Dates.locale));

  Future<void> openProfile(WidgetTester tester, FakeBackend backend) async {
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
        matching: find.text('Profilo'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
  }

  Future<void> scrollTo(WidgetTester tester, Finder finder) =>
      tester.scrollUntilVisible(
        finder,
        200,
        scrollable: find
            .descendant(
              of: find.byType(ProfileScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );

  testWidgets('card e riquadri come sul sito', (tester) async {
    await openProfile(tester, FakeBackend());

    expect(find.text('Mario Rossi'), findsOneWidget);
    expect(find.text('giocatore@example.com'), findsOneWidget);
    expect(find.text('Fascia Oro'), findsOneWidget);
    expect(find.text('12°'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('63%'), findsWidgets);
  });

  testWidgets('la scheda Abbonamenti compare solo con un pacchetto', (
    tester,
  ) async {
    await openProfile(tester, FakeBackend());
    expect(find.text('Abbonamenti'), findsNothing);
  });

  testWidgets('pacchetto: scheda, card e dettaglio con i dati reali', (
    tester,
  ) async {
    await openProfile(
      tester,
      FakeBackend(subscriptions: FakeSubscriptionsRepository([package()])),
    );

    await tester.ensureVisible(find.text('Abbonamenti'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abbonamenti'));
    await tester.pumpAndSettle();
    expect(find.text('Mattina 10'), findsOneWidget);
    expect(find.text('Disponibili'), findsOneWidget);

    await tester.tap(find.text('Dettagli ›'));
    await tester.pumpAndSettle();
    expect(find.byType(SubscriptionDetailScreen), findsOneWidget);
    expect(find.text('disponibili'), findsOneWidget);
    // Senza i dati del backend le fasce non compaiono.
    expect(find.text('Quando puoi usarlo'), findsNothing);
  });

  testWidgets('dettaglio con fasce e movimenti simulati', (tester) async {
    await openProfile(
      tester,
      FakeBackend(
        subscriptions: FakeSubscriptionsRepository([package()]),
        subscriptionDetails: FakeSubscriptionDetailsRepository(),
      ),
    );
    await tester.ensureVisible(find.text('Abbonamenti'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abbonamenti'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dettagli ›'));
    await tester.pumpAndSettle();

    expect(find.text('Quando puoi usarlo'), findsOneWidget);
    expect(find.text('Lunedì'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('+10'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(SubscriptionDetailScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Movimenti'), findsOneWidget);
    expect(find.text('Acquisto'), findsOneWidget);
    expect(find.text('+10'), findsOneWidget);
  });

  testWidgets('storico: cancella una prenotazione futura', (tester) async {
    final upcoming = booking(id: 'b1');
    final backend = FakeBackend(
      bookings: FakeBookingsRepository([upcoming]),
      profile: FakeProfileRepository(history: [upcoming]),
    );
    await openProfile(tester, backend);

    expect(find.text('Confermata'), findsOneWidget);
    await tester.tap(find.text('Cancella'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annulla prenotazione'));
    await tester.pumpAndSettle();

    expect(backend.bookings.cancelled, ['b1']);
  });

  testWidgets('lezioni: cancella una lezione confermata', (tester) async {
    final profile = FakeProfileRepository(
      lessons: [
        Lesson(
          id: 'l1',
          coachName: 'Luca',
          date: DateTime(2026, 10, 9),
          timeSlot: '10:00-11:00',
          status: LessonStatus.confirmed,
        ),
      ],
    );
    await openProfile(tester, FakeBackend(profile: profile));

    await tester.ensureVisible(find.text('Lezioni'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lezioni'));
    await tester.pumpAndSettle();
    expect(find.text('Lezione con Luca'), findsOneWidget);
    await tester.tap(find.text('Cancella'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancella lezione'));
    await tester.pumpAndSettle();

    expect(profile.cancelledLessons, ['l1']);
    expect(find.text('Cancellata'), findsOneWidget);
  });

  testWidgets('elimina account non disponibile: spiega cosa fare', (
    tester,
  ) async {
    await openProfile(tester, FakeBackend());

    await scrollTo(tester, find.text('Elimina account'));
    await tester.tap(find.text('Elimina account'));
    await tester.pumpAndSettle();

    expect(find.textContaining('non è ancora disponibile'), findsOneWidget);
  });

  testWidgets('elimina account simulato: conferma e uscita', (tester) async {
    final deletion = FakeAccountDeletionRepository();
    await openProfile(tester, FakeBackend(accountDeletion: deletion));

    await scrollTo(tester, find.text('Elimina account'));
    await tester.tap(find.text('Elimina account'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'password');
    await tester.pump();
    final button = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Elimina'),
    );
    expect(button.onPressed, isNotNull);
    await tester.tap(find.text('Elimina'));
    await tester.pumpAndSettle();

    expect(deletion.deleted, ['password']);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('impostazioni e cambio password riportano al login', (
    tester,
  ) async {
    final backend = FakeBackend();
    await openProfile(tester, backend);

    await tester.tap(find.byTooltip('Impostazioni'));
    await tester.pumpAndSettle();
    expect(find.text('Orario preferito'), findsOneWidget);
    expect(find.text('Centro notifiche'), findsOneWidget);
    expect(find.textContaining('Non disponibili'), findsOneWidget);
    expect(find.textContaining('Voci presenti solo'), findsNothing);

    await tester.tap(find.text('Cambia password'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'password');
    await tester.enterText(fields.at(1), 'una-nuova-password');
    await tester.enterText(fields.at(2), 'una-nuova-password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Cambia password'));
    await tester.pumpAndSettle();

    expect(backend.auth.password, 'una-nuova-password');
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(
      find.text('Password cambiata: accedi con la nuova password'),
      findsOneWidget,
    );
  });

  testWidgets('password attuale sbagliata: messaggio del server', (
    tester,
  ) async {
    await openProfile(tester, FakeBackend());
    await tester.tap(find.byTooltip('Impostazioni'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cambia password'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'sbagliata');
    await tester.enterText(fields.at(1), 'una-nuova-password');
    await tester.enterText(fields.at(2), 'una-nuova-password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Cambia password'));
    await tester.pumpAndSettle();

    expect(find.text('Password attuale non valida'), findsOneWidget);
  });
}
