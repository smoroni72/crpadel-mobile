import 'package:crpadel_mobile/app/app.dart';
import 'package:crpadel_mobile/app/router.dart';
import 'package:crpadel_mobile/app/routes.dart';
import 'package:crpadel_mobile/features/auth/data/auth_repository.dart';
import 'package:crpadel_mobile/features/auth/data/fake_auth_repository.dart';
import 'package:crpadel_mobile/features/auth/presentation/login_screen.dart';
import 'package:crpadel_mobile/features/auth/presentation/register_screen.dart';
import 'package:crpadel_mobile/features/bookings/presentation/book_screen.dart';
import 'package:crpadel_mobile/features/home/presentation/home_screen.dart';
import 'package:crpadel_mobile/features/matches/presentation/matches_screen.dart';
import 'package:crpadel_mobile/features/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
          overrides: [authRepositoryProvider.overrideWithValue(repository)],
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

      final bar = find.byType(NavigationBar);
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

    testWidgets('Esci dal profilo riporta al login', (tester) async {
      await pumpApp(tester, loggedIn: true);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Profilo'),
        ),
      );
      await tester.pumpAndSettle();

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
