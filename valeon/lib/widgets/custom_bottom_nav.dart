import 'package:flutter/material.dart';
import '../config/constants.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navHeight = ResponsiveHelper.bottomNavHeight(context);

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
            context: context,
            index: 0,
            icon: Icons.home,
            label: 'Accueil',
          ),
          _buildNavItem(
            context: context,
            index: 1,
            icon: Icons.search,
            label: 'Scan',
            isCenter: true,
          ),
          _buildNavItem(
            context: context,
            index: 2,
            icon: Icons.favorite_border,
            label: 'Favoris',
          ),
          _buildNavItem(
            context: context,
            index: 3,
            icon: Icons.person_outline,
            label: 'Profil',
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    bool isCenter = false,
  }) {
    final isSelected = currentIndex == index;
    final centerButtonSize = ResponsiveHelper.bottomNavCenterButtonSize(context);
    final iconSize = ResponsiveHelper.bottomNavIconSize(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    
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
                    size: isTablet ? 36.0 : 30.0,
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
                        fontSize: isTablet ? 14.0 : 12.0,
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