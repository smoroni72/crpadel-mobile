import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _pushEnabledKey = 'crpadel_push_notifications_enabled';

final pushPreferencesProvider = Provider<PushPreferences>(
  (_) => SharedPushPreferences(),
);

/// Preferenza scelta dal giocatore. Se non è mai stata modificata, gli avvisi
/// restano attivi come nelle versioni precedenti dell'app.
final pushNotificationsEnabledProvider = FutureProvider<bool>(
  (ref) => ref.watch(pushPreferencesProvider).isEnabled(),
);

abstract interface class PushPreferences {
  Future<bool> isEnabled();
  Future<void> setEnabled(bool enabled);
}

class SharedPushPreferences implements PushPreferences {
  final _preferences = SharedPreferencesAsync();

  @override
  Future<bool> isEnabled() async =>
      await _preferences.getBool(_pushEnabledKey) ?? true;

  @override
  Future<void> setEnabled(bool enabled) =>
      _preferences.setBool(_pushEnabledKey, enabled);
}

class InMemoryPushPreferences implements PushPreferences {
  InMemoryPushPreferences([this.enabled = true]);

  bool enabled;

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Future<void> setEnabled(bool enabled) async => this.enabled = enabled;
}
