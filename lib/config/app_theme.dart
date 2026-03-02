// lib/config/app_theme.dart (MODIFIÉ - ajout dark theme)
import 'package:flutter/material.dart';

class AppColors {
  // Couleurs existantes
  static const Color primaryBlue = Color(0xFF4A6FFF);
  static const Color darkPurple = Color(0xFF1A1B3D);
  static const Color mediumPurple = Color(0xFF4A3B8F);
  static const Color lightPurple = Color(0xFF6B5BB3);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B8D0);
  static const Color textDark = Color(0xFF1F2937);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = Color(0xFFF9FAFB);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color youtube = Color(0xFFFF0000);
  static const Color spotify = Color(0xFF1DB954);
  static const Color appleMusic = Color(0xFFFA2D48);
  static const Color deezer = Color(0xFFEF5466);
  static const Color facebook = Color(0xFF1877F2);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color instagram = Color(0xFFE4405F);
  static const Color bottomNavInactive = Color(0xFF6B7280);
  static const Color bottomNavActive = primaryBlue;
  static const Color premium = Color(0xFFFFD700);
  static const Color error = Color(0xFFCF6679);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceVariant = Color(0xFF16213E);
  static const Color onBackground = Colors.white;
  static const Color onSurface = Color(0xFFCCCCDD);

  // NOUVELLES COULEURS POUR DARK MODE
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkDivider = Color(0xFF3D3D3D);

  static const LinearGradient spaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkPurple, mediumPurple, lightPurple],
  );
}

class AppSizes {
  static const double paddingScreen = 20.0;
  static const double paddingSection = 24.0;
  static const double paddingCard = 16.0;
  static const double gapSmall = 8.0;
  static const double gapMedium = 12.0;
  static const double gapLarge = 16.0;
  static const double radiusCard = 16.0;
  static const double radiusButton = 24.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconScanCenter = 80.0;
  static const double buttonHeight = 50.0;
  static const double bottomNavHeight = 70.0;
  static const double appBarHeight = 60.0;
  static const double trendingCardWidth = 110.0;
  static const double trendingCardHeight = 150.0;
  static const double scanCircleOuter = 220.0;
  static const double scanCircleInner = 180.0;
  static const double scanCircleBorder = 8.0;
}

class AppTextStyles {
  static const TextStyle titleLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle titleSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}

class AppTheme {
  // Light Theme (existant)
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusButton),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.bottomNavActive,
        unselectedItemColor: AppColors.bottomNavInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // Dark Theme (NOUVEAU)
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
      ),
      cardColor: AppColors.darkCard,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusButton),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        hintStyle: const TextStyle(color: AppColors.darkTextSecondary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerColor: AppColors.darkDivider,
      dialogTheme: DialogThemeData(backgroundColor: AppColors.darkSurface),
    );
  }
}

class ResponsiveHelper {
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  static double maxContentWidth(BuildContext context) {
    return isTablet(context) ? 700.0 : double.infinity;
  }

  static double paddingScreen(BuildContext context) {
    return isTablet(context) ? 40.0 : AppSizes.paddingScreen;
  }

  static double bottomNavHeight(BuildContext context) {
    return isTablet(context) ? 84.0 : AppSizes.bottomNavHeight;
  }

  static double bottomNavIconSize(BuildContext context) {
    return isTablet(context) ? 32.0 : 26.0;
  }

  static double bottomNavCenterButtonSize(BuildContext context) {
    return isTablet(context) ? 80.0 : 64.0;
  }

  static double trendingCardWidth(BuildContext context) {
    return isTablet(context) ? 160.0 : AppSizes.trendingCardWidth;
  }

  static double resultCoverHeight(BuildContext context) {
    return isTablet(context) ? 340.0 : 250.0;
  }
}
