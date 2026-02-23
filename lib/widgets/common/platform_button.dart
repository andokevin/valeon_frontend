// lib/widgets/common/platform_button.dart
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class PlatformButton extends StatelessWidget {
  final String platform;
  final VoidCallback onTap;

  const PlatformButton({
    super.key,
    required this.platform,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final platformData = _getPlatformData(platform);
    final isTablet = ResponsiveHelper.isTablet(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: isTablet ? 58 : 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: platformData['color'],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              platformData['icon'],
              color: Colors.white,
              size: isTablet ? 24 : 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                platformData['text'],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: isTablet ? 18 : 14,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getPlatformData(String platform) {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return {
          'color': Colors.red,
          'icon': Icons.play_circle_filled,
          'text': 'Regarder sur YouTube',
        };
      case 'spotify':
        return {
          'color': const Color(0xFF1DB954),
          'icon': Icons.music_note,
          'text': 'Écouter sur Spotify',
        };
      case 'apple music':
        return {
          'color': const Color(0xFFFA2D48),
          'icon': Icons.music_note,
          'text': 'Écouter sur Apple Music',
        };
      case 'deezer':
        return {
          'color': const Color(0xFFEF5466),
          'icon': Icons.music_note,
          'text': 'Écouter sur Deezer',
        };
      case 'netflix':
        return {
          'color': Colors.red,
          'icon': Icons.live_tv,
          'text': 'Regarder sur Netflix',
        };
      case 'disney+':
        return {
          'color': const Color(0xFF113CCF),
          'icon': Icons.live_tv,
          'text': 'Regarder sur Disney+',
        };
      case 'prime video':
        return {
          'color': const Color(0xFF00A8E1),
          'icon': Icons.live_tv,
          'text': 'Regarder sur Prime Video',
        };
      default:
        return {
          'color': AppColors.primaryBlue,
          'icon': Icons.link,
          'text': 'Ouvrir le lien',
        };
    }
  }
}
