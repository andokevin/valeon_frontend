import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.graphic_eq_rounded, size: 56, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text('VALEON',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700,
                color: AppTheme.onBackground, letterSpacing: 4)),
            const SizedBox(height: 8),
            const Text('Know what you see, hear, and watch',
              style: TextStyle(fontSize: 13, color: AppTheme.onSurface)),
            const SizedBox(height: 48),
            const SizedBox(width: 32, height: 32,
              child: CircularProgressIndicator(
                color: AppTheme.primary, strokeWidth: 2)),
          ],
        ),
      ),
    );
  }
}
