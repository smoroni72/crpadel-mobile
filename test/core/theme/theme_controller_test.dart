import 'package:crpadel_mobile/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tema scuro predefinito e scelta persistita', () async {
    final preferences = InMemoryThemePreferences();
    final container = ProviderContainer(
      overrides: [themePreferencesProvider.overrideWithValue(preferences)],
    );
    addTearDown(container.dispose);

    expect(await container.read(themeModeProvider.future), ThemeMode.dark);

    await container.read(themeModeProvider.notifier).toggle();

    expect(container.read(themeModeProvider).value, ThemeMode.light);
    expect(await preferences.load(), ThemeMode.light);
  });
}
