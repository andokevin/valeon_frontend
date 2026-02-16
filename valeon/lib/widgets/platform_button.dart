import 'package:flutter/material.dart';
import '../config/constants.dart';

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
    final btnHeight = isTablet ? 58.0 : 44.0;
    final iconSize = isTablet ? 26.0 : 20.0;
    final arrowSize = isTablet ? 20.0 : 16.0;
    final fontSize = isTablet ? 16.0 : 14.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Container(
        height: btnHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: platformData['color'],
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(platformData['icon'], color: Colors.white, size: iconSize),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                platformData['text'],
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: arrowSize),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getPlatformData(String platform) {
    switch (platform.toLowerCase()) {
      case 'youtube':
        return {
          'color': AppColors.youtube,
          'icon': Icons.play_circle_outline,
          'text': 'Regarder sur YouTube',
        };
      case 'spotify':
        return {
          'color': AppColors.spotify,
          'icon': Icons.music_note,
          'text': 'Écouter sur Spotify',
        };
      case 'apple music':
        return {
          'color': AppColors.appleMusic,
          'icon': Icons.music_note,
          'text': 'Écouter sur Apple Music',
        };
      case 'deezer':
        return {
          'color': AppColors.deezer,
          'icon': Icons.music_note,
          'text': 'Écouter sur Deezer',
        };
      default:
        return {
          'color': AppColors.primaryBlue,
          'icon': Icons.link,
          'text': 'Ouvrir',
        };
    }
  }
}
