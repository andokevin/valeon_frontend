// lib/screens/library/history_full_screen.dart (CORRIGÉ - avec favoris)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../widgets/layout/space_background.dart';
import '../scan/scan_result_screen.dart';
import '../../models/favorite_model.dart'; // ← AJOUT

class HistoryFullScreen extends StatefulWidget {
  const HistoryFullScreen({super.key});

  @override
  State<HistoryFullScreen> createState() => _HistoryFullScreenState();
}

class _HistoryFullScreenState extends State<HistoryFullScreen> {
  // Map pour suivre l'état des favoris localement
  final Map<int, bool> _favoritesStatus = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final library = Provider.of<LibraryProvider>(context, listen: false);
    final connectivity =
        Provider.of<ConnectivityProvider>(context, listen: false);

    if (auth.user != null && connectivity.isOnline) {
      await library.loadUserLibrary(auth.user!);
      
      // Initialiser le statut des favoris pour chaque scan
      _initFavoritesStatus(library);
    }
    
    setState(() => _isLoading = false);
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Aujourd'hui à ${DateFormat.Hm().format(date)}";
    } else if (difference.inDays == 1) {
      return "Hier à ${DateFormat.Hm().format(date)}";
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'audio':
      case 'music':
        return AppColors.primaryBlue;
      case 'image':
      case 'photo':
        return const Color(0xFF9B59B6);
      case 'video':
      case 'movie':
        return const Color(0xFF2ECC71);
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'audio':
      case 'music':
        return Icons.music_note;
      case 'image':
      case 'photo':
        return Icons.image;
      case 'video':
      case 'movie':
        return Icons.videocam;
      default:
        return Icons.history;
    }
  }

  Future<void> _navigateToScanResult(int scanId) async {
    final library = Provider.of<LibraryProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      ),
    );

    try {
      final scan = await library.getScanDetails(scanId);
      
      if (mounted) Navigator.pop(context);
      
      if (scan != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanResultScreen(
              scanId: scanId,
              initialData: scan.result,
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de charger les détails du scan'),
            backgroundColor: Colors.red,
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
    final connectivity = Provider.of<ConnectivityProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SpaceBackground(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, hPadding, isTablet, library, isDark),
            Expanded(
              child: !connectivity.isOnline
                  ? _buildOfflineView(isDark)
                  : _isLoading || library.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: AppColors.primaryBlue),
                        )
                      : library.history.isEmpty
                          ? _buildEmptyState(isTablet, isDark)
                          : RefreshIndicator(
                              onRefresh: _loadData,
                              color: AppColors.primaryBlue,
                              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                              child: ListView.separated(
                                padding: EdgeInsets.all(hPadding),
                                itemCount: library.history.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final scan = library.history[index];
                                  // Convertir scan.scanType (qui est un enum) en String
                                  final type = scan.scanType.toString().split('.').last;
                                  final color = _getTypeColor(type);
                                  final icon = _getTypeIcon(type);
                                  
                                  // Récupérer le statut du favori
                                  final isFavorite = _favoritesStatus[scan.scanId] ?? false;

                                  return GestureDetector(
                                    onTap: () => _navigateToScanResult(scan.scanId!),
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
                                          // Icône de type
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(icon, color: color),
                                          ),
                                          const SizedBox(width: 16),
                                          
                                          // Informations
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  scan.content?.contentTitle ?? 'Scan ${scan.scanType}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark ? AppColors.darkTextPrimary : Colors.white,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (scan.content?.contentArtist != null)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 4),
                                                    child: Text(
                                                      scan.content!.contentArtist!,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: isDark ? AppColors.darkTextSecondary : Colors.white70,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Text(
                                                    _formatDate(scan.scanDate),
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: isDark ? AppColors.darkTextSecondary : Colors.white70,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          
                                          // Bouton favoris avec changement de couleur
                                          IconButton(
                                            icon: Icon(
                                              isFavorite ? Icons.favorite : Icons.favorite_border,
                                              color: isFavorite 
                                                  ? AppColors.primaryBlue  // ← Couleur principale
                                                  : (isDark ? AppColors.darkTextSecondary : Colors.white54),
                                              size: 24,
                                            ),
                                            onPressed: () => _toggleFavorite(scan, auth, library),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double hPadding, bool isTablet,
      LibraryProvider library, bool isDark) {
    return Padding(
      padding: EdgeInsets.all(hPadding),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, 
                color: isDark ? AppColors.darkTextPrimary : Colors.white),
          ),
          const Expanded(
            child: Text(
              'Historique complet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: _isLoading ? null : _loadData,
            icon: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(Icons.refresh, 
                    color: isDark ? AppColors.darkTextPrimary : Colors.white),
          ),
        ],
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
            'Connectez-vous pour voir votre historique',
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
            Icons.history,
            size: isTablet ? 80 : 60,
            color: isDark ? AppColors.darkTextSecondary : Colors.white54,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun historique',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scannez du contenu pour voir votre historique',
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
