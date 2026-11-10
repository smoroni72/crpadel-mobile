import '../../bookings/domain/booking.dart';
import 'dart:typed_data';
import '../domain/profile_models.dart';
import 'profile_repository.dart';

/// Repository in memoria per test e sviluppo senza backend.
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({
    this.profileStats = const ProfileStats(
      position: 12,
      matchesPlayed: 24,
      matchesWon: 15,
      bandName: 'Oro',
      bandColor: '#E8C468',
    ),
    this.history = const [],
    List<Lesson> lessons = const [],
    this.rankings = const [],
    this.monthlyRankings = const MonthlyRankingResult(
      month: '2026-10',
      minimumMatches: 2,
    ),
    this.decadeRankings = const DecadeRankingResult(),
  }) : lessonList = [...lessons];

  ProfileStats profileStats;
  List<Booking> history;
  List<Lesson> lessonList;
  List<PlayerRanking> rankings;
  MonthlyRankingResult monthlyRankings;
  DecadeRankingResult decadeRankings;
  final cancelledLessons = <String>[];

  /// Se impostato, ogni chiamata fallisce con questo errore.
  Object? error;

  void _check() {
    if (error != null) throw error!;
  }

  @override
  Future<List<PlayerRanking>> leaderboard({int limit = 10}) async {
    _check();
    return rankings.take(limit).toList();
  }

  @override
  Future<MonthlyRankingResult> monthlyLeaderboard({
    required String month,
  }) async {
    _check();
    return MonthlyRankingResult(
      month: month,
      minimumMatches: monthlyRankings.minimumMatches,
      players: monthlyRankings.players,
    );
  }

  @override
  Future<DecadeRankingResult> decadeLeaderboard({String? periodStart}) async {
    _check();
    return decadeRankings;
  }

  @override
  Future<ProfileStats> stats({
    required String userId,
    required String email,
  }) async {
    _check();
    return profileStats;
  }

  @override
  Future<List<Booking>> bookingHistory({required String email}) async {
    _check();
    return history;
  }

  @override
  Future<List<Lesson>> lessons() async {
    _check();
    return lessonList;
  }

  @override
  Future<void> cancelLesson(String lessonId) async {
    _check();
    cancelledLessons.add(lessonId);
    lessonList = [
      for (final l in lessonList)
        l.id == lessonId ? l.copyWith(status: LessonStatus.cancelled) : l,
    ];
  }

  @override
  Future<ProfileStats> updatePhoto({
    Uint8List? jpeg,
    required bool publicConsent,
  }) async {
    _check();
    profileStats = ProfileStats(
      position: profileStats.position,
      matchesPlayed: profileStats.matchesPlayed,
      matchesWon: profileStats.matchesWon,
      bandName: profileStats.bandName,
      bandColor: profileStats.bandColor,
      photoUrl: jpeg == null ? profileStats.photoUrl : '/fake/player.jpg',
      photoStorageId: jpeg == null
          ? profileStats.photoStorageId
          : 'fake-storage',
      photoPublicConsent: publicConsent,
    );
    return profileStats;
  }
}
