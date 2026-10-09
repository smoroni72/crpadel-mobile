/// Come si chiude il terzo set, se si gioca.
enum ThirdSet { none, set, tiebreak }

/// Risultato al meglio dei tre set, dal punto di vista della squadra A.
///
/// Stesse regole del sito (`src/lib/match-score.js`): i primi due set sono
/// obbligatori e non possono finire pari; se le squadre ne vincono uno a
/// testa serve il terzo set o il tiebreak, altrimenti non va inserito.
class MatchScore {
  const MatchScore({
    required this.set1,
    required this.set2,
    this.thirdSet = ThirdSet.none,
    this.set3,
  });

  final (int?, int?) set1;
  final (int?, int?) set2;
  final ThirdSet thirdSet;
  final (int?, int?)? set3;

  /// Messaggio d'errore, oppure `null` se il risultato è valido.
  String? get error {
    if (_incomplete(set1) || _incomplete(set2)) {
      return 'Inserisci il risultato completo dei primi due set';
    }
    if (set1.$1 == set1.$2 || set2.$1 == set2.$2) {
      return 'Un set concluso non può terminare in parità';
    }
    final split = _winner(set1) != _winner(set2);
    if (split && thirdSet == ThirdSet.none) {
      return 'Le squadre hanno vinto un set ciascuna: inserisci il terzo set '
          'o il tiebreak finale';
    }
    if (!split && thirdSet != ThirdSet.none) {
      return 'La partita è già conclusa in due set: scegli "Nessuno" per il '
          'terzo set';
    }
    if (thirdSet != ThirdSet.none) {
      final third = set3;
      final label = thirdSet == ThirdSet.tiebreak
          ? 'del tiebreak'
          : 'del terzo set';
      if (third == null || _incomplete(third)) {
        return 'Inserisci il risultato completo $label';
      }
      if (third.$1 == third.$2) {
        return thirdSet == ThirdSet.tiebreak
            ? 'Il tiebreak deve avere un vincitore'
            : 'Il terzo set non può finire in parità: se è arrivato 6-6 '
                  'inserisci il risultato finale, ad esempio 7-6';
      }
    }
    return null;
  }

  /// Formato dell'API: `"6-4 3-6 TB 10-8"`. Solo se [error] è `null`.
  String get value {
    assert(error == null);
    final parts = ['${set1.$1}-${set1.$2}', '${set2.$1}-${set2.$2}'];
    if (thirdSet != ThirdSet.none) {
      final third = '${set3!.$1}-${set3!.$2}';
      parts.add(thirdSet == ThirdSet.tiebreak ? 'TB $third' : third);
    }
    return parts.join(' ');
  }

  static bool _incomplete((int?, int?) set) =>
      set.$1 == null || set.$2 == null || set.$1! < 0 || set.$2! < 0;

  static String _winner((int?, int?) set) => set.$1! > set.$2! ? 'A' : 'B';
}
