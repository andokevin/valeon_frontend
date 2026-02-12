import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static const Color primaryBlue = Color(0xFF4A6FFF);
  static const Color darkPurple = Color(0xFF1A1B3D);
  static const Color mediumPurple = Color(0xFF4A3B8F);
  static const Color lightPurple = Color(0xFF6B5BB3);
  
  // Couleurs de texte
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B8D0);
  static const Color textDark = Color(0xFF1F2937);
  
  // Couleurs d'arrière-plan
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = Color(0xFFF9FAFB);
  
  // Couleurs des plateformes
  static const Color youtube = Color(0xFFFF0000);
  static const Color spotify = Color(0xFF1DB954);
  static const Color appleMusic = Color(0xFFFA2D48);
  static const Color deezer = Color(0xFFEF5466);
  static const Color facebook = Color(0xFF1877F2);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color tiktok = Color(0xFF000000);
  static const Color instagram = Color(0xFFE4405F);
  
  // Couleurs de la bottom nav
  static const Color bottomNavInactive = Color(0xFF6B7280);
  static const Color bottomNavActive = primaryBlue;
  
  // Gradients
  static const LinearGradient spaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkPurple, mediumPurple, lightPurple],
  );
}

class AppSizes {
  // Padding et margins
  static const double paddingScreen = 20.0;
  static const double paddingSection = 24.0;
  static const double paddingCard = 16.0;
  static const double gapSmall = 8.0;
  static const double gapMedium = 12.0;
  static const double gapLarge = 16.0;
  
  // Border radius
  static const double radiusCard = 16.0;
  static const double radiusButton = 24.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  
  // Tailles d'icônes
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconScanCenter = 80.0;
  
  // Hauteurs
  static const double buttonHeight = 50.0;
  static const double bottomNavHeight = 70.0;
  static const double appBarHeight = 60.0;
  
  // Largeurs
  static const double trendingCardWidth = 110.0;
  static const double trendingCardHeight = 150.0; // AUGMENTÉ de 140 à 150
  
  // Scan circle
  static const double scanCircleOuter = 220.0; // AUGMENTÉ de 200 à 220
  static const double scanCircleInner = 180.0; // AUGMENTÉ de 160 à 180
  static const double scanCircleBorder = 8.0;
}

class AppTextStyles {
  // Titres
  static const TextStyle titleLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  // Sous-titres
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  
  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  // Boutons
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  // Dark text (pour cards blanches)
  static const TextStyle titleDark = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  
  static const TextStyle subtitleDark = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Color(0xFF6B7280),
  );
}

class AppStrings {
  // Général
  static const String appName = 'Valeon';
  static const String tagline = 'Know what you see, hear, and watch';
  
  // Home
  static const String welcome = 'Bonjour';
  static const String searchPlaceholder = 'Rechercher musique, film, image...';
  static const String scanPrompt = 'Scannez une musique, un film, une image...';
  static const String trending = 'Trending';
  static const String seeAll = 'Voir tout';
  
  // Scan
  static const String scanInstructionAudio = 'Tenez votre appareil vers la musique, le film ou l\'image...';
  static const String listening = 'À l\'écoute...';
  static const String scanning = 'Identification en cours...';
  
  // Navigation
  static const String navHome = 'Accueil';
  static const String navScan = 'Scan';
  static const String navFavorites = 'Favoris';
  static const String navProfile = 'Profil';
  
  // Résultat
  static const String streaming = 'Streaming';
  static const String share = 'Partager';
  static const String save = 'Sauvegarder';
  static const String similarSongs = 'Chansons similaires';
  
  // Bibliothèque
  static const String library = 'Bibliothèque';
  static const String music = 'Musiques';
  static const String filmsVideos = 'Films/Vidéos';
  static const String photos = 'Photos';
  static const String playlists = 'Playlists';
  static const String favorites = 'Favoris';
}