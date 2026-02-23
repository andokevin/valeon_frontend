// lib/widgets/layout/offline_banner.dart
import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  final VoidCallback? onRetry;
  final bool showRetry;

  const OfflineBanner({super.key, this.onRetry, this.showRetry = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Colors.orange,
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 18),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Mode hors ligne',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          if (onRetry != null && showRetry)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Réessayer'),
            ),
        ],
      ),
    );
  }
}
