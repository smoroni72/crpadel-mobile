import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifica ricevuta. [data] è il contenuto per l'app (vedi
/// `docs/API_BACKEND.md`, "Notifiche push").
class PushMessage {
  const PushMessage({this.title, this.body, this.data = const {}});

  final String? title;
  final String? body;
  final Map<String, String> data;
}

enum PushPermission { granted, denied, notDetermined, unavailable }

/// Accesso a FCM. `null` quando Firebase non è configurato (es. manca
/// `google-services.json`): l'app funziona senza notifiche.
final pushMessagingProvider = Provider<PushMessaging?>((ref) => null);

abstract interface class PushMessaging {
  Future<PushPermission> permission();

  /// Mostra la richiesta del sistema, se non è già stata data una risposta.
  Future<PushPermission> requestPermission();

  Future<String?> token();

  Stream<String> get onTokenRefresh;

  /// Notifiche arrivate con l'app in primo piano (il sistema non le mostra).
  Stream<PushMessage> get onForeground;

  /// Notifiche toccate con l'app in background.
  Stream<PushMessage> get onOpened;

  /// Notifica che ha aperto l'app da chiusa.
  Future<PushMessage?> initialMessage();

  Future<void> deleteToken();
}

class FirebasePushMessaging implements PushMessaging {
  FirebaseMessaging get _m => FirebaseMessaging.instance;

  static PushPermission _map(AuthorizationStatus status) => switch (status) {
    AuthorizationStatus.authorized ||
    AuthorizationStatus.provisional => PushPermission.granted,
    AuthorizationStatus.denied ||
    AuthorizationStatus.deniedPermanently => PushPermission.denied,
    AuthorizationStatus.notDetermined => PushPermission.notDetermined,
  };

  static PushMessage _from(RemoteMessage m) => PushMessage(
    title: m.notification?.title,
    body: m.notification?.body,
    data: {for (final e in m.data.entries) e.key: '${e.value}'},
  );

  @override
  Future<PushPermission> permission() async =>
      _map((await _m.getNotificationSettings()).authorizationStatus);

  @override
  Future<PushPermission> requestPermission() async =>
      _map((await _m.requestPermission()).authorizationStatus);

  @override
  Future<String?> token() => _m.getToken();

  @override
  Stream<String> get onTokenRefresh => _m.onTokenRefresh;

  @override
  Stream<PushMessage> get onForeground =>
      FirebaseMessaging.onMessage.map(_from);

  @override
  Stream<PushMessage> get onOpened =>
      FirebaseMessaging.onMessageOpenedApp.map(_from);

  @override
  Future<PushMessage?> initialMessage() async {
    final m = await _m.getInitialMessage();
    return m == null ? null : _from(m);
  }

  @override
  Future<void> deleteToken() => _m.deleteToken();
}

/// Implementazione in memoria per i test.
class FakePushMessaging implements PushMessaging {
  FakePushMessaging({
    this.current = PushPermission.notDetermined,
    this.answer = PushPermission.granted,
    this.deviceToken = 'token-di-prova',
    this.launchMessage,
  });

  PushPermission current;

  /// Risposta dell'utente alla richiesta di permesso.
  PushPermission answer;
  String? deviceToken;
  PushMessage? launchMessage;
  var permissionRequests = 0;
  var deletedTokens = 0;

  final foreground = StreamController<PushMessage>.broadcast();
  final opened = StreamController<PushMessage>.broadcast();
  final refresh = StreamController<String>.broadcast();

  @override
  Future<PushPermission> permission() async => current;

  @override
  Future<PushPermission> requestPermission() async {
    permissionRequests++;
    if (current == PushPermission.notDetermined) current = answer;
    return current;
  }

  @override
  Future<String?> token() async => deviceToken;

  @override
  Stream<String> get onTokenRefresh => refresh.stream;

  @override
  Stream<PushMessage> get onForeground => foreground.stream;

  @override
  Stream<PushMessage> get onOpened => opened.stream;

  @override
  Future<PushMessage?> initialMessage() async {
    final m = launchMessage;
    launchMessage = null;
    return m;
  }

  @override
  Future<void> deleteToken() async => deletedTokens++;
}
