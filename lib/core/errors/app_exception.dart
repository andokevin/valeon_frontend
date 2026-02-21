class AppException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  const AppException(this.message, {this.statusCode, this.code});

  factory AppException.fromDio(dynamic error) {
    if (error?.response != null) {
      final data = error.response.data;
      final msg = data is Map ? (data['detail'] ?? 'Erreur serveur') : 'Erreur serveur';
      return AppException(msg.toString(), statusCode: error.response.statusCode);
    }
    if (error?.type?.toString().contains('connectTimeout') == true) {
      return const AppException('Connexion impossible. Vérifiez votre réseau.', code: 'timeout');
    }
    return AppException(error?.message ?? 'Erreur inconnue');
  }

  @override
  String toString() => message;
}
