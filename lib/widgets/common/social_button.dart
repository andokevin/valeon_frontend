// lib/widgets/common/social_button.dart
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class SocialButton extends StatelessWidget {
  final String platform;
  final VoidCallback onTap;
  final double size;

  const SocialButton({
    super.key,
    required this.platform,
    required this.onTap,
    this.size = 52,
  });

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
          color: platformData['iconColor'],
          size: size * 0.5,
        ),
      ),
    );
  }

  Map<String, dynamic> _getPlatformData(String platform) {
    switch (platform.toLowerCase()) {
      case 'google':
        return {
          'color': Colors.white,
          'icon': Icons.g_mobiledata,
          'iconColor': Colors.red,
        };
      case 'facebook':
        return {
          'color': const Color(0xFF1877F2),
          'icon': Icons.facebook,
          'iconColor': Colors.white,
        };
      case 'twitter':
        return {
          'color': const Color(0xFF1DA1F2),
          'icon': Icons.alternate_email,
          'iconColor': Colors.white,
        };
      case 'instagram':
        return {
          'color': const Color(0xFFE4405F),
          'icon': Icons.photo_camera,
          'iconColor': Colors.white,
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
