import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import 'authenticated_shell.dart';

class CrPadelApp extends ConsumerWidget {
  const CrPadelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'CRPadel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: ref
          .watch(authControllerProvider)
          .when(
            data: (user) =>
                user == null ? const LoginScreen() : const AuthenticatedShell(),
            loading: () => const _SplashScreen(),
            error: (_, _) => const LoginScreen(),
          ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BrandMark(),
          SizedBox(height: 24),
          CircularProgressIndicator(),
        ],
      ),
    ),
  );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) => Container(
    width: 96,
    height: 96,
    decoration: BoxDecoration(
      color: AppTheme.navy,
      borderRadius: BorderRadius.circular(24),
    ),
    alignment: Alignment.center,
    child: const Text(
      'CR',
      style: TextStyle(
        color: Colors.white,
        fontSize: 36,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
