import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/data/profile_repository.dart';
import '../../profile/domain/profile_models.dart';
import '../data/home_repository.dart';
import '../domain/home_news.dart';

final homeLeaderboardProvider = FutureProvider<List<PlayerRanking>>(
  (ref) => ref.read(profileRepositoryProvider).leaderboard(),
);

final homeNewsProvider = FutureProvider<List<HomeNews>>(
  (ref) => ref.read(homeRepositoryProvider).news(),
);
