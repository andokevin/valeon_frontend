// lib/core/network/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../utils/secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final SecureStorage _secureStorage = SecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ===== GESTION DES ERREURS =====
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
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

  // ===== REQUÊTES =====
  Future<dynamic> get(String endpoint, {Map<String, String>? params}) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '${AppConfig.apiBaseUrl}$endpoint',
      ).replace(queryParameters: params);

      final response = await http.get(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}$endpoint'),
        headers: headers,
        body: data != null ? jsonEncode(data) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}$endpoint'),
        headers: headers,
        body: data != null ? jsonEncode(data) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${AppConfig.apiBaseUrl}$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  // ===== MULTIPART (upload fichiers) =====
  Future<dynamic> postMultipart(
    String endpoint,
    Map<String, String> fields,
    Map<String, String> files,
  ) async {
    try {
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
    } catch (e) {
      throw ApiException(message: e.toString());
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
