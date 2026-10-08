import 'dart:convert';
import 'dart:typed_data';

import 'package:crpadel_mobile/core/network/api_client.dart';
import 'package:crpadel_mobile/core/network/token_storage.dart';
import 'package:dio/dio.dart';

typedef FakeHandler = (int, Object?) Function(RequestOptions options);

/// Adapter Dio che risponde con [handler] e registra le richieste.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);
  final FakeHandler handler;
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

/// `ApiClient` collegato a un [FakeAdapter].
ApiClient fakeApiClient(FakeAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))
    ..httpClientAdapter = adapter;
  return ApiClient(dio, InMemoryTokenStorage(), clubSlug: 'crpadel');
}
