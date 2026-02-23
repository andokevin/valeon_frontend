// lib/screens/library/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';
import '../../widgets/layout/space_background.dart';
import '../../widgets/library/content_list_tile.dart';
import '../scan/scan_result_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
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
    final library = Provider.of<LibraryProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return SpaceBackground(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, hPadding, isTablet),
            Expanded(
              child: library.favorites.isEmpty
                  ? _buildEmptyState(isTablet)
                  : ListView.separated(
                      padding: EdgeInsets.all(hPadding),
                      itemCount: library.favorites.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final fav = library.favorites[index];
                        return ContentListTile(
                          imageUrl: fav.contentImage,
                          title: fav.contentTitle,
                          subtitle: fav.contentArtist ?? '',
                          type: fav.contentType,
                          trailing: IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () async {
                              await library.removeFromFavorites(
                                fav.contentId,
                                auth.user!,
                              );
                            },
                          ),
                          onTap: () {
                            // Naviguer vers le détail
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScanResultScreen(
                                  scanResult: {
                                    'title': fav.contentTitle,
                                    'artist': fav.contentArtist,
                                    'type': fav.contentType,
                                    'image': fav.contentImage,
                                    'content_id': fav.contentId,
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
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
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Mes Favoris',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: isTablet ? 80 : 60,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun favori',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Scannez du contenu et ajoutez-le à vos favoris',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
