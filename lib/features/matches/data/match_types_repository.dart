import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tipo di partita proponibile a un giocatore.
class MatchTypeOption {
  const MatchTypeOption(this.code, this.label);

  /// Codice dell'API (`ranking`, `friendly`, …).
  final String code;
  final String label;
}

/// Finché non esiste un endpoint leggibile dai giocatori (lacuna n. 11) si
/// usano i tipi predefiniti; il server rifiuta comunque un tipo non attivo
/// nel circolo con un messaggio chiaro.
final matchTypesRepositoryProvider = Provider<MatchTypesRepository>(
  (ref) => const DefaultMatchTypesRepository(),
);

abstract interface class MatchTypesRepository {
  /// Tipi di partita attivi nel circolo, nell'ordine in cui mostrarli.
  Future<List<MatchTypeOption>> activeTypes();
}

/// Elenco fisso, senza chiamate di rete.
class DefaultMatchTypesRepository implements MatchTypesRepository {
  const DefaultMatchTypesRepository([this.types = defaults]);

  static const defaults = [
    MatchTypeOption('ranking', 'Ranking'),
    MatchTypeOption('friendly', 'Amichevole'),
  ];

  final List<MatchTypeOption> types;

  @override
  Future<List<MatchTypeOption>> activeTypes() async => types;
}
