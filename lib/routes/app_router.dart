import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/scan/scan_audio_screen.dart';
import '../screens/scan/scan_image_screen.dart';
import '../screens/scan/scan_video_screen.dart';
import '../screens/scan/scan_result_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/library/favorites_screen.dart';
import '../screens/library/history_screen.dart';
import '../screens/library/playlists_screen.dart';
import '../screens/library/playlist_detail_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/premium/premium_screen.dart';

// ─── Refresh Notifier ────────────────────────────────────────────────────────

class GoRouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final routerRefreshNotifierProvider = Provider<GoRouterRefreshNotifier>((ref) {
  final notifier = GoRouterRefreshNotifier();
  ref.onDispose(notifier.dispose);

  // Écoute TOUS les changements de statut auth et déclenche un refresh
  ref.listen<AuthStatus>(authStatusProvider, (previous, next) {
    if (previous != next) {
      notifier.refresh();
    }
  });

  return notifier;
});

// ─── Router Provider ─────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      // Lire l'état auth DIRECTEMENT depuis le container Riverpod
      final authState = ProviderScope.containerOf(context).read(authProvider);
      final isAuth = authState.status == AuthStatus.authenticated;
      final isLoading = authState.status == AuthStatus.loading ||
          authState.status == AuthStatus.initial;
      final loc = state.matchedLocation;

      debugPrint('[Router] status=${authState.status} | loc=$loc');

      if (isLoading) return loc == '/splash' ? null : '/splash';
      if (!isAuth && loc != '/login' && loc != '/register') return '/login';
      if (isAuth &&
          (loc == '/login' || loc == '/register' || loc == '/splash')) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (ctx, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: '/scan/audio',
            builder: (_, __) => const ScanAudioScreen(),
          ),
          GoRoute(
            path: '/scan/image',
            builder: (_, __) => const ScanImageScreen(),
          ),
          GoRoute(
            path: '/scan/video',
            builder: (_, __) => const ScanVideoScreen(),
          ),
          GoRoute(
            path: '/scan/result',
            builder: (_, state) => ScanResultScreen(
              scanResult: state.extra as Map<String, dynamic>?,
            ),
          ),
          GoRoute(
            path: '/library',
            builder: (_, __) => const LibraryScreen(),
          ),
          GoRoute(
            path: '/library/favorites',
            builder: (_, __) => const FavoritesScreen(),
          ),
          GoRoute(
            path: '/library/history',
            builder: (_, __) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/library/playlists',
            builder: (_, __) => const PlaylistsScreen(),
          ),
          GoRoute(
            path: '/library/playlists/:id',
            builder: (_, state) => PlaylistDetailScreen(
              playlistId: int.parse(state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/premium',
            builder: (_, __) => const PremiumScreen(),
          ),
        ],
      ),
    ],
  );
});

// ─── MainShell ───────────────────────────────────────────────────────────────

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

class _BottomNav extends ConsumerWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    int idx = 0;
    if (location.startsWith('/library')) idx = 1;
    else if (location.startsWith('/scan')) idx = 2;
    else if (location.startsWith('/profile')) idx = 3;

    return BottomNavigationBar(
      currentIndex: idx,
      onTap: (i) {
        switch (i) {
          case 0: context.go('/home'); break;
          case 1: context.go('/library'); break;
          case 2: context.go('/scan/audio'); break;
          case 3: context.go('/profile'); break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_music_rounded),
          label: 'Bibliothèque',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner_rounded),
          label: 'Scanner',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
      ],
    );
  }
}
