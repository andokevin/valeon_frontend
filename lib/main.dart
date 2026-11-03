// lib/main.dart (MODIFIÉ)
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/scan_provider.dart';
import 'providers/connectivity_provider.dart';
import 'providers/recommendation_provider.dart';
import 'providers/library_provider.dart';
import 'providers/theme_provider.dart'; // ← NOUVEAU
import 'screens/auth_wrapper.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile/premium_screen.dart';
import 'screens/scan/scan_audio_screen.dart';
import 'screens/scan/scan_result_screen.dart';
import 'screens/library/history_screen.dart';
import 'screens/library/favorites_screen.dart';
import 'screens/library/playlists_screen.dart';
import 'screens/library/playlist_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Version navigateur (tests dans Chrome) : pas de configuration Firebase Web,
    // donc pas de connexion Google/Facebook ; e-mail + mot de passe fonctionnent.
    debugPrint('ℹ️ Web : Firebase non initialisé (connexion Google/Facebook indisponible)');
  } else {
    await Firebase.initializeApp();
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const ValeonApp());
  });
}

class ValeonApp extends StatelessWidget {
  const ValeonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ScanProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // ← NOUVEAU
      ],
      child: Consumer2<ConnectivityProvider, ThemeProvider>(
        builder: (context, connectivity, theme, child) {
          return MaterialApp(
            title: 'Valeon',
            debugShowCheckedModeBanner: false,
            theme: theme.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
            initialRoute: '/',
            onGenerateRoute: (settings) {
              // Gestion des routes avec paramètres
              if (settings.name == '/scan/result') {
                final args = settings.arguments as Map<String, dynamic>?;
                return MaterialPageRoute(
                  builder: (context) => ScanResultScreen(
                    scanId: args?['scanId'],
                    scanResult: args?['scanResult'],
                    initialData: args?['initialData'],
                  ),
                );
              }
              if (settings.name == '/playlist/detail') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => PlaylistDetailScreen(
                    playlistId: args['playlistId'],
                    playlistName: args['playlistName'],
                  ),
                );
              }
              return null; // Laisser les routes standards gérer
            },
            routes: {
              '/': (context) => const AuthWrapper(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/premium': (context) => const PremiumScreen(),
              '/scan/audio': (context) => const ScanAudioScreen(),
              '/history': (context) => const HistoryScreen(),
              '/favorites': (context) => const FavoritesScreen(),
              '/playlists': (context) => const PlaylistsScreen(),
            },
          );
        },
      ),
    );
  }
}