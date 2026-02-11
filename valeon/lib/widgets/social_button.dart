import 'package:flutter/material.dart';
import '../config/constants.dart';

class SocialButton extends StatelessWidget {
  final String platform;
  final VoidCallback onTap;
  final double size;
  
  const SocialButton({
    Key? key,
    required this.platform,
    required this.onTap,
    this.size = 52, // AUGMENTÉ de 50 à 52
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformData = _getPlatformData(platform);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: platformData['color'],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (platformData['color'] as Color).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          platformData['icon'],
          color: platformData['iconColor'] ?? Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
  
  Map<String, dynamic> _getPlatformData(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return {
          'color': AppColors.facebook,
          'icon': Icons.facebook,
          'iconColor': Colors.white,
        };
      case 'twitter':
        return {
          'color': AppColors.twitter,
          'icon': Icons.alternate_email, // Icône Twitter alternative
          'iconColor': Colors.white,
        };
      case 'tiktok':
        return {
          'color': AppColors.tiktok,
          'icon': Icons.music_note,
          'iconColor': Colors.white,
        };
      case 'instagram':
        return {
          'color': AppColors.instagram,
          'icon': Icons.camera_alt,
          'iconColor': Colors.white,
        };
      case 'google':
        return {
          'color': Colors.white,
          'icon': Icons.g_mobiledata,
          'iconColor': Colors.red,
        };
      case 'apple':
        return {
          'color': Colors.black,
          'icon': Icons.apple,
          'iconColor': Colors.white,
        };
      default:
        return {
          'color': AppColors.primaryBlue,
          'icon': Icons.share,
          'iconColor': Colors.white,
        };
    }
  }
}