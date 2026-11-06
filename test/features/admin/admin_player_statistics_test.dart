import 'package:crpadel_mobile/features/admin/data/admin_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legge statistiche e punti delle singole partite', () {
    final statistics = AdminPlayerStatistics.fromJson({
      'current_favorite_streak': 3,
      'decade_adjustment_points': '-1.00',
      'totals': {
        'matches_played': 12,
        'wins': 7,
        'losses': 5,
        'ranking_matches': 10,
        'friendly_matches': 1,
        'tournament_matches': 1,
        'sets_won': 16,
        'sets_lost': 12,
        'games_won': 90,
        'games_lost': 82,
        'underdog_matches': 4,
        'underdog_wins': 2,
        'favorite_matches': 6,
        'favorite_wins': 4,
        'ranking_points_earned': '38.50',
        'ranking_points_average': 3.85,
      },
      'matches': [
        {
          'date': '2026-11-06',
          'time_slot': '13:00-14:30',
          'court_name': 'Campo 1',
          'score_team1': '6-4 6-3',
          'status': 'completed',
          'ranking_points_delta': '12.00',
          'ranking_score_delta': '-0.42',
        },
      ],
    });

    expect(statistics.matchesPlayed, 12);
    expect(statistics.winRate, 58);
    expect(statistics.favoriteStreak, 3);
    expect(statistics.decadeAdjustmentPoints, -1);
    expect(statistics.matches.single.rankingPoints, 12);
    expect(statistics.matches.single.rankingScoreDelta, -0.42);
  });
}
