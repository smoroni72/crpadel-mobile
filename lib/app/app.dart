import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/push/push_controller.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';
import 'router.dart';

class CrPadelApp extends ConsumerWidget {
  const CrPadelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Avvia le notifiche push per tutta la vita dell'app.
    ref.watch(pushPermissionProvider);
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.dark;
    return MaterialApp.router(
      title: 'CRPadel',
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: const Locale('it', 'IT'),
      supportedLocales: const [Locale('it', 'IT')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
