// lib/screens/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/sync_provider.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'main_navigation.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, SyncProvider>(
      builder: (context, auth, sync, child) {
        // État de chargement
        if (auth.isLoading) {
          return const SplashScreen(minimal: true);
        }

        // Utilisateur authentifié
        if (auth.isAuthenticated) {
          // Synchronisation en arrière-plan
          if (!sync.isSyncing && auth.user != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              sync.syncAll(user: auth.user);
            });
          }

          return const MainNavigation();
        }

        // Non authentifié
        return const LoginScreen();
      },
    );
  }
}
