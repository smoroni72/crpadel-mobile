import 'package:crpadel_mobile/features/profile/data/profile_repository.dart';
import '../../helpers/fake_http.dart';
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
  test(
    'ranking analysis parses equal coefficients and unfinished categories without inference',
    () async {
      final totals = {
        'equal_matches': 4,
        'equal_wins': 3,
        'unfinished_ranking_matches': 1,
        'ranking_matches_without_coefficients': 3,
      };
      final repository = ApiProfileRepository(
        fakeApiClient(
          FakeAdapter(
            (_) => (
              200,
              {
                'data': {'period': totals},
              },
            ),
          ),
        ),
      );
      final stats = await repository.publicStats(
        player: const PlayerRanking(playerRef: 'fabio', playerName: 'Fabio'),
      );
      expect(stats.equalMatches, 4);
      expect(stats.equalWins, 3);
      expect(stats.unfinishedRankingMatches, 1);
      expect(stats.rankingMatchesWithoutCoefficients, 3);
      final admin = AdminPlayerStatistics.fromJson({'totals': totals});
      expect(admin.equalMatches, 4);
      expect(admin.equalWins, 3);
      expect(admin.unfinishedRankingMatches, 1);
    },
  );
}
