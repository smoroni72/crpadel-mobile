import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app/app.dart';
import 'core/config/app_environment.dart';
import 'core/network/api_client.dart';
import 'core/providers.dart';
import 'core/utils/dates.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = Dates.locale;
  await initializeDateFormatting(Dates.locale);
  final api = await ApiClient.create(clubSlug: AppEnvironment.clubSlug);
  runApp(
    ProviderScope(
      overrides: [apiClientProvider.overrideWithValue(api)],
      child: const CrPadelApp(),
    ),
  );
}
