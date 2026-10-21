import '../domain/home_news.dart';
import 'home_repository.dart';

class FakeHomeRepository implements HomeRepository {
  FakeHomeRepository([this.items = const []]);

  List<HomeNews> items;
  Object? error;

  @override
  Future<List<HomeNews>> news({int limit = 6}) async {
    if (error != null) throw error!;
    return items.take(limit).toList();
  }
}
