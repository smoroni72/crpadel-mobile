import 'package:crpadel_mobile/features/matches/domain/match_score.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('due set vinti dalla stessa squadra', () {
    const score = MatchScore(set1: (6, 4), set2: (6, 3));
    expect(score.error, isNull);
    expect(score.value, '6-4 6-3');
  });

  test('un set a testa richiede il terzo set o il tiebreak', () {
    expect(
      const MatchScore(set1: (6, 4), set2: (3, 6)).error,
      contains('un set ciascuna'),
    );
    const third = MatchScore(
      set1: (6, 4),
      set2: (3, 6),
      thirdSet: ThirdSet.set,
      set3: (7, 6),
    );
    expect(third.value, '6-4 3-6 7-6');
    const tiebreak = MatchScore(
      set1: (6, 4),
      set2: (3, 6),
      thirdSet: ThirdSet.tiebreak,
      set3: (10, 8),
    );
    expect(tiebreak.value, '6-4 3-6 TB 10-8');
  });

  test('errori come sul sito', () {
    expect(
      const MatchScore(set1: (6, null), set2: (6, 3)).error,
      'Inserisci il risultato completo dei primi due set',
    );
    expect(
      const MatchScore(set1: (6, 6), set2: (6, 3)).error,
      'Un set concluso non può terminare in parità',
    );
    expect(
      const MatchScore(
        set1: (6, 4),
        set2: (6, 3),
        thirdSet: ThirdSet.set,
        set3: (6, 2),
      ).error,
      contains('già conclusa in due set'),
    );
    expect(
      const MatchScore(
        set1: (6, 4),
        set2: (3, 6),
        thirdSet: ThirdSet.tiebreak,
        set3: (8, 8),
      ).error,
      'Il tiebreak deve avere un vincitore',
    );
    expect(
      const MatchScore(
        set1: (6, 4),
        set2: (3, 6),
        thirdSet: ThirdSet.set,
        set3: (null, 2),
      ).error,
      'Inserisci il risultato completo del terzo set',
    );
  });
}
