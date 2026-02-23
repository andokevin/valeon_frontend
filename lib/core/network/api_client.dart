// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/app_config.dart';
import '../../utils/secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio dio;
  final SecureStorage _secureStorage = SecureStorage();
  bool _isRefreshing = false;
  final List<Map<String, dynamic>> _pendingRequests = [];

  void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: AppConfig.apiTimeout),
        receiveTimeout: const Duration(seconds: AppConfig.apiTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
      ),
    );

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));
  }

  Future<void> _onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final options = err.requestOptions;

      if (!_isRefreshing) {
        _isRefreshing = true;
        try {
          final success = await _refreshToken();
          if (success) {
            _isRefreshing = false;
            _retryPendingRequests();

            // Retry la requête originale
            final token = await _secureStorage.getToken();
            options.headers['Authorization'] = 'Bearer $token';
            final response = await dio.fetch(options);
            return handler.resolve(response);
          }
        } catch (e) {
          _isRefreshing = false;
          _pendingRequests.clear();
        }
      } else {
        // Attendre et réessayer
        _pendingRequests.add({'options': options, 'handler': handler});
        return;
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await dio.post(
        '/auth/refresh-token',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _secureStorage.saveToken(data['access_token']);
        if (data['refresh_token'] != null) {
          await _secureStorage.saveRefreshToken(data['refresh_token']);
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Erreur refresh token: $e');
      return false;
    }
  }

  void _retryPendingRequests() {
    for (var req in _pendingRequests) {
      final options = req['options'] as RequestOptions;
      final handler = req['handler'] as ErrorInterceptorHandler;
      dio.fetch(options).then(
            (response) => handler.resolve(response),
            onError: (error) => handler.next(error as DioException),
          );
    }
    _pendingRequests.clear();
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) {
    return dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path, {dynamic data}) {
    return dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return dio.put(path, data: data);
  }

  Future<Response> delete(String path) {
    return dio.delete(path);
  }

  Future<Response> uploadFile(String path, FormData data) {
    return dio.post(path, data: data);
  }
}
