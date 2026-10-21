import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _darkThemeKey = 'crpadel_dark_theme';

final themePreferencesProvider = Provider<ThemePreferences>(
  (_) => SharedThemePreferences(),
);

final themeModeProvider = AsyncNotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

abstract interface class ThemePreferences {
  Future<ThemeMode> load();
  Future<void> save(ThemeMode mode);
}

class SharedThemePreferences implements ThemePreferences {
  final _preferences = SharedPreferencesAsync();

  @override
  Future<ThemeMode> load() async {
    final dark = await _preferences.getBool(_darkThemeKey);
    return dark == false ? ThemeMode.light : ThemeMode.dark;
  }

  @override
  Future<void> save(ThemeMode mode) =>
      _preferences.setBool(_darkThemeKey, mode == ThemeMode.dark);
}

class InMemoryThemePreferences implements ThemePreferences {
  InMemoryThemePreferences([this.mode = ThemeMode.dark]);

  ThemeMode mode;

  @override
  Future<ThemeMode> load() async => mode;

  @override
  Future<void> save(ThemeMode value) async => mode = value;
}

class ThemeModeController extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() => ref.read(themePreferencesProvider).load();

  Future<void> toggle() async {
    final current = state.value ?? ThemeMode.dark;
    final next = current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = AsyncData(next);
    await ref.read(themePreferencesProvider).save(next);
  }
}

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider).value ?? ThemeMode.dark;
    final dark = mode == ThemeMode.dark;
    final colors = Theme.of(context).colorScheme;
    return IconButton.outlined(
      onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
      tooltip: dark ? 'Passa al tema chiaro' : 'Passa al tema scuro',
      style: IconButton.styleFrom(
        backgroundColor: colors.surface,
        side: BorderSide(color: colors.outline),
        fixedSize: const Size.square(44),
      ),
      icon: Icon(
        dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        color: colors.onSurface,
      ),
    );
  }
}
