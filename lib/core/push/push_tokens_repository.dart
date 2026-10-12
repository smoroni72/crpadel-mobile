import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Registra il dispositivo dell'utente per le notifiche. Il backend non ha
/// ancora un endpoint per i giocatori (lacuna n. 5): esiste solo il fake,
/// attivo con `FAKE_PUSH_TOKENS=true`. Senza, il provider vale `null` e il
/// token non viene inviato (le notifiche non possono ancora arrivare).
final pushTokensRepositoryProvider = Provider<PushTokensRepository?>(
  (ref) => const bool.fromEnvironment('FAKE_PUSH_TOKENS')
      ? FakePushTokensRepository()
      : null,
);

abstract interface class PushTokensRepository {
  /// Proposta: `POST /me/push-tokens` con `token` e `platform`.
  Future<void> register({required String token, required String platform});

  /// Proposta: `DELETE /me/push-tokens/:token`.
  Future<void> unregister(String token);
}

class FakePushTokensRepository implements PushTokensRepository {
  final registered = <String>{};

  @override
  Future<void> register({
    required String token,
    required String platform,
  }) async => registered.add(token);

  @override
  Future<void> unregister(String token) async => registered.remove(token);
}

/// `android` o `ios`, come la colonna `platform` di `push_tokens`.
String get devicePlatform =>
    defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
