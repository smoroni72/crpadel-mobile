import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'app_environment.dart';

/// Slug del circolo in uso, inviato dall'`ApiClient` in `X-Club-Slug`.
///
/// `null` vuol dire che l'utente deve ancora scegliere il circolo. Finché il
/// backend non espone l'elenco dei circoli (lacuna n. 8) vale sempre
/// `CLUB_SLUG`.
final currentClubProvider = NotifierProvider<CurrentClubController, String?>(
  CurrentClubController.new,
);

class CurrentClubController extends Notifier<String?> {
  @override
  String? build() => AppEnvironment.clubSlug;

  void select(String slug) {
    ref.read(apiClientProvider).clubSlug = slug;
    state = slug;
  }
}
