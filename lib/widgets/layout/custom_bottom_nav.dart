// lib/widgets/layout/custom_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../../config/app_theme.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final navHeight = ResponsiveHelper.bottomNavHeight(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      height: navHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.home,
            label: 'Accueil',
            isTablet: isTablet,
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.qr_code_scanner,
            label: 'Scan',
            isCenter: true,
            isTablet: isTablet,
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.library_music,
            label: 'Bibliothèque',
            isTablet: isTablet,
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.person,
            label: 'Profil',
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    bool isCenter = false,
    required bool isTablet,
  }) {
    final isSelected = currentIndex == index;
    final centerButtonSize =
        ResponsiveHelper.bottomNavCenterButtonSize(context as BuildContext);
    final iconSize =
        ResponsiveHelper.bottomNavIconSize(context as BuildContext);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isCenter)
                Container(
                  width: centerButtonSize,
                  height: centerButtonSize,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: isTablet ? 32 : 28,
                  ),
                )
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: isSelected
                          ? AppColors.bottomNavActive
                          : AppColors.bottomNavInactive,
                      size: iconSize,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 11,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? AppColors.bottomNavActive
                            : AppColors.bottomNavInactive,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
