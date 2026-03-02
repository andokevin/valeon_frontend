// lib/widgets/common/theme_switch.dart (NOUVEAU)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/app_theme.dart';

class ThemeSwitch extends StatelessWidget {
  final bool showLabel;
  final double size;

  const ThemeSwitch({
    super.key,
    this.showLabel = false,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTap: () => themeProvider.toggleTheme(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? AppColors.darkSurface
                  : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: themeProvider.isDarkMode
                      ? Colors.white
                      : AppColors.primaryBlue,
                  size: size,
                ),
                if (showLabel) ...[
                  const SizedBox(width: 4),
                  Text(
                    themeProvider.isDarkMode ? 'Mode sombre' : 'Mode clair',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : AppColors.primaryBlue,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
