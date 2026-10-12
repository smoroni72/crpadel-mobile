import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_environment.dart';

/// Eliminazione del proprio account. Il backend non ha ancora un endpoint
/// (lacuna n. 10; anche il pulsante del sito oggi non funziona): esiste solo
/// il fake, attivo con `FAKE_ACCOUNT_DELETION=true`. Senza, il provider vale
/// `null` e l'app spiega che la funzione non è ancora disponibile.
final accountDeletionRepositoryProvider = Provider<AccountDeletionRepository?>(
  (ref) => AppEnvironment.fakeAccountDeletion
      ? FakeAccountDeletionRepository()
      : null,
);

abstract interface class AccountDeletionRepository {
  /// Proposta: `DELETE /me` con la password per conferma.
  Future<void> deleteAccount({required String password});
}

class FakeAccountDeletionRepository implements AccountDeletionRepository {
  final deleted = <String>[];

  @override
  Future<void> deleteAccount({required String password}) async =>
      deleted.add(password);
}
