import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';
import '../../app/routes.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/notifications/data/notifications_repository.dart';
import '../../features/notifications/presentation/notifications_provider.dart';
import 'push_messaging.dart';
import 'push_tokens_repository.dart';

/// Messenger dell'app, per gli avvisi delle notifiche in primo piano.
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Stato del permesso per le notifiche, letto da Impostazioni.
final pushPermissionProvider = NotifierProvider<PushController, PushPermission>(
  PushController.new,
);

/// Collega FCM all'app: permesso e token dopo l'accesso, avvisi in primo
/// piano, apertura della schermata giusta al tocco.
class PushController extends Notifier<PushPermission> {
  PushMessaging? get _push => ref.read(pushMessagingProvider);
  PushTokensRepository? get _tokens => ref.read(pushTokensRepositoryProvider);

  String? _registered;
  PushMessage? _pending;
  DateTime? _lastSync;

  @override
  PushPermission build() {
    final push = _push;
    if (push == null) return PushPermission.unavailable;
    final subscriptions = [
      push.onForeground.listen(_showInApp),
      push.onOpened.listen(_open),
      push.onTokenRefresh.listen(_register),
    ];
    final lifecycle = AppLifecycleListener(onResume: () => unawaited(_refreshToken()));
    ref.onDispose(() {
      lifecycle.dispose();
      for (final s in subscriptions) {
        s.cancel();
      }
    });
    ref.listen(authControllerProvider, (previous, next) {
      final wasIn = previous?.value != null;
      final isIn = next.value != null;
      if (!wasIn && isIn) unawaited(_onLogin());
      if (wasIn && !isIn) unawaited(_onLogout());
    }, fireImmediately: true);
    unawaited(_readInitial(push));
    return PushPermission.notDetermined;
  }

  Future<void> _readInitial(PushMessaging push) async {
    state = await push.permission();
    final launch = await push.initialMessage();
    if (launch != null) _open(launch);
  }

  /// Chiede il permesso (se serve) e registra il dispositivo.
  Future<void> _onLogin() async {
    await requestPermission();
    final pending = _pending;
    if (pending != null) {
      _pending = null;
      _navigate(pending);
    }
  }

  Future<PushPermission> requestPermission() async {
    final push = _push;
    if (push == null) return PushPermission.unavailable;
    state = await push.requestPermission();
    if (state == PushPermission.granted) {
      final token = await push.token();
      if (token != null) await _register(token);
    }
    return state;
  }

  Future<void> _register(String token) async {
    if (ref.read(authControllerProvider).value == null) return;
    try {
      await _tokens?.register(token: token, platform: devicePlatform);
      _registered = token;
      _lastSync = DateTime.now();
    } catch (_) {
      // Riproveremo al prossimo avvio o al rinnovo del token.
    }
  }

  Future<void> _refreshToken() async {
    if (ref.read(authControllerProvider).value == null) return;
    final lastSync = _lastSync;
    if (lastSync != null && DateTime.now().difference(lastSync) < const Duration(hours: 12)) return;
    final token = await _push?.token();
    if (token != null) await _register(token);
  }

  Future<void> _onLogout() async {
    final token = _registered;
    _registered = null;
    if (token == null) return;
    try {
      await _tokens?.unregister(token);
      await _push?.deleteToken();
    } catch (_) {}
  }

  void _showInApp(PushMessage message) {
    ref.invalidate(notificationsProvider);
    ref.invalidate(unreadNotificationsProvider);
    final text = [
      message.title,
      message.body,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
    if (text.isEmpty) return;
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(text),
        action: pushTarget(message) == null
            ? null
            : SnackBarAction(label: 'Apri', onPressed: () => _open(message)),
      ),
    );
  }

  void _open(PushMessage message) {
    if (ref.read(authControllerProvider).value == null) {
      // Prima va fatto l'accesso: apriamo la schermata subito dopo.
      _pending = message;
      return;
    }
    unawaited(_markAndNavigate(message));
  }

  Future<void> _markAndNavigate(PushMessage message) async {
    final notificationId = message.data['notification_id'];
    if (notificationId != null) {
      try {
        await ref.read(notificationsRepositoryProvider).markRead(notificationId);
        ref.invalidate(notificationsProvider);
        ref.invalidate(unreadNotificationsProvider);
      } catch (_) {}
    }
    _navigate(message);
  }

  void _navigate(PushMessage message) {
    final target = pushTarget(message);
    if (target == null) return;
    final router = ref.read(routerProvider);
    if (target.pathParameters.isEmpty) {
      router.goNamed(target.name);
    } else {
      router.pushNamed(target.name, pathParameters: target.pathParameters);
    }
  }
}

/// Schermata da aprire per una notifica.
class PushTarget {
  const PushTarget(this.name, [this.pathParameters = const {}]);

  final String name;
  final Map<String, String> pathParameters;
}

/// Contratto dei dati della notifica (`type` e `id`), descritto in
/// `docs/API_BACKEND.md`. `null` se non c'è nulla da aprire.
PushTarget? pushTarget(PushMessage message) {
  final id = message.data['entity_id'] ?? message.data['id'];
  final destination = message.data['destination'];
  if (destination != null) return notificationTarget(destination, id);
  return switch (message.data['type']) {
    'match' when id != null => PushTarget(AppRoutes.matchDetail, {'id': id}),
    'subscription' when id != null => PushTarget(AppRoutes.subscriptionDetail, {
      'id': id,
    }),
    'booking' => const PushTarget(AppRoutes.home),
    'matches' => const PushTarget(AppRoutes.matches),
    _ => const PushTarget(AppRoutes.notifications),
  };
}

PushTarget? notificationTarget(String? destination, String? entityId) => switch (destination) {
  'partite' when entityId != null => PushTarget(AppRoutes.matchDetail, {'id': entityId}),
  'partite' => const PushTarget(AppRoutes.matches),
  'prenotazioni' => const PushTarget(AppRoutes.book),
  'abbonamenti' when entityId != null => PushTarget(AppRoutes.subscriptionDetail, {'id': entityId}),
  'abbonamenti' => const PushTarget(AppRoutes.profile),
  'eventi' || 'tornei' || 'news' => const PushTarget(AppRoutes.home),
  null => const PushTarget(AppRoutes.notifications),
  _ => const PushTarget(AppRoutes.notifications),
};
