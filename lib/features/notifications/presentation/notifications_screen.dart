import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/push/push_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_value_view.dart';
import '../data/notifications_repository.dart';
import '../domain/app_notification.dart';
import 'notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  Future<void> _open(BuildContext context, WidgetRef ref, AppNotification item) async {
    if (!item.isRead) await markNotificationRead(ref, item.id);
    if (!context.mounted) return;
    final target = notificationTarget(item.destination, item.entityId);
    if (target == null) return;
    if (target.pathParameters.isEmpty) {
      context.goNamed(target.name);
    } else {
      context.pushNamed(target.name, pathParameters: target.pathParameters);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifiche'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(notificationsRepositoryProvider).markAllRead();
              ref.invalidate(notificationsProvider);
              ref.invalidate(unreadNotificationsProvider);
            },
            child: const Text('Segna tutte lette'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(notificationsProvider.future),
        child: AsyncValueView(
          value: items,
          errorText: 'Non riesco a caricare le notifiche',
          onRetry: () => ref.invalidate(notificationsProvider),
          data: (list) => list.isEmpty
              ? ListView(children: const [SizedBox(height: 180), Center(child: Text('Nessuna notifica'))])
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return Card(
                      color: item.isRead ? null : context.colors.primary.withValues(alpha: .08),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _open(context, ref, item),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (item.imageUrl case final url?) ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(url, height: 150, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink()),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!item.isRead) Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 7, right: 10), decoration: BoxDecoration(color: context.colors.primary, shape: BoxShape.circle)),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 4), Text(item.body),
                                    const SizedBox(height: 8), Text(DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt), style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
                                  ])),
                                  if (item.destination != null) const Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
