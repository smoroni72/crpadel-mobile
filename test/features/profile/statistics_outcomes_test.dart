import 'package:crpadel_mobile/features/profile/domain/profile_models.dart';
import 'package:crpadel_mobile/features/admin/data/admin_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'incomplete matches remain attendance but never dilute decided-result percentages',
    () {
      const old = ProfileStats(
        matchesPlayed: 23,
        matchesWon: 17,
        matchesLost: 5,
        undecided: 1,
      );
      expect(old.decidedMatches, 22);
      expect(old.winRate, 77);
      expect(old.lossRate, 23);
      const current = ProfileStats(
        matchesPlayed: 26,
        matchesWon: 19,
        matchesLost: 6,
        undecided: 1,
      );
      expect(current.winRate, 76);
      expect(current.lossRate, 24);
      const unfinished = ProfileStats(matchesPlayed: 2, undecided: 2);
      expect(unfinished.winRate, 0);
      expect(unfinished.lossRate, 0);
      final admin = AdminPlayerStatistics.fromJson({
        'totals': {
          'matches_played': 26,
          'wins': 19,
          'losses': 6,
          'undecided': 1,
        },
      });
      expect(admin.winRate, current.winRate);
    },
  );
}
