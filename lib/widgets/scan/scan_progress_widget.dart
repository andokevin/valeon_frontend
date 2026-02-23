// lib/widgets/scan/scan_progress_widget.dart
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../providers/scan_provider.dart';

class ScanProgressWidget extends StatelessWidget {
  final ScanPhase phase;
  final String? error;
  final VoidCallback? onRetry;

  const ScanProgressWidget({
    super.key,
    required this.phase,
    this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (phase == ScanPhase.error) {
      return _buildErrorState();
    }

    return _buildProgressState();
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Scan échoué',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error ?? 'Une erreur est survenue',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          if (onRetry != null)
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  color: AppColors.primaryBlue,
                  strokeWidth: 3,
                  value: phase == ScanPhase.uploading ? null : null,
                ),
              ),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  phase == ScanPhase.uploading
                      ? Icons.upload
                      : Icons.psychology,
                  color: AppColors.primaryBlue,
                  size: 36,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            phase == ScanPhase.uploading
                ? 'Envoi en cours...'
                : 'Analyse par l\'IA...',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cela peut prendre quelques secondes',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
