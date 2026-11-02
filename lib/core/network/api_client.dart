// lib/core/network/api_client.dart (CORRIGÉ - avec params)
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/app_config.dart';
import '../../utils/secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio dio;
  // Dio sans intercepteur pour le refresh : un 401 sur le refresh ne doit pas
  // redéclencher un refresh (sinon la requête reste bloquée indéfiniment).
  late Dio _refreshDio;
  final SecureStorage _secureStorage = SecureStorage();
  bool _initialized = false;
  // Refresh en cours, partagé par toutes les requêtes qui reçoivent un 401
  Future<bool>? _refreshFuture;

  static const String _retriedKey = 'auth_retried';

  BaseOptions get _baseOptions => BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: AppConfig.apiTimeout),
        receiveTimeout: const Duration(seconds: AppConfig.apiTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
      );

  // Appelé par chaque service : seul le premier appel crée les clients
  void init() {
    if (_initialized) return;
    _initialized = true;

    dio = Dio(_baseOptions);
    _refreshDio = Dio(_baseOptions);

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
    final options = err.requestOptions;
    final isAuthCall = options.path.startsWith('/auth/login') ||
        options.path.startsWith('/auth/refresh-token');

    if (err.response?.statusCode != 401 ||
        isAuthCall ||
        options.extra[_retriedKey] == true) {
      return handler.next(err);
    }

    final refreshed = await (_refreshFuture ??=
        _refreshToken().whenComplete(() => _refreshFuture = null));
    if (!refreshed) {
      return handler.next(err);
    }

    try {
      final token = await _secureStorage.getToken();
      options.headers['Authorization'] = 'Bearer $token';
      options.extra[_retriedKey] = true;
      final response = await dio.fetch(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _refreshDio.post(
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
      // Refresh expiré ou révoqué : la session n'est plus valide
      await _secureStorage.deleteToken();
      return false;
    }
  }

  // ===== MODIFICATION: Utilisation de 'params' au lieu de 'queryParameters' =====
  Future<Response> get(String path, {Map<String, dynamic>? params}) {
    return dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? params}) {
    return dio.post(path, data: data, queryParameters: params);
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? params}) {
    return dio.put(path, data: data, queryParameters: params);
  }

  Future<Response> delete(String path, {Map<String, dynamic>? params}) {
    return dio.delete(path, queryParameters: params);
  }

  Future<Response> uploadFile(String path, FormData data, {Map<String, dynamic>? params}) {
    return dio.post(path, data: data, queryParameters: params);
  }
}
