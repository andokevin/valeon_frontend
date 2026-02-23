// lib/screens/library/library_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../widgets/layout/space_background.dart';
import '../../widgets/layout/offline_banner.dart';
import '../../widgets/library/content_list_tile.dart';
import 'favorites_screen.dart';
import 'history_screen.dart';
import 'playlists_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final library = Provider.of<LibraryProvider>(context, listen: false);

    if (auth.user != null) {
      await library.loadUserLibrary(auth.user!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final hPadding = ResponsiveHelper.paddingScreen(context);
    final connectivity = Provider.of<ConnectivityProvider>(context);
    final library = Provider.of<LibraryProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return SpaceBackground(
      child: SafeArea(
        child: Column(
          children: [
            if (!connectivity.isOnline) const OfflineBanner(),
            _buildHeader(context, hPadding, isTablet),
            if (library.isLoading)
              const Expanded(
                child: Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryBlue),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(hPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Statistiques
                      _buildStatsSection(context, library.stats, isTablet),

                      const SizedBox(height: 32),

                      // Sections de la bibliothèque
                      const Text(
                        'Ma collection',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildLibraryItem(
                        context: context,
                        icon: Icons.favorite,
                        color: Colors.red,
                        title: 'Mes favoris',
                        subtitle: 'Contenus sauvegardés',
                        count: library.favorites.length,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FavoritesScreen(),
                            ),
                          );
                        },
                        isTablet: isTablet,
                      ),

                      const SizedBox(height: 12),

                      _buildLibraryItem(
                        context: context,
                        icon: Icons.history,
                        color: AppColors.primaryBlue,
                        title: 'Historique',
                        subtitle: 'Scans récents',
                        count: library.history.length,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistoryScreen(),
                            ),
                          );
                        },
                        isTablet: isTablet,
                      ),

                      const SizedBox(height: 12),

                      _buildLibraryItem(
                        context: context,
                        icon: Icons.playlist_play,
                        color: Colors.purple,
                        title: 'Playlists',
                        subtitle: 'Mes collections',
                        count: library.playlists.length,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PlaylistsScreen(),
                            ),
                          );
                        },
                        isTablet: isTablet,
                      ),

                      const SizedBox(height: 40),

                      // Contenu récent
                      if (library.history.isNotEmpty) ...[
                        const Text(
                          'Récents',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...library.history.take(3).map((scan) {
                          if (scan.content == null) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ContentListTile(
                              imageUrl: scan.content!.contentImage,
                              title: scan.content!.contentTitle,
                              subtitle: scan.content!.contentArtist ?? '',
                              type: scan.content!.contentType,
                              onTap: () {
                                // Naviguer vers le détail
                              },
                            ),
                          );
                        }),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double hPadding, bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(hPadding),
      child: Row(
        children: [
          Container(
            width: isTablet ? 52 : 44,
            height: isTablet ? 52 : 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.lightPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.library_music, color: Colors.white),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          const Text(
            'Bibliothèque',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              _loadData();
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
      BuildContext context, Map<String, int> stats, bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.qr_code_scanner,
            label: 'Scans',
            value: (stats['total_scans'] ?? 0).toString(),
            color: AppColors.primaryBlue,
            isTablet: isTablet,
          ),
          _buildStatItem(
            icon: Icons.favorite,
            label: 'Favoris',
            value: (stats['total_favorites'] ?? 0).toString(),
            color: Colors.red,
            isTablet: isTablet,
          ),
          _buildStatItem(
            icon: Icons.playlist_play,
            label: 'Playlists',
            value: (stats['total_playlists'] ?? 0).toString(),
            color: Colors.purple,
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isTablet,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: isTablet ? 28 : 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildLibraryItem({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required int count,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: isTablet ? 30 : 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count éléments • $subtitle',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
