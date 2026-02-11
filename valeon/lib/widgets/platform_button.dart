import 'package:flutter/material.dart';
import '../config/constants.dart';

class PlatformButton extends StatelessWidget {
  final String platform;
  final VoidCallback onTap;
  
  const PlatformButton({
    Key? key,
    required this.platform,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformData = _getPlatformData(platform);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: platformData['color'],
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(
              platformData['icon'],
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                platformData['text'],
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
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