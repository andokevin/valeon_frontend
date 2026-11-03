// lib/screens/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'main_navigation.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        // Écran de démarrage uniquement pendant la vérification de session au lancement.
        // Pendant une connexion, on garde l'écran de login affiché (bouton en chargement,
        // message d'erreur) au lieu de le détruire.
        if (!auth.initialized) return const SplashScreen();
        if (auth.status == AuthStatus.authenticated) return const MainNavigation();
        return const LoginScreen();
      },
    );
  }
}
