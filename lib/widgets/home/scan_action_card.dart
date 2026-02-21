import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ScanActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isPremiumOnly;

  const ScanActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isPremiumOnly = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(children: [
        Stack(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 26),
          ),
          if (isPremiumOnly)
            Positioned(top: -2, right: -2,
              child: Container(
                width: 18, height: 18,
                decoration: const BoxDecoration(
                  color: AppTheme.premium, shape: BoxShape.circle),
                child: const Icon(Icons.star_rounded, size: 12, color: Colors.black),
              )),
        ]),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: AppTheme.onBackground)),
      ]),
    ),
  );
}
