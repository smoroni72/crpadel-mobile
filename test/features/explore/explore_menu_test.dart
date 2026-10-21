import 'package:crpadel_mobile/app/app.dart';
import 'package:crpadel_mobile/features/explore/presentation/explore_menu_screen.dart';
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
      'Centro notifiche',
      'Informazioni sul circolo',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });
}
