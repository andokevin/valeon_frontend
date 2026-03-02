// lib/screens/library/favorites_screen.dart (CORRIGÉ - navigation comme historique)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../widgets/library/content_list_tile.dart';
import '../scan/scan_result_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final Map<int, Map<String, dynamic>> _enrichedContents = {};
  bool _isLoading = false;

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
      setState(() => _isLoading = true);
      await library.loadUserLibrary(auth.user!);
      await _enrichFavoritesWithDetails(library);
      setState(() => _isLoading = false);
    }
  }

  // ===== Récupérer les détails complets via getScanDetails =====
  Future<void> _enrichFavoritesWithDetails(LibraryProvider library) async {
    _enrichedContents.clear();
    
    for (var fav in library.favorites) {
      try {
        // Chercher dans l'historique un scan qui correspond à ce contenu
        final relatedScans = library.history.where(
          (scan) => scan.content?.contentId == fav.contentId && scan.result != null
        ).toList();
        
        if (relatedScans.isNotEmpty) {
          // Prendre le scan le plus récent
          relatedScans.sort((a, b) => b.scanDate.compareTo(a.scanDate));
          final latestScan = relatedScans.first;
          
          // Récupérer les détails complets du scan
          final scanDetails = await library.getScanDetails(latestScan.scanId!);
          if (scanDetails != null && scanDetails.result != null) {
            // Convertir Map<dynamic, dynamic> en Map<String, dynamic>
            final Map<String, dynamic> convertedResult = {};
            scanDetails.result!.forEach((key, value) {
              convertedResult[key.toString()] = value;
            });
            _enrichedContents[fav.contentId] = convertedResult;
          }
        }
      } catch (e) {
        print('Erreur récupération détails pour ${fav.contentId}: $e');
      }
    }
  }

  // ===== NOUVELLE MÉTHODE: Navigation comme dans historique =====
  Future<void> _navigateToContent(BuildContext context, dynamic fav) async {
    final library = Provider.of<LibraryProvider>(context, listen: false);
    
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      ),
    );

    try {
      // Chercher un scan associé à ce contenu
      final relatedScans = library.history.where(
        (scan) => scan.content?.contentId == fav.contentId && scan.result != null
      ).toList();
      
      if (relatedScans.isNotEmpty) {
        // Prendre le scan le plus récent
        relatedScans.sort((a, b) => b.scanDate.compareTo(a.scanDate));
        final latestScan = relatedScans.first;
        
        if (mounted) Navigator.pop(context); // Fermer le dialogue
        
        // === MÊME NAVIGATION QUE L'HISTORIQUE ===
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanResultScreen(
              scanId: latestScan.scanId,
              initialData: latestScan.result,
            ),
          ),
        );
      } else {
        // Fallback si pas de scan trouvé
        if (mounted) Navigator.pop(context);
        
        // Utiliser les données du favori
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
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final hPadding = ResponsiveHelper.paddingScreen(context);
    final library = Provider.of<LibraryProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final connectivity = Provider.of<ConnectivityProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.darkPurple,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? AppColors.darkTextPrimary : Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mes Favoris',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? AppColors.darkTextPrimary : Colors.white,
            ),
            onPressed: connectivity.isOnline ? _loadData : null,
          ),
        ],
      ),
      body: !connectivity.isOnline
          ? _buildOfflineView(isDark)
          : _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBlue),
                )
              : library.favorites.isEmpty
                  ? _buildEmptyState(isTablet, isDark)
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: AppColors.primaryBlue,
                      backgroundColor:
                          isDark ? AppColors.darkSurface : Colors.white,
                      child: ListView.separated(
                        padding: EdgeInsets.all(hPadding),
                        itemCount: library.favorites.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final fav = library.favorites[index];
                          final enriched = _enrichedContents[fav.contentId];
                          return _buildFavoriteItem(context, fav, enriched, auth, library, isDark);
                        },
                      ),
                    ),
    );
  }

  // ===== Élément favori avec affichage enrichi =====
  Widget _buildFavoriteItem(BuildContext context, dynamic fav, 
      Map<String, dynamic>? enriched, AuthProvider auth, 
      LibraryProvider library, bool isDark) {
    
    Color typeColor;
    IconData typeIcon;
    String typeLabel;

    switch (fav.contentType) {
      case 'music':
        typeColor = AppColors.primaryBlue;
        typeIcon = Icons.music_note;
        typeLabel = 'Musique';
        break;
      case 'movie':
      case 'movie_poster':
        typeColor = Colors.purple;
        typeIcon = Icons.movie;
        typeLabel = 'Film';
        break;
      case 'tv_show':
        typeColor = Colors.orange;
        typeIcon = Icons.tv;
        typeLabel = 'Série';
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.favorite;
        typeLabel = 'Contenu';
    }

    // Utiliser les données enrichies si disponibles
    final displayTitle = enriched?['title'] ?? fav.contentTitle;
    final displayArtist = enriched?['artist'] ?? fav.contentArtist;
    final displayImage = enriched?['image'] ?? fav.contentImage;
    final displayYear = enriched?['year'];
    final displayAlbum = enriched?['album'];
    final displayDescription = enriched?['description'] ?? enriched?['natural_response'];

    return GestureDetector(
      onTap: () => _navigateToContent(context, fav), // ← Utilise la nouvelle méthode
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== IMAGE =====
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: displayImage != null && displayImage.isNotEmpty
                  ? Image.network(
                      displayImage,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: typeColor.withOpacity(0.2),
                          child: Icon(
                            typeIcon,
                            color: typeColor,
                            size: 40,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 80,
                          height: 80,
                          color: typeColor.withOpacity(0.1),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: typeColor,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: typeColor.withOpacity(0.2),
                      child: Icon(
                        typeIcon,
                        color: typeColor,
                        size: 40,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            
            // ===== INFORMATIONS DÉTAILLÉES =====
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    displayTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Artiste / Réalisateur
                  if (displayArtist != null && displayArtist.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        displayArtist,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.darkTextSecondary : Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  
                  // Album pour la musique
                  if (fav.contentType == 'music' && displayAlbum != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Album: $displayAlbum',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  
                  // Année
                  if (displayYear != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Année: $displayYear',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : Colors.white70,
                        ),
                      ),
                    ),
                  
                  // Description courte ou réponse naturelle
                  if (displayDescription != null && displayDescription.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        displayDescription.length > 80
                            ? '${displayDescription.substring(0, 80)}...'
                            : displayDescription,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : Colors.white54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Type et date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
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
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ajouté le ${_formatDate(fav.createdAt)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Bouton suppression
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              onPressed: () async {
                await library.removeFromFavorites(
                  fav.contentId,
                  auth.user!,
                );
                _loadData(); // Recharger après suppression
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Retiré des favoris'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
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
      return "aujourd'hui";
    } else if (difference.inDays == 1) {
      return "hier";
    } else if (difference.inDays < 7) {
      return "il y a ${difference.inDays} jours";
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }

  Widget _buildOfflineView(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 64,
            color: isDark ? AppColors.darkTextSecondary : Colors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            'Pas de connexion internet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connectez-vous pour voir vos favoris',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: isTablet ? 80 : 60,
            color: isDark ? AppColors.darkTextSecondary : Colors.white54,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun favori',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scannez du contenu et ajoutez-le à vos favoris',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
