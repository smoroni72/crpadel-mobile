import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

import '../config/app_environment.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._(this._dio, this._storage);

  static const _accessTokenKey = 'crpadel_access_token';
  final Dio _dio;
  final FlutterSecureStorage _storage;
  String? _accessToken;
  Future<void>? _refreshing;

  static Future<ApiClient> create() async {
    const storage = FlutterSecureStorage();
    final directory = await getApplicationSupportDirectory();
    final cookieJar = PersistCookieJar(
      storage: FileStorage('${directory.path}/cookies'),
    );
    final dio = Dio(
      BaseOptions(
        baseUrl: AppEnvironment.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {'X-Club-Slug': AppEnvironment.clubSlug},
      ),
    );
    dio.interceptors.add(CookieManager(cookieJar));
    final client = ApiClient._(dio, storage);
    client._accessToken = await storage.read(key: _accessTokenKey);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = client._accessToken;
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
        onError: (error, handler) async {
          final request = error.requestOptions;
          final canRetry =
              error.response?.statusCode == 401 &&
              request.extra['retried'] != true &&
              !request.path.startsWith('/auth/');
          if (!canRetry) return handler.next(error);
          try {
            await client.refresh();
            request.extra['retried'] = true;
            request.headers['Authorization'] = 'Bearer ${client._accessToken}';
            handler.resolve(await dio.fetch(request));
          } catch (_) {
            handler.next(error);
          }
        },
      ),
    );
    return client;
  }

  Future<Response<dynamic>> get(String path, {Map<String, dynamic>? query}) =>
      _guard(() => _dio.get(path, queryParameters: query));

  Future<Response<dynamic>> post(String path, {Object? data}) =>
      _guard(() => _dio.post(path, data: data));

  Future<void> setAccessToken(String? token) async {
    _accessToken = token;
    if (token == null) {
      await _storage.delete(key: _accessTokenKey);
    } else {
      await _storage.write(key: _accessTokenKey, value: token);
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
