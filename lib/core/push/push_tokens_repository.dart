import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

import '../providers.dart';
import '../network/api_client.dart';

/// Registra il dispositivo dell'utente per le notifiche. Il backend non ha
/// ancora un endpoint per i giocatori (lacuna n. 5): esiste solo il fake,
/// attivo con `FAKE_PUSH_TOKENS=true`. Senza, il provider vale `null` e il
/// token non viene inviato (le notifiche non possono ancora arrivare).
final pushTokensRepositoryProvider = Provider<PushTokensRepository?>(
  (ref) => ApiPushTokensRepository(ref.watch(apiClientProvider)),
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

class ApiPushTokensRepository implements PushTokensRepository {
  ApiPushTokensRepository(this._api);
  final ApiClient _api;

  Future<String> _installationId() async {
    final preferences = await SharedPreferences.getInstance();
    const key = 'crpadel_installation_id';
    final existing = preferences.getString(key);
    if (existing != null) return existing;
    final random = Random.secure();
    final value = '${DateTime.now().microsecondsSinceEpoch}-${List.generate(16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';
    await preferences.setString(key, value);
    return value;
  }

  @override
  Future<void> register({required String token, required String platform}) async {
    await _api.post('/communications/me/push-tokens', data: {
      'token': token,
      'platform': platform,
      'installation_id': await _installationId(),
    });
  }

  @override
  Future<void> unregister(String token) =>
      _api.delete('/communications/me/push-tokens/${Uri.encodeComponent(token)}');
}

/// `android` o `ios`, come la colonna `platform` di `push_tokens`.
String get devicePlatform =>
    defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
