// lib/widgets/offline_banner.dart
import 'package:flutter/material.dart';
import '../config/constants.dart';

class OfflineBanner extends StatelessWidget {
  final VoidCallback? onRetry;
  final bool showRetry;

  const OfflineBanner({super.key, this.onRetry, this.showRetry = true});

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.orange,
      child: Row(
        children: [
          // Icône
          Icon(Icons.wifi_off, color: Colors.white, size: isTablet ? 24 : 20),

          const SizedBox(width: 12),

          // Message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mode hors ligne',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Données locales uniquement',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),

          // Bouton Réessayer (optionnel)
          if (onRetry != null && showRetry) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 10 : 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Réessayer',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 15 : 13,
                ),
              ),
            ),
          ],

          // Bouton Fermer (optionnel)
          if (onRetry == null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                // Cacher la bannière
                // À implémenter avec un ValueNotifier ou un Provider
              },
              icon: Icon(
                Icons.close,
                color: Colors.white,
                size: isTablet ? 24 : 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}

class OfflineBannerWrapper extends StatefulWidget {
  final Widget child;
  final bool initiallyVisible;

  const OfflineBannerWrapper({
    super.key,
    required this.child,
    this.initiallyVisible = true,
  });

  @override
  State<OfflineBannerWrapper> createState() => _OfflineBannerWrapperState();
}

class _OfflineBannerWrapperState extends State<OfflineBannerWrapper> {
  bool _isVisible = true;

  void _hideBanner() {
    setState(() {
      _isVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isVisible) ...[
          OfflineBanner(
            onRetry: () {
              // Action de réessai
              _hideBanner();
            },
          ),
        ],
        Expanded(child: widget.child),
      ],
    );
  }
}

// Provider pour gérer l'état de la bannière
class OfflineBannerProvider extends ChangeNotifier {
  bool _isVisible = true;
  String? _customMessage;

  bool get isVisible => _isVisible;
  String? get customMessage => _customMessage;

  void show({String? message}) {
    _isVisible = true;
    _customMessage = message;
    notifyListeners();
  }

  void hide() {
    _isVisible = false;
    notifyListeners();
  }

  void setMessage(String message) {
    _customMessage = message;
    notifyListeners();
  }

  void reset() {
    _isVisible = true;
    _customMessage = null;
    notifyListeners();
  }
}
