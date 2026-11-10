import 'package:crpadel_mobile/core/theme/app_theme.dart';
import 'package:crpadel_mobile/features/matches/presentation/widgets/result_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tempo scaduto salva anche senza punteggio', (tester) async {
    MatchResultSubmission? submission;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                submission = await showResultSheet(context);
              },
              child: const Text('Apri'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Apri'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tempo scaduto'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('tutti e quattro risultano sconfitti'),
      findsOneWidget,
    );

    await tester.tap(find.text('Salva risultato'));
    await tester.pumpAndSettle();

    expect(submission?.score, isNull);
    expect(submission?.resultOutcome, 'time_expired');
  });
}
