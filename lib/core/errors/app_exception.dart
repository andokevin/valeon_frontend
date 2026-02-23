// lib/core/errors/app_exception.dart
import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const AppException(this.message, {this.statusCode, this.code});

  factory AppException.fromDio(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response!.data;
        final msg = data is Map
            ? (data['detail'] ?? data['message'] ?? 'Erreur serveur')
            : 'Erreur serveur';
        return AppException(msg.toString(),
            statusCode: error.response!.statusCode);
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return const AppException(
            'Connexion impossible. Vérifiez votre réseau.',
            code: 'timeout');
      }
      if (error.type == DioExceptionType.connectionError) {
        return const AppException('Pas de connexion internet',
            code: 'no_internet');
      }
    }
    return AppException(error.toString());
  }

  @override
  String toString() => message;
}
