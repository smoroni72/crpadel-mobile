import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../domain/app_notification.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => ApiNotificationsRepository(ref.watch(apiClientProvider)),
);

abstract interface class NotificationsRepository {
  Future<List<AppNotification>> list();
  Future<int> unreadCount();
  Future<void> markRead(String id);
  Future<void> markAllRead();
}

class ApiNotificationsRepository implements NotificationsRepository {
  ApiNotificationsRepository(this._api);
  final ApiClient _api;

  @override
  Future<List<AppNotification>> list() async {
    final response = await _api.get('/communications/me/notifications');
    return ((response.data as Map<String, dynamic>)['data'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList();
  }

  @override
  Future<int> unreadCount() async {
    final response = await _api.get(
      '/communications/me/notifications/unread-count',
    );
    return (response.data as Map<String, dynamic>)['count'] as int;
  }

  @override
  Future<void> markRead(String id) async =>
      _api.patch('/communications/me/notifications/$id/read');

  @override
  Future<void> markAllRead() async =>
      _api.post('/communications/me/notifications/read-all');
}
