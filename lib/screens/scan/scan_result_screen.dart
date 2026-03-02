// lib/screens/scan/scan_result_screen.dart (CORRIGÉ - avec conversion complète)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:valeon/models/content_model.dart';
import 'package:valeon/models/playlist_model.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/scan_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../widgets/common/cached_image.dart';
import '../../services/api_service.dart';
import '../../utils/date_utils.dart';

class ScanResultScreen extends StatefulWidget {
  final int? scanId;
  final Map<String, dynamic>? scanResult;
  final Map<String, dynamic>? initialData;

  const ScanResultScreen({
    super.key,
    this.scanId,
    this.scanResult,
    this.initialData,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _result;
  bool _isLoading = false;
  String? _error;
  bool _isFavorite = false;
  bool _checkingFavorite = true;
  bool _isTogglingFavorite = false;

  // ===== Recommandations similaires =====
  List<Map<String, dynamic>> _similarContents = [];
  bool _loadingSimilar = false;

  @override
  void initState() {
    super.initState();
    _initializeResult();
  }

  // ===== FONCTION UTILITAIRE POUR CONVERTIR Map<dynamic, dynamic> en Map<String, dynamic> =====
  Map<String, dynamic> _convertToMapStringDynamic(dynamic input) {
    if (input == null) return {};
    
    if (input is Map<String, dynamic>) {
      return input;
    } else if (input is Map) {
      // Convertir Map<dynamic, dynamic> en Map<String, dynamic>
      final Map<String, dynamic> result = {};
      input.forEach((key, value) {
        final String stringKey = key.toString();
        if (value is Map) {
          result[stringKey] = _convertToMapStringDynamic(value);
        } else if (value is List) {
          result[stringKey] = value.map((item) {
            if (item is Map) {
              return _convertToMapStringDynamic(item);
            }
            return item;
          }).toList();
        } else {
          result[stringKey] = value;
        }
      });
      return result;
    }
    return {};
  }

  // ===== FONCTION POUR CONVERTIR UNE LISTE =====
  List<Map<String, dynamic>> _convertToListMapStringDynamic(List<dynamic>? input) {
    if (input == null) return [];
    
    return input.map((item) {
      if (item is Map<String, dynamic>) {
        return item;
      } else if (item is Map) {
        return _convertToMapStringDynamic(item);
      }
      return <String, dynamic>{};
    }).toList();
  }

  Future<void> _initializeResult() async {
    if (widget.scanId != null) {
      await _loadScanFromId(widget.scanId!);
    } else if (widget.scanResult != null) {
      setState(() {
        _result = _convertToMapStringDynamic(widget.scanResult);
        _isLoading = false;
      });
      _checkIfFavorite();
      _loadSimilarContents();
    } else if (widget.initialData != null) {
      setState(() {
        _result = _convertToMapStringDynamic(widget.initialData);
        _isLoading = false;
      });
      _checkIfFavorite();
      _loadSimilarContents();
    } else {
      setState(() {
        _error = 'Aucun résultat disponible';
        _isLoading = false;
      });
    }
  }

  // ===== Charger les recommandations similaires =====
  Future<void> _loadSimilarContents() async {
    if (_result == null) return;

    final contentId = _result!['content_id'] ?? _result!['id'];
    
    if (contentId == null || contentId == 0) {
      debugPrint('⚠️ Pas de content_id valide, impossible de charger les similaires');
      return;
    }

    setState(() {
      _loadingSimilar = true;
    });

    try {
      final response = await _apiService.getSimilarContent(contentId, limit: 3);
      
      if (response != null && response['recommendations'] != null) {
        // Convertir les recommandations
        final recommendationsList = response['recommendations'] as List<dynamic>? ?? [];
        final convertedRecommendations = _convertToListMapStringDynamic(recommendationsList);
        
        setState(() {
          _similarContents = convertedRecommendations;
          _loadingSimilar = false;
        });
        
        debugPrint('✅ ${_similarContents.length} recommandations chargées');
      } else {
        setState(() {
          _similarContents = [];
          _loadingSimilar = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Erreur chargement similaires: $e');
      setState(() {
        _loadingSimilar = false;
      });
    }
  }

  // ===== Naviguer vers un contenu similaire =====
  Future<void> _navigateToSimilar(Map<String, dynamic> similar) async {
    final connectivity = Provider.of<ConnectivityProvider>(context, listen: false);
    
    if (!connectivity.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connexion internet requise'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      ),
    );

    try {
      Map<String, dynamic> similarResult = {
        'title': similar['title'],
        'artist': similar['artist'] ?? similar['director'],
        'type': similar['type'] ?? 'music',
        'image': similar['image'],
        'year': similar['year'],
        'album': similar['album'],
        'description': similar['description'] ?? similar['reason'],
        'spotify_id': similar['spotify_id'],
        'youtube_id': similar['youtube_id'],
        'tmdb_id': similar['tmdb_id'],
        'confidence': 0.9,
      };

      if (similar['spotify'] != null) {
        similarResult['spotify'] = _convertToMapStringDynamic(similar['spotify']);
      }
      if (similar['youtube'] != null) {
        similarResult['youtube'] = _convertToMapStringDynamic(similar['youtube']);
      }
      if (similar['tmdb'] != null) {
        similarResult['tmdb'] = _convertToMapStringDynamic(similar['tmdb']);
      }

      if (mounted) Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanResultScreen(
            scanResult: similarResult,
          ),
        ),
      );

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

  Future<void> _loadScanFromId(int scanId) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final scanProvider = Provider.of<ScanProvider>(context, listen: false);
      final scan = await scanProvider.getScanById(scanId);

      if (scan != null && scan.result != null) {
        setState(() {
          _result = _convertToMapStringDynamic(scan.result);
          _isLoading = false;
        });
        _checkIfFavorite();
        _loadSimilarContents();
        return;
      }

      final library = Provider.of<LibraryProvider>(context, listen: false);
      final historyScan = await library.getScanDetails(scanId);

      if (historyScan != null && historyScan.result != null) {
        setState(() {
          _result = _convertToMapStringDynamic(historyScan.result);
          _isLoading = false;
        });
        _checkIfFavorite();
        _loadSimilarContents();
        return;
      }

      setState(() {
        _error = 'Scan introuvable';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _checkIfFavorite() async {
    if (_result == null) return;

    final contentId = _result!['content_id'];
    
    if (contentId == null || contentId == 0) {
      setState(() {
        _checkingFavorite = false;
        _isFavorite = false;
      });
      return;
    }

    try {
      final library = Provider.of<LibraryProvider>(context, listen: false);
      final isFav = await library.isFavorite(contentId);
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
          _checkingFavorite = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Erreur check favorite: $e');
      setState(() {
        _checkingFavorite = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_result == null || _isTogglingFavorite) return;

    final contentId = _result!['content_id'];
    
    if (contentId == null || contentId == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ajouter aux favoris (ID manquant)'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user == null) return;

    final library = Provider.of<LibraryProvider>(context, listen: false);

    final content = ContentModel(
      contentId: contentId,
      contentType: _result!['type'] ?? 'unknown',
      contentTitle: _result!['title'] ?? '',
      contentArtist: _result!['artist'] ?? _result!['director'],
      contentImage: _result!['image'],
      contentDescription: _result!['description'],
      contentReleaseDate: _result!['year'],
    );

    setState(() {
      _isTogglingFavorite = true;
    });

    try {
      if (_isFavorite) {
        await library.removeFromFavorites(contentId, auth.user!);
        setState(() {
          _isFavorite = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Retiré des favoris'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        await library.addToFavorites(content, auth.user!);
        setState(() {
          _isFavorite = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ajouté aux favoris'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur toggle favorite: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _isTogglingFavorite = false;
      });
    }
  }

  String? _getImageUrl(Map<String, dynamic> result) {
    if (result['image'] != null && result['image'].toString().isNotEmpty) {
      return result['image'];
    }
    if (result['spotify'] != null && result['spotify']['image'] != null) {
      return result['spotify']['image'];
    }
    if (result['youtube'] != null && result['youtube']['thumbnail'] != null) {
      return result['youtube']['thumbnail'];
    }
    return null;
  }

  String? _getSpotifyUrl(Map<String, dynamic>? spotify) {
    if (spotify == null || spotify.isEmpty) return null;
    if (spotify['spotify_url'] != null) return spotify['spotify_url'];
    if (spotify['external_urls'] != null &&
        spotify['external_urls']['spotify'] != null) {
      return spotify['external_urls']['spotify'];
    }
    if (spotify['id'] != null) {
      return 'https://open.spotify.com/track/${spotify['id']}';
    }
    if (spotify['spotify_id'] != null) {
      return 'https://open.spotify.com/track/${spotify['spotify_id']}';
    }
    return null;
  }

  String? _getYoutubeUrl(Map<String, dynamic>? youtube) {
    if (youtube == null || youtube.isEmpty) return null;
    if (youtube['url'] != null) return youtube['url'];
    if (youtube['video_id'] != null) {
      return 'https://www.youtube.com/watch?v=${youtube['video_id']}';
    }
    if (youtube['id'] != null) {
      return 'https://www.youtube.com/watch?v=${youtube['id']}';
    }
    return null;
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    if (url.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lien invalide'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    String finalUrl = url.trim();

    try {
      if (finalUrl.contains('spotify.com')) {
        final spotifyTrackId = _extractSpotifyTrackId(finalUrl);
        if (spotifyTrackId != null) {
          final spotifyIntent = 'spotify:track:$spotifyTrackId';
          final spotifyUri = Uri.parse(spotifyIntent);
          
          if (await canLaunchUrl(spotifyUri)) {
            await launchUrl(spotifyUri, mode: LaunchMode.externalApplication);
            return;
          }
        }
      }
      
      else if (finalUrl.contains('youtube.com') || finalUrl.contains('youtu.be')) {
        final youtubeVideoId = _extractYoutubeVideoId(finalUrl);
        if (youtubeVideoId != null) {
          final youtubeIntent = 'vnd.youtube:$youtubeVideoId';
          final youtubeUri = Uri.parse(youtubeIntent);
          
          if (await canLaunchUrl(youtubeUri)) {
            await launchUrl(youtubeUri, mode: LaunchMode.externalApplication);
            return;
          }
        }
      }

      if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
        finalUrl = 'https://$finalUrl';
      }

      final uri = Uri.parse(finalUrl);
      
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      }
      
      if (!launched && context.mounted) {
        throw Exception('Échec de lancement');
      }
      
    } catch (e) {
      debugPrint('❌ Erreur _launchURL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d\'ouvrir le lien: $finalUrl'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String? _extractSpotifyTrackId(String url) {
    final RegExp trackRegex = RegExp(r'track[/:]([a-zA-Z0-9]+)');
    final match = trackRegex.firstMatch(url);
    return match?.group(1);
  }

  String? _extractYoutubeVideoId(String url) {
    final RegExp youtubeRegex = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    );
    final match = youtubeRegex.firstMatch(url);
    return match?.group(1);
  }

  Widget _buildAddToPlaylistButton(BuildContext context, int contentId, bool isDark) {
    if (contentId == null || contentId == 0) {
      return const SizedBox();
    }
    
    final library = Provider.of<LibraryProvider>(context);
    final playlists = library.playlists;
    
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.playlist_add,
        color: isDark ? AppColors.darkTextPrimary : Colors.white,
      ),
      tooltip: 'Ajouter à une playlist',
      onSelected: (playlistId) async {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        if (auth.user == null) return;
        
        final id = int.tryParse(playlistId);
        if (id != null) {
          await library.addToPlaylist(id, contentId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ajouté à la playlist'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      itemBuilder: (context) {
        if (playlists.isEmpty) {
          return [
            const PopupMenuItem(
              value: '',
              enabled: false,
              child: Text('Aucune playlist'),
            ),
          ];
        }
        
        return playlists.map((playlist) {
          return PopupMenuItem(
            value: playlist.playlistId.toString(),
            child: Row(
              children: [
                const Icon(Icons.playlist_play, size: 18, color: Colors.white70),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    playlist.playlistName,
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${playlist.contentCount}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.darkPurple,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      );
    }

    if (_error != null || _result == null) {
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
          title: const Text('Résultat', style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 64,
                  color: isDark ? AppColors.darkTextSecondary : Colors.red),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Aucun résultat disponible',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    final r = _result!;
    final title = r['title'] ?? r['content_title'] ?? 'Inconnu';
    final type = r['type'] ?? r['content_type'] ?? 'unknown';
    final artist = r['artist'] ?? r['content_artist'];
    final director = r['director'];
    final actors = r['actors'] is List ? (r['actors'] as List).join(', ') : null;
    final album = r['album'];
    final year = r['year'] ?? r['release_date'];
    final genre = r['genre'];
    final description = r['description'] ?? r['content_description'];
    final image = _getImageUrl(r);
    final confidence = (r['confidence'] is num) ? ((r['confidence'] as num) * 100).toInt() : 0;

    // ===== CORRECTION : Convertir spotify et youtube avant de les utiliser =====
    final Map<String, dynamic> spotify = r['spotify'] is Map 
        ? _convertToMapStringDynamic(r['spotify']) 
        : {};
    final Map<String, dynamic> youtube = r['youtube'] is Map 
        ? _convertToMapStringDynamic(r['youtube']) 
        : {};
    
    final spotifyUrl = _getSpotifyUrl(spotify);
    final youtubeUrl = _getYoutubeUrl(youtube);

    final contentId = r['content_id'] ?? r['id'];
    final isMusic = type.contains('music') ||
        type.contains('album') ||
        type.contains('song') ||
        type.contains('cover');
    final isMovie = type.contains('movie') ||
        type.contains('film') ||
        type.contains('poster') ||
        type.contains('scene');

    final auth = Provider.of<AuthProvider>(context);
    final library = Provider.of<LibraryProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.darkPurple,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: isDark ? AppColors.darkTextPrimary : Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              if (contentId != null && contentId != 0)
                _buildAddToPlaylistButton(context, contentId, isDark),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (image != null && image.isNotEmpty)
                    CachedImageWidget(url: image, fit: BoxFit.cover)
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryBlue, AppColors.lightPurple],
                        ),
                      ),
                      child: Icon(
                        isMusic ? Icons.music_note : Icons.movie,
                        size: 80,
                        color: Colors.white54,
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    _buildTypeBadge(type, isDark),
                    const SizedBox(width: 8),
                    if (confidence > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getConfidenceColor(confidence).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$confidence% confiance',
                          style: TextStyle(
                            color: _getConfidenceColor(confidence),
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  title,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : Colors.white,
                  ),
                ),

                if (artist != null || director != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    artist ?? director ?? '',
                    style: TextStyle(
                      fontSize: 20,
                      color: isDark ? AppColors.darkTextSecondary : Colors.white70,
                    ),
                  ),
                ],

                if (year != null || genre != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${year ?? ''}${year != null && genre != null ? ' - ' : ''}${genre ?? ''}',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppColors.darkTextSecondary : Colors.white54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],

                if (actors != null && actors.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Avec: $actors',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : Colors.white70,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                if (description != null && description.isNotEmpty)
                  Text(
                    description,
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : Colors.white70,
                      height: 1.6,
                      fontSize: 16,
                    ),
                  ),

                const SizedBox(height: 32),

                if (isMusic) ...[
                  _buildSectionTitle('Écouter sur', isDark),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      if (youtubeUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildMusicPlatformButton(
                              'Regarder sur YouTube', Colors.red, youtubeUrl, context, isDark),
                        ),
                      if (spotifyUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildMusicPlatformButton(
                              'Écouter sur Spotify', const Color(0xFF1DB954), spotifyUrl, context, isDark),
                        ),
                    ],
                  ),
                ] else if (isMovie) ...[
                  _buildSectionTitle('Regarder', isDark),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      if (youtubeUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildMusicPlatformButton(
                              'Regarder la bande-annonce', Colors.red, youtubeUrl, context, isDark),
                        ),
                    ],
                  ),
                ],

                const SizedBox(height: 32),

                // ===== SECTION RECOMMANDATIONS SIMILAIRES =====
                if (!_loadingSimilar && _similarContents.isNotEmpty) ...[
                  _buildSectionTitle(
                      isMusic ? 'Chansons similaires' : 'Films similaires',
                      isDark),
                  const SizedBox(height: 16),
                  ..._similarContents.map((similar) {
                    final reason = similar['reason'] ?? similar['description'];
                    
                    return GestureDetector(
                      onTap: () => _navigateToSimilar(similar),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: isDark
                                  ? AppColors.darkDivider
                                  : Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: similar['image'] != null
                                  ? Image.network(
                                      similar['image'],
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 60,
                                          height: 60,
                                          color: (isMusic ? AppColors.primaryBlue : Colors.orange).withOpacity(0.2),
                                          child: Icon(
                                            isMusic ? Icons.music_note : Icons.movie,
                                            color: isMusic ? AppColors.primaryBlue : Colors.orange,
                                            size: 30,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      color: (isMusic ? AppColors.primaryBlue : Colors.orange).withOpacity(0.2),
                                      child: Icon(
                                        isMusic ? Icons.music_note : Icons.movie,
                                        color: isMusic ? AppColors.primaryBlue : Colors.orange,
                                        size: 30,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    similar['title'] ?? 'Titre inconnu',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.darkTextPrimary : Colors.white,
                                      fontSize: 15,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  if (similar['artist'] != null || similar['director'] != null)
                                    Text(
                                      similar['artist'] ?? similar['director'] ?? '',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? AppColors.darkTextSecondary : Colors.white70,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  if (similar['year'] != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Année: ${similar['year']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.darkTextSecondary : Colors.white54,
                                      ),
                                    ),
                                  ],
                                  if (reason != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      reason.length > 60 ? '${reason.substring(0, 60)}...' : reason,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.darkTextSecondary : Colors.white54,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            
                            Icon(
                              Icons.arrow_forward_ios,
                              color: isDark ? AppColors.darkTextSecondary : Colors.white54,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                ] else if (_loadingSimilar) ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                          color: AppColors.primaryBlue,
                          strokeWidth: 2,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                if (auth.isAuthenticated && contentId != null && contentId != 0)
                  _buildFavoriteButton(context, contentId, isDark),

                const SizedBox(height: 20),

                OutlinedButton.icon(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Nouveau scan'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.darkTextPrimary : Colors.white,
      ),
    );
  }

  Widget _buildMusicPlatformButton(String platform, Color color, String url,
      BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _launchURL(context, url),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              platform.contains('YouTube') ? Icons.play_circle_filled : Icons.music_note,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              platform,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context, int contentId, bool isDark) {
    if (_checkingFavorite) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: _isTogglingFavorite ? null : _toggleFavorite,
      icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
      label: Text(_isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris'),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isFavorite ? Colors.red : AppColors.primaryBlue,
        minimumSize: const Size(double.infinity, 52),
      ),
    );
  }

  Widget _buildTypeBadge(String type, bool isDark) {
    Color color;
    String label;

    switch (type) {
      case 'music':
      case 'song':
      case 'album_cover':
      case 'music_video':
      case 'concert_photo':
        color = AppColors.primaryBlue;
        label = '🎵 Musique';
        break;
      case 'movie':
      case 'film':
      case 'movie_poster':
      case 'movie_scene':
      case 'tv_show_scene':
        color = Colors.orange;
        label = '🎬 Film';
        break;
      case 'tv_show':
        color = Colors.purple;
        label = '📺 Série';
        break;
      case 'artist':
      case 'artist_photo':
        color = Colors.green;
        label = '👤 Artiste';
        break;
      default:
        color = Colors.grey;
        label = '📁 Contenu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 80) return Colors.green;
    if (confidence >= 50) return Colors.orange;
    return Colors.red;
  }
}
