import 'package:crpadel_mobile/app/bottom_bar.dart';
import 'package:crpadel_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<List<int>> pumpBar(
    WidgetTester tester, {
    required ThemeData theme,
    int index = 0,
  }) async {
    final taps = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          bottomNavigationBar: AppBottomBar(
            currentIndex: index,
            onSelected: taps.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return taps;
  }

  testWidgets('mostra le 4 tab e segnala il tocco', (tester) async {
    final taps = await pumpBar(tester, theme: AppTheme.light());

    for (final label in ['Home', 'Prenota', 'Partite', 'Profilo']) {
      expect(find.text(label), findsOneWidget);
    }
    await tester.tap(find.text('Partite'));
    expect(taps, [2]);
  });

  testWidgets('la tab attiva è marcata come selezionata', (tester) async {
    await pumpBar(tester, theme: AppTheme.light(), index: 1);

    expect(
      tester.getSemantics(find.bySemanticsLabel('Prenota')),
      matchesSemantics(
        label: 'Prenota',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        hasTapAction: true,
      ),
    );
  });

  testWidgets('funziona anche con il tema scuro', (tester) async {
    await pumpBar(tester, theme: AppTheme.dark(), index: 3);
    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.person_rounded), findsOneWidget);
  });
}
