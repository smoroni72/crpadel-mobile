import 'package:crpadel_mobile/app/app.dart';
import 'package:crpadel_mobile/features/explore/presentation/explore_menu_screen.dart';
import 'package:crpadel_mobile/features/app_menu/domain/app_menu_configuration.dart';
import 'package:crpadel_mobile/features/app_menu/presentation/app_menu_provider.dart';
import 'package:crpadel_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/app_overrides.dart';

void main() {
  setUpAll(() => initializeDateFormatting('it_IT'));

  testWidgets('la Home apre il menu con tutte le sezioni concordate', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final backend = FakeBackend();
    await tester.pumpWidget(
      ProviderScope(
        overrides: backend.overrides,
        retry: (_, _) => null,
        child: const CrPadelApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();

    expect(find.byType(ExploreMenuScreen), findsOneWidget);
    for (final label in const [
      'Tornei',
      'Classifiche',
      'Lezioni',
      'Gallery',
      'CRPadel TV',
      'Centro notifiche',
      'Informazioni sul circolo',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('nasconde le sezioni disattivate dall’admin', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appMenuConfigurationProvider.overrideWith(
            (_) async => const AppMenuConfiguration(
              tournaments: false,
              lessons: false,
              gallery: false,
              crpadelTv: false,
              notifications: false,
            ),
          ),
        ],
        retry: (_, _) => null,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const ExploreMenuScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Classifiche'), findsOneWidget);
    expect(find.text('Informazioni sul circolo'), findsOneWidget);
    expect(find.text('Tornei'), findsNothing);
    expect(find.text('Lezioni'), findsNothing);
    expect(find.text('Gallery'), findsNothing);
    expect(find.text('CRPadel TV'), findsNothing);
    expect(find.text('Centro notifiche'), findsNothing);
  });
}
