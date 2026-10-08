import 'package:crpadel_mobile/core/theme/app_theme.dart';
import 'package:crpadel_mobile/core/utils/dates.dart';
import 'package:crpadel_mobile/features/auth/data/auth_repository.dart';
import 'package:crpadel_mobile/features/auth/data/fake_auth_repository.dart';
import 'package:crpadel_mobile/features/auth/presentation/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting(Dates.locale));

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const RegisterScreen(),
        ),
      ),
    );
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  testWidgets('la password si può mostrare e nascondere', (tester) async {
    await pumpScreen(tester);
    EditableText password() => tester.widget<EditableText>(
      find.descendant(
        of: field('Password'),
        matching: find.byType(EditableText),
      ),
    );

    expect(password().obscureText, isTrue);
    await tester.tap(find.byTooltip('Mostra password'));
    await tester.pump();
    expect(password().obscureText, isFalse);
    await tester.tap(find.byTooltip('Nascondi password'));
    await tester.pump();
    expect(password().obscureText, isTrue);
  });

  testWidgets('la data di nascita si scrive con la maschera', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(field('Data di nascita'), '02121990');
    expect(find.text('02/12/1990'), findsOneWidget);
  });

  testWidgets('una data inesistente viene segnalata', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(field('Data di nascita'), '31021990');
    await tester.tap(find.text('Registrati'));
    await tester.pump();
    expect(find.text('Usa il formato gg/mm/aaaa'), findsOneWidget);
  });

  testWidgets('con dati validi la registrazione va a buon fine', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.enterText(field('Nome e cognome'), 'Mario Rossi');
    await tester.enterText(field('Email'), 'mario@example.com');
    await tester.enterText(field('Password'), 'una-password-lunga');
    await tester.enterText(field('Data di nascita'), '02121990');
    await tester.tap(find.text('Sesso'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Maschile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registrati'));
    await tester.pumpAndSettle();

    expect(find.text('Controlla la posta'), findsOneWidget);
  });
}
