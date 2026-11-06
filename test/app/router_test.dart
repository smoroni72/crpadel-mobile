import 'package:crpadel_mobile/app/app.dart';
import 'package:crpadel_mobile/app/bottom_bar.dart';
import 'package:crpadel_mobile/app/app_shell.dart';
import 'package:crpadel_mobile/app/router.dart';
import 'package:crpadel_mobile/app/routes.dart';
import 'package:crpadel_mobile/features/auth/data/fake_auth_repository.dart';
import 'package:crpadel_mobile/features/auth/domain/app_user.dart';
import 'package:crpadel_mobile/features/auth/presentation/login_screen.dart';
import 'package:crpadel_mobile/features/auth/presentation/register_screen.dart';
import 'package:crpadel_mobile/features/admin/presentation/admin_screens.dart';
import 'package:crpadel_mobile/features/admin/presentation/admin_create_match_screen.dart';
import 'package:crpadel_mobile/features/bookings/presentation/book_screen.dart';
import 'package:crpadel_mobile/features/bookings/presentation/complete_booking_screen.dart';
import 'package:crpadel_mobile/features/home/presentation/home_screen.dart';
import 'package:crpadel_mobile/features/matches/presentation/matches_screen.dart';
import 'package:crpadel_mobile/features/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/app_overrides.dart';

void main() {
  group('appRedirect', () {
    const user = FakeAuthRepository.demoUser;

    test('senza circolo porta alla scelta del circolo', () {
      expect(
        appRedirect(
          location: AppPaths.home,
          club: null,
          auth: const AsyncData(user),
        ),
        AppPaths.chooseClub,
      );
    });

    test('al primo caricamento mostra lo splash', () {
      expect(
        appRedirect(
          location: AppPaths.home,
          club: 'crpadel',
          auth: const AsyncLoading(),
        ),
        AppPaths.splash,
      );
    });

    test('durante il login resta sul form', () {
      expect(
        appRedirect(
          location: AppPaths.login,
          club: 'crpadel',
          auth: const AsyncLoading(),
        ),
        isNull,
      );
    });

    test('senza utente porta al login, ma lascia aprire la registrazione', () {
      expect(
        appRedirect(
          location: AppPaths.profile,
          club: 'crpadel',
          auth: const AsyncData(null),
        ),
        AppPaths.login,
      );
      expect(
        appRedirect(
          location: '/login/registrazione',
          club: 'crpadel',
          auth: const AsyncData(null),
        ),
        isNull,
      );
    });

    test('con utente porta dallo splash alla home', () {
      expect(
        appRedirect(
          location: AppPaths.splash,
          club: 'crpadel',
          auth: const AsyncData(user),
        ),
        AppPaths.home,
      );
    });

    test('protegge le pagine admin dal collegamento diretto', () {
      expect(
        appRedirect(
          location: AppPaths.admin,
          club: 'crpadel',
          auth: const AsyncData(user),
        ),
        AppPaths.home,
      );
      expect(
        appRedirect(
          location: AppPaths.adminMatches,
          club: 'crpadel',
          auth: const AsyncData(
            AppUser(
              id: 'admin-1',
              email: 'admin@crpadel.it',
              fullName: 'Admin',
              role: 'admin',
              adminMenuPermissions: ['matches'],
            ),
          ),
        ),
        isNull,
      );
      expect(
        appRedirect(
          location: AppPaths.adminUsers,
          club: 'crpadel',
          auth: const AsyncData(
            AppUser(
              id: 'admin-1',
              email: 'admin@crpadel.it',
              fullName: 'Admin',
              role: 'admin',
              adminMenuPermissions: ['matches'],
            ),
          ),
        ),
        AppPaths.admin,
      );
      expect(
        appRedirect(
          location: AppPaths.adminUsers,
          club: 'crpadel',
          auth: const AsyncData(
            AppUser(
              id: 'super-admin-1',
              email: 'superadmin@crpadel.it',
              fullName: 'Super Admin',
              role: 'super_admin',
            ),
          ),
        ),
        isNull,
      );
    });
  });

  group('navigazione', () {
    Future<FakeAuthRepository> pumpApp(
      WidgetTester tester, {
      bool loggedIn = false,
    }) async {
      final repository = FakeAuthRepository(
        sessionUser: loggedIn ? FakeAuthRepository.demoUser : null,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: FakeBackend(auth: repository).overrides,
          retry: (_, _) => null,
          child: const CrPadelApp(),
        ),
      );
      await tester.pumpAndSettle();
      return repository;
    }

    testWidgets('senza sessione mostra il login e apre la registrazione', (
      tester,
    ) async {
      await pumpApp(tester);
      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.tap(find.text('Crea un account'));
      await tester.pumpAndSettle();
      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets('cambiando account cancella la password precedente', (
      tester,
    ) async {
      await pumpApp(tester);
      final email = find.widgetWithText(TextFormField, 'Email');
      final password = find.widgetWithText(TextFormField, 'Password');

      await tester.enterText(email, 'primo@crpadel.it');
      await tester.enterText(password, 'password-precedente');
      await tester.tap(email);
      await tester.enterText(email, 'secondo@crpadel.it');
      await tester.pump();

      expect(tester.widget<TextFormField>(password).controller!.text, isEmpty);
      expect(find.byTooltip('Usa un altro account'), findsOneWidget);
    });

    testWidgets('un accesso errato svuota e seleziona la password', (
      tester,
    ) async {
      await pumpApp(tester);
      final email = find.widgetWithText(TextFormField, 'Email');
      final password = find.widgetWithText(TextFormField, 'Password');

      await tester.enterText(email, 'giocatore@example.com');
      await tester.enterText(password, 'password-errata');
      await tester.tap(find.text('Accedi'));
      await tester.pumpAndSettle();

      expect(find.text('Credenziali non valide'), findsOneWidget);
      expect(tester.widget<TextFormField>(password).controller!.text, isEmpty);
      final editable = find.descendant(
        of: password,
        matching: find.byType(EditableText),
      );
      expect(tester.widget<EditableText>(editable).focusNode.hasFocus, isTrue);
    });

    testWidgets('dopo il login le 4 tab navigano', (tester) async {
      await pumpApp(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'giocatore@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password',
      );
      await tester.tap(find.text('Accedi'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      final bar = find.byType(AppBottomBar);
      await tester.tap(
        find.descendant(of: bar, matching: find.text('Prenota')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BookScreen), findsOneWidget);

      await tester.tap(
        find.descendant(of: bar, matching: find.text('Partite')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MatchesScreen), findsOneWidget);

      await tester.tap(
        find.descendant(of: bar, matching: find.text('Profilo')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('un admin crea la partita scegliendo campo e orario', (
      tester,
    ) async {
      const admin = AppUser(
        id: 'admin-1',
        email: 'admin@crpadel.it',
        fullName: 'Admin',
        role: 'admin',
        adminMenuPermissions: ['matches'],
      );
      final repository = FakeAuthRepository(sessionUser: admin);
      final backend = FakeBackend(auth: repository);
      await tester.pumpWidget(
        ProviderScope(
          overrides: backend.overrides,
          retry: (_, _) => null,
          child: const CrPadelApp(),
        ),
      );
      await tester.pumpAndSettle();

      GoRouter.of(
        tester.element(find.byType(HomeScreen)),
      ).goNamed(AppRoutes.adminMatches);
      await tester.pumpAndSettle();
      expect(find.byType(AdminMatchesScreen), findsOneWidget);

      await tester.tap(find.text('Nuova partita'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AdminCreateMatchScreen), findsOneWidget);
      expect(find.byType(BookScreen), findsNothing);
      expect(find.text('Crea partita'), findsOneWidget);
      expect(find.text('Data della partita'), findsOneWidget);
      expect(find.text('Campo'), findsOneWidget);
      expect(find.text('Orario'), findsOneWidget);
      expect(find.text('Continua con giocatori e dettagli'), findsOneWidget);
      expect(find.byType(AppShell), findsNothing);

      tester
          .widget<DropdownButtonFormField<String>>(
            find.byType(DropdownButtonFormField<String>),
          )
          .onChanged!
          .call('c1');
      await tester.pumpAndSettle();

      tester
          .widget<DropdownButtonFormField<int>>(
            find.byType(DropdownButtonFormField<int>),
          )
          .onChanged!
          .call(8 * 60);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continua con giocatori e dettagli'));
      await tester.pumpAndSettle();
      expect(find.byType(CompleteBookingScreen), findsOneWidget);
      expect(find.text('Mer 7 ott · 08:00–09:30'), findsOneWidget);
      expect(find.text('Prenotato per'), findsNothing);
      expect(find.text('Registra partita'), findsOneWidget);

      await tester.tap(find.text('Registra partita'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminMatchesScreen), findsOneWidget);
      expect(backend.bookings.created, isEmpty);
      expect(backend.matches.created, hasLength(1));
      expect(backend.matches.created.single.timeSlot, '08:00-09:30');
    });

    testWidgets('parte con tema scuro e il sole attiva quello chiaro', (
      tester,
    ) async {
      await pumpApp(tester, loggedIn: true);

      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark,
      );
      await tester.tap(find.byTooltip('Passa al tema chiaro'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.light,
      );
      expect(find.byTooltip('Passa al tema scuro'), findsOneWidget);
    });

    testWidgets('Esci dal profilo riporta al login', (tester) async {
      await pumpApp(tester, loggedIn: true);
      await tester.tap(
        find.descendant(
          of: find.byType(AppBottomBar),
          matching: find.text('Profilo'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Esci'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(ProfileScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('Esci'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('la sessione scaduta riporta al login', (tester) async {
      final repository = await pumpApp(tester, loggedIn: true);
      expect(find.byType(HomeScreen), findsOneWidget);

      repository.expireSession();
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
