// lib/widgets/home/scan_action_card.dart
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class ScanActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isPremiumOnly;  // ← Ce flag existe déjà
  final bool isPremium;      // ← Et celui-ci aussi

  const ScanActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isPremiumOnly = false,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return GestureDetector(
      onTap: onTap,  // ← Le onTap est passé depuis home_screen.dart
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isTablet ? 32 : 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 15 : 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            // L'étoile Premium reste un indicateur visuel, pas un bloqueur
            if (isPremiumOnly && !isPremium)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.premium,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.black,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}