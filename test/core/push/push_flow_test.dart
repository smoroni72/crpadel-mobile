import 'package:crpadel_mobile/app/app.dart';
import 'package:crpadel_mobile/app/bottom_bar.dart';
import 'package:crpadel_mobile/app/routes.dart';
import 'package:crpadel_mobile/core/push/push_controller.dart';
import 'package:crpadel_mobile/core/push/push_messaging.dart';
import 'package:crpadel_mobile/core/push/push_tokens_repository.dart';
import 'package:crpadel_mobile/core/utils/dates.dart';
import 'package:crpadel_mobile/features/auth/data/fake_auth_repository.dart';
import 'package:crpadel_mobile/features/auth/presentation/login_screen.dart';
import 'package:crpadel_mobile/features/matches/presentation/match_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/app_overrides.dart';
import '../../helpers/fixtures.dart';

void main() {
  setUpAll(() => initializeDateFormatting(Dates.locale));

  test('dati della notifica → schermata da aprire', () {
    PushTarget? target(Map<String, String> data) =>
        pushTarget(PushMessage(data: data));

    expect(target({'type': 'match', 'id': 'm1'})?.name, AppRoutes.matchDetail);
    expect(target({'type': 'match', 'id': 'm1'})?.pathParameters, {'id': 'm1'});
    expect(
      target({'type': 'subscription', 'id': 's1'})?.name,
      AppRoutes.subscriptionDetail,
    );
    expect(target({'type': 'booking'})?.name, AppRoutes.home);
    expect(target({'type': 'match'}), isNull);
    expect(target({}), isNull);
    expect(
      target({'destination': 'partite', 'entity_id': 'm1'})?.name,
      AppRoutes.matchDetail,
    );
    expect(
      target({'destination': 'prenotazioni'})?.name,
      AppRoutes.book,
    );
    expect(
      target({'destination': 'abbonamenti'})?.name,
      AppRoutes.profile,
    );
  });

  FakeBackend backendWith({
    required FakePushMessaging push,
    FakePushTokensRepository? tokens,
    bool loggedIn = true,
  }) {
    final b = FakeBackend(
      auth: FakeAuthRepository(
        sessionUser: loggedIn ? FakeAuthRepository.demoUser : null,
      ),
      push: push,
      pushTokens: tokens ?? FakePushTokensRepository(),
    );
    b.matches.matches = [match(id: 'm1', court: 'Campo 3')];
    return b;
  }

  Future<void> start(WidgetTester tester, FakeBackend backend) async {
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
  }

  testWidgets('dopo l\'accesso chiede il permesso e registra il dispositivo', (
    tester,
  ) async {
    final push = FakePushMessaging();
    final tokens = FakePushTokensRepository();
    await start(tester, backendWith(push: push, tokens: tokens));

    expect(push.permissionRequests, 1);
    expect(tokens.registered, {'token-di-prova'});
  });

  testWidgets('permesso negato: nessuna registrazione', (tester) async {
    final push = FakePushMessaging(answer: PushPermission.denied);
    final tokens = FakePushTokensRepository();
    await start(tester, backendWith(push: push, tokens: tokens));

    expect(tokens.registered, isEmpty);
  });

  testWidgets('uscendo il dispositivo viene tolto', (tester) async {
    final push = FakePushMessaging();
    final tokens = FakePushTokensRepository();
    await start(tester, backendWith(push: push, tokens: tokens));

    await tester.tap(
      find.descendant(
        of: find.byType(AppBottomBar),
        matching: find.text('Profilo'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Esci'));
    await tester.tap(find.text('Esci'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(tokens.registered, isEmpty);
    expect(push.deletedTokens, 1);
  });

  testWidgets('notifica in primo piano: avviso con «Apri»', (tester) async {
    final push = FakePushMessaging();
    await start(tester, backendWith(push: push));

    push.foreground.add(
      const PushMessage(
        title: 'Partita completa',
        body: 'Campo 3 alle 19:00',
        data: {'type': 'match', 'id': 'm1'},
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Partita completa · Campo 3 alle 19:00'), findsOneWidget);

    await tester.tap(find.text('Apri'));
    await tester.pumpAndSettle();
    expect(find.byType(MatchDetailScreen), findsOneWidget);
  });

  testWidgets('notifica toccata: apre la partita', (tester) async {
    final push = FakePushMessaging(current: PushPermission.granted);
    await start(tester, backendWith(push: push));

    push.opened.add(const PushMessage(data: {'type': 'match', 'id': 'm1'}));
    await tester.pumpAndSettle();

    expect(find.byType(MatchDetailScreen), findsOneWidget);
  });

  testWidgets('app aperta da una notifica senza sessione: dopo l\'accesso', (
    tester,
  ) async {
    final push = FakePushMessaging(
      launchMessage: const PushMessage(data: {'type': 'match', 'id': 'm1'}),
    );
    await start(tester, backendWith(push: push, loggedIn: false));
    expect(find.byType(LoginScreen), findsOneWidget);

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

    expect(find.byType(MatchDetailScreen), findsOneWidget);
  });

  testWidgets('Impostazioni mostra lo stato delle notifiche', (tester) async {
    final push = FakePushMessaging();
    await start(tester, backendWith(push: push));

    await tester.tap(
      find.descendant(
        of: find.byType(AppBottomBar),
        matching: find.text('Profilo'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Impostazioni'));
    await tester.pumpAndSettle();

    expect(find.text('Attive'), findsOneWidget);
  });
}
