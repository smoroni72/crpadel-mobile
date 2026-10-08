import 'dart:convert';
import 'dart:typed_data';

import 'package:crpadel_mobile/core/network/api_client.dart';
import 'package:crpadel_mobile/core/network/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _Handler = (int, Object?) Function(RequestOptions options);

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);
  final _Handler handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final (status, body) = handler(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late InMemoryTokenStorage storage;

  ApiClient buildClient(_FakeAdapter adapter) {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))
      ..httpClientAdapter = adapter;
    return ApiClient(dio, storage, clubSlug: 'crpadel');
  }

  setUp(() => storage = InMemoryTokenStorage());

  test('invia circolo e Bearer; il circolo si può cambiare', () async {
    final adapter = _FakeAdapter((_) => (200, {'data': []}));
    final api = buildClient(adapter);
    await api.setAccessToken('token-1');

    await api.get('/courts');
    api.clubSlug = 'altro-circolo';
    await api.get('/courts');

    expect(adapter.requests[0].headers['X-Club-Slug'], 'crpadel');
    expect(adapter.requests[0].headers['Authorization'], 'Bearer token-1');
    expect(adapter.requests[1].headers['X-Club-Slug'], 'altro-circolo');
  });

  test('put, patch e delete usano il metodo giusto', () async {
    final adapter = _FakeAdapter((_) => (200, {'data': null}));
    final api = buildClient(adapter);

    await api.put('/x');
    await api.patch('/bookings/1', data: {'status': 'cancelled'});
    await api.delete('/x');

    expect(adapter.requests.map((r) => r.method), ['PUT', 'PATCH', 'DELETE']);
    expect(adapter.requests[1].data, {'status': 'cancelled'});
  });

  test('su 401 rinnova il token e ripete la richiesta', () async {
    final adapter = _FakeAdapter((options) {
      if (options.path == '/auth/refresh') {
        return (200, {'access_token': 'nuovo'});
      }
      final auth = options.headers['Authorization'];
      return auth == 'Bearer nuovo' ? (200, {'data': 'ok'}) : (401, {});
    });
    final api = buildClient(adapter);
    await api.setAccessToken('scaduto');

    final response = await api.get('/bookings');

    expect(response.data, {'data': 'ok'});
    expect(storage.token, 'nuovo');
    expect(adapter.requests.map((r) => r.path), [
      '/bookings',
      '/auth/refresh',
      '/bookings',
    ]);
  });

  test(
    'se il refresh fallisce cancella il token e segnala la scadenza',
    () async {
      final adapter = _FakeAdapter(
        (options) => (401, {'error': 'Sessione non valida'}),
      );
      final api = buildClient(adapter);
      await api.setAccessToken('scaduto');
      var expired = 0;
      api.sessionExpired.listen((_) => expired++);

      await expectLater(
        api.get('/bookings'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(storage.token, isNull);
      expect(expired, 1);
    },
  );

  test('un 401 sulle rotte di accesso non tenta il refresh', () async {
    final adapter = _FakeAdapter(
      (_) => (401, {'error': 'Credenziali non valide'}),
    );
    final api = buildClient(adapter);

    await expectLater(
      api.post('/auth/login'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          'Credenziali non valide',
        ),
      ),
    );
    expect(adapter.requests, hasLength(1));
  });
}
