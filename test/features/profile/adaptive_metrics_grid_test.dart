import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crpadel_mobile/core/widgets/adaptive_metrics_grid.dart';

void main() {
  testWidgets(
    'captions remain readable in aligned rows on narrow screens with larger text',
    (tester) async {
      tester.view.physicalSize = const Size(960, 1800);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: AdaptiveMetricsGrid(
                    children: [
                      for (final caption in [
                        'Ranking',
                        'Amichevoli',
                        'Tornei',
                        '0 senza esito · 1 tempo scaduto',
                      ])
                        Container(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              const Text('Non concluse'),
                              const Text('1', style: TextStyle(fontSize: 24)),
                              Text(caption),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('0 senza esito · 1 tempo scaduto'), findsOneWidget);
    },
  );
}
