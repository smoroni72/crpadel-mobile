import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bookings/data/bookings_repository.dart';
import '../../bookings/domain/coach.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/profile_models.dart';
import '../data/explore_repository.dart';
import '../domain/explore_models.dart';

final tournamentsProvider = FutureProvider<List<ClubTournament>>(
  (ref) => ref.read(exploreRepositoryProvider).tournaments(),
);

final galleryProvider = FutureProvider<List<GalleryEvent>>(
  (ref) => ref.read(exploreRepositoryProvider).gallery(),
);

final clubInfoProvider = FutureProvider<ClubInfo>(
  (ref) => ref.read(exploreRepositoryProvider).clubInfo(),
);

final fullRankingsProvider = FutureProvider<List<PlayerRanking>>(
  (ref) => ref.read(profileRepositoryProvider).leaderboard(limit: 200),
);

final monthlyRankingsProvider =
    FutureProvider.family<MonthlyRankingResult, String>(
      (ref, month) =>
          ref.read(profileRepositoryProvider).monthlyLeaderboard(month: month),
    );

final publicCoachesProvider = FutureProvider<List<Coach>>(
  (ref) => ref.read(bookingsRepositoryProvider).coaches(),
);
