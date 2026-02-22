// lib/core/network/api_client.dart (MODIFIÉ)
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../utils/secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final SecureStorage _secureStorage = SecureStorage();
  bool _isRefreshing = false;
  final List<Map<String, dynamic>> _pendingRequests = [];

  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ===== GESTION DES ERREURS AVEC REFRESH TOKEN =====
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw TokenExpiredException();
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response),
      );
    }
  }

  String _parseErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return data['detail'] ?? data['message'] ?? 'Erreur inconnue';
    } catch (e) {
      return 'Erreur ${response.statusCode}';
    }
  }

  // ===== REQUÊTES AVEC REFRESH TOKEN =====
  Future<dynamic> get(String endpoint, {Map<String, String>? params}) async {
    return _requestWithRefresh(() async {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '${AppConfig.apiBaseUrl}$endpoint',
      ).replace(queryParameters: params);

      final response = await http.get(uri, headers: headers);
      return _handleResponse(response);
    });
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? data}) async {
    return _requestWithRefresh(() async {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}$endpoint'),
        headers: headers,
        body: data != null ? jsonEncode(data) : null,
      );
      return _handleResponse(response);
    });
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? data}) async {
    return _requestWithRefresh(() async {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}$endpoint'),
        headers: headers,
        body: data != null ? jsonEncode(data) : null,
      );
      return _handleResponse(response);
    });
  }

  Future<dynamic> delete(String endpoint) async {
    return _requestWithRefresh(() async {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${AppConfig.apiBaseUrl}$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    });
  }

  // ===== MULTIPART (upload fichiers) =====
  Future<dynamic> postMultipart(
    String endpoint,
    Map<String, String> fields,
    Map<String, String> files,
  ) async {
    return _requestWithRefresh(() async {
      final headers = await _getHeaders();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.apiBaseUrl}$endpoint'),
      );

      request.headers.addAll(headers);
      request.fields.addAll(fields);

      for (var entry in files.entries) {
        request.files.add(
          await http.MultipartFile.fromPath(entry.key, entry.value),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    });
  }

  // ===== MÉCANISME DE REFRESH TOKEN =====
  Future<dynamic> _requestWithRefresh(Function request) async {
    try {
      return await request();
    } on TokenExpiredException catch (_) {
      if (_isRefreshing) {
        // Attendre que le refresh soit terminé
        await Future.delayed(const Duration(milliseconds: 500));
        return _requestWithRefresh(request);
      }

      _isRefreshing = true;
      try {
        final success = await _refreshToken();
        if (success) {
          _isRefreshing = false;
          return await request();
        } else {
          _isRefreshing = false;
          // Rediriger vers login
          throw ApiException(
              message: 'Session expirée, veuillez vous reconnecter');
        }
      } catch (e) {
        _isRefreshing = false;
        rethrow;
      }
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _secureStorage.saveToken(data['access_token']);
        if (data['refresh_token'] != null) {
          await _secureStorage.saveRefreshToken(data['refresh_token']);
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Erreur refresh token: $e');
      return false;
    }
  }
}

class ApiException implements Exception {
  final int? statusCode;
  final String message;

  ApiException({this.statusCode, this.message = 'Erreur réseau'});

  @override
  String toString() => message;
}

class TokenExpiredException implements Exception {}
