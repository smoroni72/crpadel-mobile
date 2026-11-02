import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_menu_repository.dart';
import '../domain/app_menu_configuration.dart';

final appMenuConfigurationProvider =
    FutureProvider.autoDispose<AppMenuConfiguration>((ref) async {
      try {
        return await ref.read(appMenuRepositoryProvider).load();
      } catch (_) {
        // Mantiene compatibile l'app durante un aggiornamento graduale del
        // backend: in assenza della configurazione tutte le voci restano attive.
        return AppMenuConfiguration.allEnabled;
      }
    });
