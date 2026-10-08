import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../config/app_environment.dart';
import 'token_storage.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => message;
}

class ApiClient {
  /// Prepara il client su un [Dio] già configurato (base URL, cookie).
  /// In produzione si usa [create]; nei test si passa un adapter finto.
  @visibleForTesting
  ApiClient(this._dio, this._storage, {required this.clubSlug}) {
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );
  }

  final Dio _dio;
  final TokenStorage _storage;
  final _sessionExpired = StreamController<void>.broadcast();

  /// Circolo inviato in `X-Club-Slug` da ogni richiesta.
  String clubSlug;
  String? _accessToken;
  Future<void>? _refreshing;

  static Future<ApiClient> create({required String clubSlug}) async {
    final directory = await getApplicationSupportDirectory();
    final cookieJar = PersistCookieJar(
      storage: FileStorage('${directory.path}/cookies'),
    );
    final dio = Dio(
      BaseOptions(
        baseUrl: AppEnvironment.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    dio.interceptors.add(CookieManager(cookieJar));
    final client = ApiClient(dio, SecureTokenStorage(), clubSlug: clubSlug);
    await client.loadStoredToken();
    return client;
  }

  /// Emette un evento quando il refresh fallisce durante una richiesta:
  /// il token è già stato cancellato e l'utente va riportato al login.
  Stream<void> get sessionExpired => _sessionExpired.stream;

  Future<void> loadStoredToken() async {
    _accessToken = await _storage.read();
  }

  Future<Response<dynamic>> get(String path, {Map<String, dynamic>? query}) =>
      _guard(() => _dio.get(path, queryParameters: query));

  Future<Response<dynamic>> post(String path, {Object? data}) =>
      _guard(() => _dio.post(path, data: data));

  Future<Response<dynamic>> put(String path, {Object? data}) =>
      _guard(() => _dio.put(path, data: data));

  Future<Response<dynamic>> patch(String path, {Object? data}) =>
      _guard(() => _dio.patch(path, data: data));

  Future<Response<dynamic>> delete(String path, {Object? data}) =>
      _guard(() => _dio.delete(path, data: data));

  Future<void> setAccessToken(String? token) async {
    _accessToken = token;
    if (token == null) {
      await _storage.delete();
    } else {
      await _storage.write(token);
    }
  }

  Future<void> refresh() async {
    if (_refreshing != null) return _refreshing;
    _refreshing = () async {
      final response = await _dio.post('/auth/refresh');
      final data = response.data as Map<String, dynamic>;
      await setAccessToken(data['access_token'] as String);
    }();
    try {
      await _refreshing;
    } finally {
      _refreshing = null;
    }
  }

  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Club-Slug'] = clubSlug;
    final token = _accessToken;
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final request = error.requestOptions;
    final canRetry =
        error.response?.statusCode == 401 &&
        request.extra['retried'] != true &&
        !request.path.startsWith('/auth/');
    if (!canRetry) return handler.next(error);
    try {
      await refresh();
    } catch (_) {
      await setAccessToken(null);
      _sessionExpired.add(null);
      return handler.next(error);
    }
    try {
      request.extra['retried'] = true;
      request.headers['Authorization'] = 'Bearer $_accessToken';
      handler.resolve(await _dio.fetch(request));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<Response<dynamic>> _guard(
    Future<Response<dynamic>> Function() action,
  ) async {
    try {
      return await action();
    } on DioException catch (error) {
      final data = error.response?.data;
      final body = data is Map<String, dynamic>
          ? data
          : const <String, dynamic>{};
      throw ApiException(
        (body['error'] ??
                body['message'] ??
                'Impossibile completare la richiesta')
            .toString(),
        statusCode: error.response?.statusCode,
        code: body['code']?.toString(),
      );
    }
  }
}
