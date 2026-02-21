import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/scan_provider.dart';

class ScanProgressWidget extends StatelessWidget {
  final ScanPhase phase;
  final String? error;
  final VoidCallback? onRetry;

  const ScanProgressWidget({super.key, required this.phase, this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (phase == ScanPhase.error) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline_rounded, size: 64, color: AppTheme.error),
        const SizedBox(height: 16),
        const Text('Scan échoué', style: TextStyle(fontSize: 18,
          fontWeight: FontWeight.w700, color: AppTheme.onBackground)),
        const SizedBox(height: 8),
        Text(error ?? 'Une erreur est survenue',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.onSurface)),
        const SizedBox(height: 24),
        if (onRetry != null)
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Réessayer'),
          ),
      ]));
    }

    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Stack(alignment: Alignment.center, children: [
        SizedBox(width: 100, height: 100,
          child: CircularProgressIndicator(
            color: AppTheme.primary, strokeWidth: 3,
            value: phase == ScanPhase.uploading ? 0.5 : null)),
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(
            phase == ScanPhase.uploading ? Icons.upload_rounded : Icons.psychology_rounded,
            color: AppTheme.primary, size: 36),
        ),
      ]),
      const SizedBox(height: 24),
      Text(
        phase == ScanPhase.uploading ? 'Envoi en cours...' : 'Analyse par l\'IA...',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
          color: AppTheme.onBackground)),
      const SizedBox(height: 8),
      const Text('Cela peut prendre quelques secondes',
        style: TextStyle(color: AppTheme.onSurface)),
    ]));
  }
}
