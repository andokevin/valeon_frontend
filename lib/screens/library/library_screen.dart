// lib/screens/library/library_screen.dart (CORRIGÉ - avec favoris)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../widgets/layout/space_background.dart';
import '../../widgets/library/content_list_tile.dart';
import 'favorites_screen.dart';
import 'playlists_screen.dart';
import 'history_full_screen.dart';
import '../scan/scan_result_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  // Map pour suivre l'état des favoris localement
  final Map<int, bool> _favoritesStatus = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final library = Provider.of<LibraryProvider>(context, listen: false);
    final connectivity =
        Provider.of<ConnectivityProvider>(context, listen: false);

    if (auth.user != null && connectivity.isOnline) {
      await library.loadUserLibrary(auth.user!);
      _initFavoritesStatus(library);
    }
  }

  void _initFavoritesStatus(LibraryProvider library) {
    _favoritesStatus.clear();
    for (var scan in library.history) {
      if (scan.content != null) {
        // Vérifier si ce contenu est dans les favoris
        final isFav = library.favorites.any(
          (fav) => fav.contentId == scan.content!.contentId
        );
        _favoritesStatus[scan.scanId!] = isFav;
      }
    }
  }

  Future<void> _toggleFavorite(dynamic scan, AuthProvider auth, LibraryProvider library) async {
    if (scan.content == null || auth.user == null) return;
    
    final contentId = scan.content!.contentId;
    final scanId = scan.scanId!;
    final currentStatus = _favoritesStatus[scanId] ?? false;
    
    // Mise à jour optimiste de l'UI
    setState(() {
      _favoritesStatus[scanId] = !currentStatus;
    });

    try {
      if (currentStatus) {
        // Retirer des favoris
        await library.removeFromFavorites(contentId, auth.user!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Retiré des favoris'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        // Ajouter aux favoris
        await library.addToFavorites(scan.content!, auth.user!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ajouté aux favoris'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      // En cas d'erreur, annuler la mise à jour optimiste
      setState(() {
        _favoritesStatus[scanId] = currentStatus;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final hPadding = ResponsiveHelper.paddingScreen(context);
    final connectivity = Provider.of<ConnectivityProvider>(context);
    final library = Provider.of<LibraryProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SpaceBackground(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, hPadding, isTablet, connectivity),
            if (!connectivity.isOnline) _buildOfflineBanner(),
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
                      if (connectivity.isOnline) ...[
                        _buildStatsSection(context, library.stats, isTablet, isDark),
                        const SizedBox(height: 32),
                      ],

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
                        onTap: connectivity.isOnline
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const FavoritesScreen(),
                                  ),
                                );
                              }
                            : null,
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
                        onTap: connectivity.isOnline
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PlaylistsScreen(),
                                  ),
                                );
                              }
                            : null,
                        isTablet: isTablet,
                      ),

                      const SizedBox(height: 40),

                      // ===== SECTION HISTORIQUE (intégrée dans bibliothèque) =====
                      if (library.history.isNotEmpty && connectivity.isOnline) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Historique des scans',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HistoryFullScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Voir tout',
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...library.history.take(5).map((scan) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildHistoryItem(context, scan, auth, library, isDark),
                          );
                        }),
                      ] else if (connectivity.isOnline) ...[
                        const Text(
                          'Historique des scans',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark 
                                ? AppColors.darkSurface.withOpacity(0.5)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark 
                                  ? AppColors.darkDivider
                                  : Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: const Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 48,
                                  color: Colors.white54,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Aucun scan récent',
                                  style: TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Scannez du contenu pour voir votre historique',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Widget _buildHeader(BuildContext context, double hPadding, bool isTablet,
      ConnectivityProvider connectivity) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            onPressed: connectivity.isOnline ? _loadData : null,
            icon: Icon(Icons.refresh,
                color: connectivity.isOnline 
                    ? (isDark ? AppColors.darkTextPrimary : Colors.white)
                    : Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Colors.orange,
      child: const Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.white, size: 18),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mode hors ligne - Bibliothèque non disponible',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
      BuildContext context, Map<String, int> stats, bool isTablet, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkSurface
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark 
              ? AppColors.darkDivider
              : Colors.white.withOpacity(0.2),
        ),
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
    required VoidCallback? onTap,
    required bool isTablet,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.darkSurface
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark 
                  ? AppColors.darkDivider
                  : Colors.white.withOpacity(0.2),
            ),
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
                        color: isDark ? AppColors.darkTextPrimary : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count éléments • $subtitle',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : Colors.white70,
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
      ),
    );
  }

  // ===== Élément d'historique avec cœur fonctionnel =====
  Widget _buildHistoryItem(BuildContext context, dynamic scan, 
      AuthProvider auth, LibraryProvider library, bool isDark) {
    
    Color typeColor;
    IconData typeIcon;
    String typeLabel;

    switch (scan.scanType) {
      case 'audio':
      case 'music':
        typeColor = AppColors.primaryBlue;
        typeIcon = Icons.music_note;
        typeLabel = 'Musique';
        break;
      case 'image':
      case 'photo':
        typeColor = Colors.purple;
        typeIcon = Icons.image;
        typeLabel = 'Image';
        break;
      case 'video':
      case 'movie':
        typeColor = Colors.green;
        typeIcon = Icons.movie;
        typeLabel = 'Vidéo';
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.history;
        typeLabel = 'Scan';
    }

    // Récupérer le statut du favori
    final isFavorite = _favoritesStatus[scan.scanId] ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanResultScreen(
              scanId: scan.scanId,
              initialData: scan.result,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark 
              ? AppColors.darkSurface
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark 
                ? AppColors.darkDivider
                : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            // Icône de type
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                typeIcon,
                color: typeColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.content?.contentTitle ?? 'Scan ${scan.scanType}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (scan.content?.contentArtist != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      scan.content!.contentArtist!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(scan.scanDate),
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppColors.darkTextSecondary : Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Bouton favoris avec changement de couleur
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite 
                    ? AppColors.primaryBlue  // Couleur principale quand actif
                    : (isDark ? AppColors.darkTextSecondary : Colors.white54),
                size: 20,
              ),
              onPressed: () => _toggleFavorite(scan, auth, library),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Aujourd'hui";
    } else if (difference.inDays == 1) {
      return "Hier";
    } else if (difference.inDays < 7) {
      return "Il y a ${difference.inDays} jours";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }
}
