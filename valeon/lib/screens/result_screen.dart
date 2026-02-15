import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/constants.dart';
import '../widgets/platform_button.dart';
import '../widgets/social_button.dart';
import '../widgets/custom_button.dart';

class ResultScreen extends StatelessWidget {
  final String title;
  final String artist;
  final String year;
  final String genre;
  final String description;
  final String imageUrl;

  const ResultScreen({
    Key? key,
    this.title = 'Blinding Lights',
    this.artist = 'The Weeknd',
    this.year = '2019',
    this.genre = 'Synth-pop',
    this.description =
        'Chanson populaire du groupe Glass Animals sortie en 2020, connue pour sa mélodie accrocheuse et son atmosphère nostalgique.',
    this.imageUrl = 'placeholder',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

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
                    ? _buildTabletLayout(context)
                    : _buildPhoneLayout(context),
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
              'Écran Résultat',
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
              Icons.search,
              color: AppColors.textDark,
              size: isTablet ? 28.0 : 24.0,
            ),
          ),
        ],
      ),
    );
  }

  /// Layout téléphone : colonne unique
  Widget _buildPhoneLayout(BuildContext context) {
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
          _buildStreamingSection(false),
          const SizedBox(height: 24),
          _buildShareSection(false),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Sauvegarder',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('✅ Sauvegardé dans vos favoris !'),
                  backgroundColor: AppColors.primaryBlue,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: Icons.bookmark_border,
          ),
          const SizedBox(height: 32),
          _buildSimilarSection(context, false),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Layout tablette : 2 colonnes côte à côte
  Widget _buildTabletLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colonne gauche : cover + infos + sauvegarde
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
                    CustomButton(
                      text: 'Sauvegarder',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('✅ Sauvegardé dans vos favoris !'),
                            backgroundColor: AppColors.primaryBlue,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: Icons.bookmark_border,
                    ),
                    const SizedBox(height: 24),
                    _buildShareSection(true),
                  ],
                ),
              ),

              const SizedBox(width: 32),

              // Colonne droite : streaming + similaires
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStreamingSection(true),
                    const SizedBox(height: 32),
                    _buildSimilarSection(context, true),
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
          child: imageUrl.startsWith('http')
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
          '$artist - ($year)',
          style: TextStyle(
            fontSize: isTablet ? 20.0 : 16.0,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          genre,
          style: TextStyle(
            fontSize: isTablet ? 17.0 : 14.0,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(bool isTablet) {
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
        PlatformButton(platform: 'YouTube', onTap: () {}),
        const SizedBox(height: 10),
        PlatformButton(platform: 'Spotify', onTap: () {}),
        const SizedBox(height: 10),
        PlatformButton(platform: 'Apple Music', onTap: () {}),
        const SizedBox(height: 10),
        PlatformButton(platform: 'Deezer', onTap: () {}),
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
            SocialButton(platform: 'Facebook', onTap: () {}, size: socialSize),
            const SizedBox(width: 12),
            SocialButton(platform: 'Twitter', onTap: () {}, size: socialSize),
            const SizedBox(width: 12),
            SocialButton(platform: 'TikTok', onTap: () {}, size: socialSize),
            const SizedBox(width: 12),
            SocialButton(platform: 'Instagram', onTap: () {}, size: socialSize),
          ],
        ),
      ],
    );
  }

  Widget _buildSimilarSection(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chansons similaires',
          style: TextStyle(
            fontSize: isTablet ? 22.0 : 18.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        _buildSimilarItem(
          context,
          'Sunflower',
          'Post Malone & Swae Lee',
          '2018',
          isTablet,
        ),
        Divider(height: isTablet ? 32.0 : 24.0),
        _buildSimilarItem(
          context,
          'Blinding Lights',
          'The Weeknd',
          'Il y a 1 jour',
          isTablet,
        ),
      ],
    );
  }

  Widget _buildSimilarItem(
    BuildContext context,
    String itemTitle,
    String itemArtist,
    String time,
    bool isTablet,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              title: itemTitle,
              artist: itemArtist,
              year: time,
              genre: genre,
              description: description,
            ),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: isTablet ? 76.0 : 60.0,
            height: isTablet ? 76.0 : 60.0,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.music_note,
              color: Colors.grey,
              size: isTablet ? 40.0 : 30.0,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemTitle,
                  style: TextStyle(
                    fontSize: isTablet ? 18.0 : 16.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  itemArtist,
                  style: TextStyle(
                    fontSize: isTablet ? 16.0 : 14.0,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: isTablet ? 14.0 : 12.0,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$itemTitle ajouté aux favoris'),
                  backgroundColor: AppColors.primaryBlue,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: Icon(
              Icons.add_circle_outline,
              color: AppColors.primaryBlue,
              size: isTablet ? 34.0 : 28.0,
            ),
          ),
        ],
      ),
    );
  }
}