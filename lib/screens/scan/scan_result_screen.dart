// lib/screens/scan/scan_result_screen.dart
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:valeon/models/content_model.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';
import '../../widgets/common/cached_image.dart';
import '../../widgets/common/platform_button.dart';

class ScanResultScreen extends StatelessWidget {
  final Map<String, dynamic>? scanResult;

  const ScanResultScreen({super.key, this.scanResult});

  @override
  Widget build(BuildContext context) {
    if (scanResult == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Résultat')),
        body: const Center(
          child: Text(
            'Aucun résultat disponible',
            style: TextStyle(color: AppColors.onSurface),
          ),
        ),
      );
    }

    final r = scanResult!;
    final title = r['title'] ?? r['content_title'] ?? 'Inconnu';
    final type = r['type'] ?? r['content_type'] ?? 'unknown';
    final artist = r['artist'] ?? r['content_artist'];
    final image = r['image'] ?? r['content_image'];
    final description = r['description'] ?? r['content_description'];
    final confidence = ((r['confidence'] ?? 0.0) * 100).toInt();
    final metadata = r['metadata'] as Map<String, dynamic>? ?? {};
    final externalLinks = r['external_links'] as Map<String, dynamic>? ?? {};
    final streaming = r['streaming'] as Map<String, dynamic>?;
    final youtube = r['youtube'] as Map<String, dynamic>?;
    final contentId = r['content_id'] ?? r['id'];

    final auth = Provider.of<AuthProvider>(context);
    final library = Provider.of<LibraryProvider>(context);
    final isFavorite =
        contentId != null ? (library.isFavorite(contentId) as bool) : false;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (image != null && image.isNotEmpty)
                    CachedImageWidget(url: image, fit: BoxFit.cover)
                  else
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryBlue,
                            AppColors.lightPurple
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.music_note,
                        size: 80,
                        color: Colors.white54,
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Badge type + confiance
                Row(
                  children: [
                    _buildTypeBadge(type),
                    const SizedBox(width: 8),
                    if (confidence > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              _getConfidenceColor(confidence).withOpacity(0.15),
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
                const SizedBox(height: 12),

                // Titre
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (artist != null && artist.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    artist,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  ),
                ],

                // Métadonnées
                if (metadata.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Détails',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMetadataGrid(metadata),
                ],

                // Liens YouTube
                if (youtube != null) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Regarder sur YouTube',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  PlatformButton(
                    platform: 'YouTube',
                    onTap: () => _launchURL(context, youtube['url'] ?? ''),
                  ),
                ],

                // Plateformes de streaming
                if (streaming != null && streaming['streaming'] != null) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Disponible sur',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStreamingList(streaming['streaming']),
                ],

                // Liens externes
                if (externalLinks.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Liens',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...externalLinks.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PlatformButton(
                        platform: entry.key,
                        onTap: () =>
                            _launchURL(context, entry.value.toString()),
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 32),

                // Bouton favoris
                if (auth.isAuthenticated && contentId != null)
                  ElevatedButton.icon(
                    onPressed: () => _toggleFavorite(
                        context, contentId, isFavorite, library),
                    icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border),
                    label: Text(isFavorite
                        ? 'Retirer des favoris'
                        : 'Ajouter aux favoris'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isFavorite ? Colors.red : AppColors.primaryBlue,
                      minimumSize: const Size(double.infinity, 52),
                    ),
                  ),

                const SizedBox(height: 32),

                // Bouton nouveau scan
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
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

  Widget _buildTypeBadge(String type) {
    Color color;
    String label;

    switch (type) {
      case 'music':
        color = AppColors.primaryBlue;
        label = '🎵 Musique';
        break;
      case 'movie':
      case 'movie_poster':
        color = Colors.orange;
        label = '🎬 Film';
        break;
      case 'tv_show':
        color = Colors.teal;
        label = '📺 Série';
        break;
      case 'album_cover':
        color = Colors.purple;
        label = '💿 Album';
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
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 80) return Colors.green;
    if (confidence >= 50) return Colors.orange;
    return Colors.red;
  }

  Widget _buildMetadataGrid(Map<String, dynamic> metadata) {
    final entries = metadata.entries
        .where((e) => e.value != null && e.value.toString().isNotEmpty)
        .take(6)
        .toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: entries.map((e) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                e.key,
                style:
                    const TextStyle(color: AppColors.onSurface, fontSize: 11),
              ),
              Text(
                e.value.toString(),
                style: const TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStreamingList(dynamic providers) {
    if (providers == null || providers is! List) return const SizedBox();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: providers.map((p) {
        final name = p['provider'] ?? '';
        final url = p['url'] ?? '';
        return InkWell(
          onTap: () => _launchURL(context as BuildContext, url),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
            ),
            child: Text(
              name,
              style: const TextStyle(
                color: AppColors.onBackground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _toggleFavorite(BuildContext context, int contentId,
      bool isFavorite, LibraryProvider library) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user == null) return;

    final r = scanResult!;
    final content = ContentModel(
      contentId: contentId,
      contentType: r['type'] ?? r['content_type'] ?? 'unknown',
      contentTitle: r['title'] ?? r['content_title'] ?? '',
      contentArtist: r['artist'] ?? r['content_artist'],
      contentImage: r['image'] ?? r['content_image'],
      contentDescription: r['description'] ?? r['content_description'],
      contentReleaseDate: r['year'] ?? r['release_date'],
    );

    if (isFavorite) {
      await library.removeFromFavorites(contentId, auth.user!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Retiré des favoris'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      await library.addToFavorites(content, auth.user!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajouté aux favoris'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    if (url.isEmpty) return;
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d\'ouvrir le lien'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
