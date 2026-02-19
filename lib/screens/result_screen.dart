// lib/screens/result_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../widgets/platform_button.dart';
import '../widgets/social_button.dart';
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, isTablet),

              Expanded(
                child: isTablet
                    ? _buildTabletLayout(context, isFavorite, auth, library)
                    : _buildPhoneLayout(context, isFavorite, auth, library),
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              color: AppColors.textDark,
              size: isTablet ? 28.0 : 22.0,
            ),
          ),
          Expanded(
            child: Text(
              'Résultat',
              style: TextStyle(
                fontSize: isTablet ? 22.0 : 18.0,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.share,
              color: AppColors.textDark,
              size: isTablet ? 28.0 : 24.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneLayout(
    BuildContext context,
    bool isFavorite,
    AuthProvider auth,
    LibraryProvider library,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingScreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCoverImage(context, false),
          const SizedBox(height: 20),
          _buildTitleSection(false),
          const SizedBox(height: 16),
          _buildDescription(false),
          const SizedBox(height: 24),
          if (externalLinks != null) _buildStreamingSection(false),
          const SizedBox(height: 24),
          _buildShareSection(false),
          const SizedBox(height: 24),
          if (auth.isAuthenticated)
            CustomButton(
              text: isFavorite ? 'Retirer des favoris' : 'Sauvegarder',
              onPressed: () => _toggleFavorite(context, isFavorite, library),
              icon: isFavorite ? Icons.favorite : Icons.bookmark_border,
              backgroundColor: isFavorite ? Colors.red : null,
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    bool isFavorite,
    AuthProvider auth,
    LibraryProvider library,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colonne gauche
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCoverImage(context, true),
                    const SizedBox(height: 24),
                    _buildTitleSection(true),
                    const SizedBox(height: 16),
                    _buildDescription(true),
                    const SizedBox(height: 24),
                    if (auth.isAuthenticated)
                      CustomButton(
                        text: isFavorite
                            ? 'Retirer des favoris'
                            : 'Sauvegarder',
                        onPressed: () =>
                            _toggleFavorite(context, isFavorite, library),
                        icon: isFavorite
                            ? Icons.favorite
                            : Icons.bookmark_border,
                        backgroundColor: isFavorite ? Colors.red : null,
                      ),
                    const SizedBox(height: 24),
                    _buildShareSection(true),
                  ],
                ),
              ),

              const SizedBox(width: 32),

              // Colonne droite
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (externalLinks != null) _buildStreamingSection(true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context, bool isTablet) {
    final coverHeight = ResponsiveHelper.resultCoverHeight(context);

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        child: Container(
          width: double.infinity,
          height: coverHeight,
          color: Colors.grey[300],
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
      color: Colors.grey[300],
      child: Icon(
        Icons.music_note,
        size: isTablet ? 110.0 : 80.0,
        color: Colors.grey,
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
            fontSize: isTablet ? 30.0 : 24.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$artist${year.isNotEmpty ? ' - $year' : ''}',
          style: TextStyle(
            fontSize: isTablet ? 20.0 : 16.0,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        if (genre.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            genre,
            style: TextStyle(
              fontSize: isTablet ? 17.0 : 14.0,
              color: Colors.grey[500],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDescription(bool isTablet) {
    if (description.isEmpty) return const SizedBox();

    return Text(
      description,
      style: TextStyle(
        fontSize: isTablet ? 16.0 : 14.0,
        color: Colors.grey[700],
        height: 1.5,
      ),
    );
  }

  Widget _buildStreamingSection(bool isTablet) {
    if (externalLinks == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Streaming',
          style: TextStyle(
            fontSize: isTablet ? 22.0 : 18.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),

        if (externalLinks!['youtube'] != null)
          PlatformButton(
            platform: 'YouTube',
            onTap: () => _openLink(externalLinks!['youtube']),
          ),

        if (externalLinks!['spotify'] != null) ...[
          const SizedBox(height: 10),
          PlatformButton(
            platform: 'Spotify',
            onTap: () => _openLink(externalLinks!['spotify']),
          ),
        ],

        if (externalLinks!['apple_music'] != null) ...[
          const SizedBox(height: 10),
          PlatformButton(
            platform: 'Apple Music',
            onTap: () => _openLink(externalLinks!['apple_music']),
          ),
        ],

        if (externalLinks!['deezer'] != null) ...[
          const SizedBox(height: 10),
          PlatformButton(
            platform: 'Deezer',
            onTap: () => _openLink(externalLinks!['deezer']),
          ),
        ],
      ],
    );
  }

  Widget _buildShareSection(bool isTablet) {
    final socialSize = isTablet ? 64.0 : 52.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Partager',
          style: TextStyle(
            fontSize: isTablet ? 22.0 : 18.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SocialButton(
              platform: 'Facebook',
              onTap: () => _shareContent('facebook'),
              size: socialSize,
            ),
            const SizedBox(width: 12),
            SocialButton(
              platform: 'Twitter',
              onTap: () => _shareContent('twitter'),
              size: socialSize,
            ),
            const SizedBox(width: 12),
            SocialButton(
              platform: 'Instagram',
              onTap: () => _shareContent('instagram'),
              size: socialSize,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    bool isFavorite,
    LibraryProvider library,
  ) async {
    if (contentId == null) return;

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
      await library.removeFromFavorites(
        contentId!,
        context.read<AuthProvider>().user!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Retiré des favoris'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      await library.addToFavorites(content, context.read<AuthProvider>().user!);
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

  ContentType _determineContentType() {
    // Logique pour déterminer le type
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

  void _openLink(String? url) {
    if (url == null) return;
    // TODO: Ouvrir le lien
  }

  void _shareContent(String platform) {
    // TODO: Implémenter le partage
  }
}
