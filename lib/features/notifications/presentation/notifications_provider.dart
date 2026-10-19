import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notifications_repository.dart';
import '../domain/app_notification.dart';

final notificationsProvider = FutureProvider<List<AppNotification>>(
  (ref) => ref.read(notificationsRepositoryProvider).list(),
);

final unreadNotificationsProvider = FutureProvider<int>(
  (ref) => ref.read(notificationsRepositoryProvider).unreadCount(),
);

Future<void> markNotificationRead(WidgetRef ref, String id) async {
  await ref.read(notificationsRepositoryProvider).markRead(id);
  ref.invalidate(notificationsProvider);
  ref.invalidate(unreadNotificationsProvider);
}
