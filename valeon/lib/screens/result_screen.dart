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
    // ✅ Intercepter le bouton retour Android
    return WillPopScope(
      onWillPop: () async {
        _navigateBackToHome(context);
        return false; // On gère nous-mêmes la navigation
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.paddingScreen),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCoverImage(),

                      const SizedBox(height: 20),

                      _buildTitleSection(),

                      const SizedBox(height: 16),

                      _buildDescription(),

                      const SizedBox(height: 24),

                      _buildStreamingSection(),

                      const SizedBox(height: 24),

                      _buildShareSection(),

                      const SizedBox(height: 24),

                      CustomButton(
                        text: 'Sauvegarder',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                '✅ Sauvegardé dans vos favoris !',
                              ),
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

                      _buildSimilarSection(context),

                      const SizedBox(height: 20),
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

  // ✅ Navigation propre vers Home
  void _navigateBackToHome(BuildContext context) {
    // Retirer toutes les routes jusqu'au MainNavigation
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget _buildHeader(BuildContext context) {
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
          // ✅ Bouton retour vers Home
          IconButton(
            onPressed: () => _navigateBackToHome(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textDark,
              size: 22,
            ),
          ),
          const Expanded(
            child: Text(
              'Écran Résultat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: AppColors.textDark,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        child: Container(
          width: double.infinity,
          height: 250,
          color: Colors.grey[300],
          child: imageUrl.startsWith('http')
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _placeholderImage();
                  },
                )
              : _placeholderImage(),
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.music_note,
        size: 80,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$artist - ($year)',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          genre,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      description,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[700],
        height: 1.5,
      ),
    );
  }

  Widget _buildStreamingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Streaming',
          style: TextStyle(
            fontSize: 18,
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

  Widget _buildShareSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Partager',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SocialButton(platform: 'Facebook', onTap: () {}),
            const SizedBox(width: 12),
            SocialButton(platform: 'Twitter', onTap: () {}),
            const SizedBox(width: 12),
            SocialButton(platform: 'TikTok', onTap: () {}),
            const SizedBox(width: 12),
            SocialButton(platform: 'Instagram', onTap: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildSimilarSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chansons similaires',
          style: TextStyle(
            fontSize: 18,
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
        ),
        const Divider(height: 24),
        _buildSimilarItem(
          context,
          'Blinding Lights',
          'The Weeknd',
          'Il y a 1 jour',
        ),
      ],
    );
  }

  Widget _buildSimilarItem(
    BuildContext context,
    String title,
    String artist,
    String time,
  ) {
    return GestureDetector(
      onTap: () {
        // ✅ Naviguer vers un nouveau ResultScreen
        // sans empiler trop de routes
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              title: title,
              artist: artist,
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.music_note,
              color: Colors.grey,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  artist,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
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
                  content: Text('$title ajouté aux favoris'),
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
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}