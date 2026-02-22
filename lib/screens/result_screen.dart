// lib/screens/result_screen.dart (CORRIGÉ)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/constants.dart';
import '../widgets/platform_button.dart';
import '../widgets/custom_button.dart';
import '../providers/auth_provider.dart';
import '../providers/library_provider.dart';
import '../models/content_model.dart';

class ResultScreen extends StatelessWidget {
  final String title;
  final String artist;
  final String year;
  final String genre;
  final String description;
  final String imageUrl;
  final String? contentId;
  final Map<String, dynamic>? externalLinks;
  final Map<String, dynamic>? streaming;
  final Map<String, dynamic>? youtube;

  const ResultScreen({
    super.key,
    required this.title,
    required this.artist,
    this.year = '',
    this.genre = '',
    this.description = '',
    this.imageUrl = '',
    this.contentId,
    this.externalLinks,
    this.streaming,
    this.youtube,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final auth = Provider.of<AuthProvider>(context);
    final library = Provider.of<LibraryProvider>(context);

    final isFavorite = contentId != null && library.isFavorite(contentId!);

    return WillPopScope(
      onWillPop: () async {
        _navigateBackToHome(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1B3D),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, isTablet),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cover image
                      _buildCoverImage(context, isTablet),

                      const SizedBox(height: 24),

                      // Titre et artiste
                      _buildTitleSection(isTablet),

                      const SizedBox(height: 16),

                      // Description
                      if (description.isNotEmpty) ...[
                        _buildDescription(isTablet),
                        const SizedBox(height: 24),
                      ],

                      // Liens YouTube
                      if (youtube != null) ...[
                        _buildYouTubeSection(context, isTablet),
                        const SizedBox(height: 20),
                      ],

                      // Plateformes de streaming
                      if (streaming != null && streaming!.isNotEmpty) ...[
                        _buildStreamingSection(context, isTablet),
                        const SizedBox(height: 24),
                      ],

                      // Liens externes génériques
                      if (externalLinks != null &&
                          externalLinks!.isNotEmpty) ...[
                        _buildExternalLinksSection(context, isTablet),
                        const SizedBox(height: 24),
                      ],

                      // Chansons similaires
                      _buildSimilarSection(context, isTablet),

                      const SizedBox(height: 24),

                      // Bouton favoris
                      if (auth.isAuthenticated && contentId != null)
                        CustomButton(
                          text: isFavorite
                              ? 'Retirer des favoris'
                              : 'Ajouter à la bibliothèque',
                          onPressed: () =>
                              _toggleFavorite(context, isFavorite, library),
                          icon: isFavorite ? Icons.favorite : Icons.bookmark,
                          backgroundColor: isFavorite ? Colors.red : null,
                        ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateBackToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget _buildHeader(BuildContext context, bool isTablet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2B5E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _navigateBackToHome(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: isTablet ? 28.0 : 22.0,
            ),
          ),
          Expanded(
            child: Text(
              'Résultat',
              style: TextStyle(
                fontSize: isTablet ? 24.0 : 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () => _shareContent(context),
            icon: Icon(
              Icons.share,
              color: Colors.white,
              size: isTablet ? 28.0 : 24.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context, bool isTablet) {
    final coverHeight = ResponsiveHelper.resultCoverHeight(context);

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          height: coverHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryBlue.withOpacity(0.3),
                const Color(0xFF9B59B6).withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _placeholderImage(isTablet);
                  },
                )
              : _placeholderImage(isTablet),
        ),
      ),
    );
  }

  Widget _placeholderImage(bool isTablet) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Icon(
          Icons.music_note,
          size: isTablet ? 120.0 : 80.0,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildTitleSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 32.0 : 28.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          artist,
          style: TextStyle(
            fontSize: isTablet ? 20.0 : 18.0,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        if (year.isNotEmpty || genre.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              if (year.isNotEmpty)
                Text(
                  year,
                  style: TextStyle(
                    fontSize: isTablet ? 16.0 : 14.0,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              if (year.isNotEmpty && genre.isNotEmpty)
                const Text(' • ', style: TextStyle(color: Colors.white54)),
              if (genre.isNotEmpty)
                Text(
                  genre,
                  style: TextStyle(
                    fontSize: isTablet ? 16.0 : 14.0,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDescription(bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        description,
        style: TextStyle(
          fontSize: isTablet ? 16.0 : 14.0,
          color: Colors.white.withOpacity(0.9),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildYouTubeSection(BuildContext context, bool isTablet) {
    if (youtube == null) return const SizedBox();

    final videoId = youtube!['video_id'] ?? youtube!['id'];
    final url = youtube!['url'] ?? 'https://www.youtube.com/watch?v=$videoId';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Regarder sur YouTube',
          style: TextStyle(
            fontSize: isTablet ? 20.0 : 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        PlatformButton(
          platform: 'YouTube',
          onTap: () => _launchURL(context, url),
        ),
      ],
    );
  }

  Widget _buildStreamingSection(BuildContext context, bool isTablet) {
    List<Widget> buttons = [];

    if (streaming != null) {
      if (streaming!['spotify'] != null) {
        buttons.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PlatformButton(
              platform: 'Spotify',
              onTap: () => _launchURL(context, streaming!['spotify']),
            ),
          ),
        );
      }
      if (streaming!['apple_music'] != null) {
        buttons.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PlatformButton(
              platform: 'Apple Music',
              onTap: () => _launchURL(context, streaming!['apple_music']),
            ),
          ),
        );
      }
      if (streaming!['deezer'] != null) {
        buttons.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PlatformButton(
              platform: 'Deezer',
              onTap: () => _launchURL(context, streaming!['deezer']),
            ),
          ),
        );
      }
    }

    if (buttons.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Écouter sur',
          style: TextStyle(
            fontSize: isTablet ? 20.0 : 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...buttons,
      ],
    );
  }

  Widget _buildExternalLinksSection(BuildContext context, bool isTablet) {
    List<Widget> buttons = [];

    if (externalLinks != null) {
      externalLinks!.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          buttons.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PlatformButton(
                platform: key,
                onTap: () => _launchURL(context, value.toString()),
              ),
            ),
          );
        }
      });
    }

    if (buttons.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Liens',
          style: TextStyle(
            fontSize: isTablet ? 20.0 : 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...buttons,
      ],
    );
  }

  Widget _buildSimilarSection(BuildContext context, bool isTablet) {
    // Données mock pour les chansons similaires
    final similarItems = [
      {
        'title': 'Sunflower',
        'artist': 'Post Malone & Swae Lee',
        'year': '2018'
      },
      {'title': 'Blinding Lights', 'artist': 'The Weeknd', 'year': '2019'},
      {'title': 'Heat Waves', 'artist': 'Glass Animals', 'year': '2020'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chansons similaires',
          style: TextStyle(
            fontSize: isTablet ? 20.0 : 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...similarItems
            .map((item) => _buildSimilarItem(context, item, isTablet)),
      ],
    );
  }

  Widget _buildSimilarItem(
      BuildContext context, Map<String, String> item, bool isTablet) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              title: item['title']!,
              artist: item['artist']!,
              year: item['year']!,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.music_note,
              color: AppColors.primaryBlue,
              size: isTablet ? 30.0 : 24.0,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title']!,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 16.0 : 14.0,
                    ),
                  ),
                  Text(
                    item['artist']!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: isTablet ? 14.0 : 12.0,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              item['year']!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: isTablet ? 14.0 : 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    bool isFavorite,
    LibraryProvider library,
  ) async {
    if (contentId == null) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user == null) return;

    final content = ContentModel(
      id: contentId!,
      title: title,
      artist: artist,
      year: year,
      genre: genre,
      description: description,
      imageUrl: imageUrl,
      type: _determineContentType(),
      scannedAt: DateTime.now(),
    );

    if (isFavorite) {
      await library.removeFromFavorites(contentId!, auth.user!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Retiré de la bibliothèque'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      await library.addToFavorites(content, auth.user!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajouté à la bibliothèque'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  ContentType _determineContentType() {
    if (genre.toLowerCase().contains('film') ||
        genre.toLowerCase().contains('movie')) {
      return ContentType.film;
    } else if (genre.toLowerCase().contains('image') ||
        genre.toLowerCase().contains('photo')) {
      return ContentType.image;
    } else {
      return ContentType.music;
    }
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Impossible d\'ouvrir $url';
      }
    } catch (e) {
      debugPrint('Erreur ouverture URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d\'ouvrir le lien'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareContent(BuildContext context) {
    // TODO: Implémenter le partage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Partage - Fonctionnalité à venir'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
