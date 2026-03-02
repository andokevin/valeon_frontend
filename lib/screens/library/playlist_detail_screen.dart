// lib/screens/library/playlist_detail_screen.dart (CORRIGÉ - navigation comme historique)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valeon/models/playlist_model.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../widgets/library/content_list_tile.dart';
import '../scan/scan_result_screen.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final int playlistId;
  final String playlistName;

  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
    required this.playlistName,
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  PlaylistModel? _playlist;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlaylist();
  }

  Future<void> _loadPlaylist() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final library = Provider.of<LibraryProvider>(context, listen: false);
      final playlist = await library.getPlaylist(widget.playlistId);
      setState(() {
        _playlist = playlist;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFromPlaylist(int contentId) async {
    final library = Provider.of<LibraryProvider>(context, listen: false);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        title: const Text(
          'Retirer de la playlist',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Voulez-vous vraiment retirer cet élément de la playlist ?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // À implémenter avec l'API
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fonctionnalité à implémenter'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // ===== NOUVELLE MÉTHODE: Navigation comme dans historique =====
  Future<void> _navigateToContent(BuildContext context, dynamic content) async {
    final library = Provider.of<LibraryProvider>(context, listen: false);
    
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
        (scan) => scan.content?.contentId == content.contentId && scan.result != null
      ).toList();
      
      if (relatedScans.isNotEmpty) {
        // Prendre le scan le plus récent
        relatedScans.sort((a, b) => b.scanDate.compareTo(a.scanDate));
        final latestScan = relatedScans.first;
        
        if (mounted) Navigator.pop(context);
        
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
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanResultScreen(
              scanResult: {
                'title': content.contentTitle,
                'artist': content.contentArtist,
                'type': content.contentType,
                'image': content.contentImage,
                'content_id': content.contentId,
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
    final auth = Provider.of<AuthProvider>(context);
    final library = Provider.of<LibraryProvider>(context);
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
        title: Text(
          widget.playlistName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert,
                color: isDark ? AppColors.darkTextPrimary : Colors.white),
            onSelected: (value) async {
              if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor:
                        isDark ? AppColors.darkSurface : AppColors.surface,
                    title: const Text('Supprimer la playlist',
                        style: TextStyle(color: Colors.white)),
                    content: const Text(
                        'Voulez-vous vraiment supprimer cette playlist ?',
                        style: TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text('Supprimer'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && auth.user != null) {
                  await library.deletePlaylist(widget.playlistId);
                  if (mounted) Navigator.pop(context);
                }
              } else if (value == 'refresh') {
                await _loadPlaylist();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Rafraîchir', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Supprimer', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: !connectivity.isOnline
          ? _buildOfflineView(isDark)
          : _isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryBlue))
              : _error != null
                  ? _buildErrorView(isDark)
                  : _playlist == null || _playlist!.contents.isEmpty
                      ? _buildEmptyState(isTablet, isDark)
                      : RefreshIndicator(
                          onRefresh: _loadPlaylist,
                          color: AppColors.primaryBlue,
                          backgroundColor:
                              isDark ? AppColors.darkSurface : Colors.white,
                          child: ListView.separated(
                            padding: EdgeInsets.all(hPadding),
                            itemCount: _playlist!.contents.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final content = _playlist!.contents[index];
                              return ContentListTile(
                                imageUrl: content.contentImage,
                                title: content.contentTitle,
                                subtitle: content.contentArtist ?? '',
                                type: content.contentType,
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _removeFromPlaylist(content.contentId),
                                ),
                                onTap: () => _navigateToContent(context, content), // ← Changé ici
                              );
                            },
                          ),
                        ),
    );
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
            'Connectez-vous pour voir vos playlists',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: isDark ? AppColors.darkTextSecondary : Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Une erreur est survenue',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadPlaylist,
            child: const Text('Réessayer'),
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
            Icons.playlist_add,
            size: isTablet ? 80 : 60,
            color: isDark ? AppColors.darkTextSecondary : Colors.white54,
          ),
          const SizedBox(height: 16),
          Text(
            'Playlist vide',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez des contenus depuis vos scans',
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
