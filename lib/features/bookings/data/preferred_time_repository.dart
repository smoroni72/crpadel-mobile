import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/booking_request.dart';

/// Fascia oraria preferita per giocare, es. 19:00–20:00 (inizi ammessi).
class PreferredTime {
  const PreferredTime(this.startMinutes, this.endMinutes)
    : assert(endMinutes > startMinutes);

  final int startMinutes;
  final int endMinutes;

  bool includes(int minutes) =>
      minutes >= startMinutes && minutes <= endMinutes;

  /// "19:00–20:00"
  String get label => '${hhmm(startMinutes)}–${hhmm(endMinutes)}';

  @override
  bool operator ==(Object other) =>
      other is PreferredTime &&
      other.startMinutes == startMinutes &&
      other.endMinutes == endMinutes;

  @override
  int get hashCode => Object.hash(startMinutes, endMinutes);
}

/// Salvato sul dispositivo finché il profilo utente non lo supporta
/// (lacuna n. 4).
final preferredTimeRepositoryProvider = Provider<PreferredTimeRepository>(
  (ref) => SharedPreferencesPreferredTimeRepository(),
);

abstract interface class PreferredTimeRepository {
  Future<PreferredTime?> load();

  /// `null` cancella la preferenza.
  Future<void> save(PreferredTime? value);
}

class SharedPreferencesPreferredTimeRepository
    implements PreferredTimeRepository {
  static const _startKey = 'preferred_time_start';
  static const _endKey = 'preferred_time_end';

  final _prefs = SharedPreferencesAsync();

  @override
  Future<PreferredTime?> load() async {
    final start = await _prefs.getInt(_startKey);
    final end = await _prefs.getInt(_endKey);
    if (start == null || end == null || end <= start) return null;
    return PreferredTime(start, end);
  }

  @override
  Future<void> save(PreferredTime? value) async {
    if (value == null) {
      await _prefs.remove(_startKey);
      await _prefs.remove(_endKey);
      return;
    }
    await _prefs.setInt(_startKey, value.startMinutes);
    await _prefs.setInt(_endKey, value.endMinutes);
  }
}

class InMemoryPreferredTimeRepository implements PreferredTimeRepository {
  InMemoryPreferredTimeRepository([this.value]);

  PreferredTime? value;

  @override
  Future<PreferredTime?> load() async => value;

  @override
  Future<void> save(PreferredTime? value) async => this.value = value;
}
