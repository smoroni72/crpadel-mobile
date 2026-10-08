import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/app_environment.dart';
import 'core/network/api_client.dart';
import 'core/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = await ApiClient.create(clubSlug: AppEnvironment.clubSlug);
  runApp(
    ProviderScope(
      overrides: [apiClientProvider.overrideWithValue(api)],
      child: const CrPadelApp(),
    ),
  );
}
