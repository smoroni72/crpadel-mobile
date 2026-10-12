import '../../bookings/domain/booking.dart';
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
  }) : lessonList = [...lessons];

  ProfileStats profileStats;
  List<Booking> history;
  List<Lesson> lessonList;
  final cancelledLessons = <String>[];

  /// Se impostato, ogni chiamata fallisce con questo errore.
  Object? error;

  void _check() {
    if (error != null) throw error!;
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
}
