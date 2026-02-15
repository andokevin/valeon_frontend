import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../widgets/space_background.dart';
import 'result_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _selectedTab = 0;

  // Données simulées des favoris
  final List<Map<String, dynamic>> _favoritesMusic = [
    {
      'title': 'Blinding Lights',
      'artist': 'The Weeknd',
      'year': '2019',
      'genre': 'Synth-pop',
      'description': 'Chanson populaire de The Weeknd sortie en 2019.',
    },
    {
      'title': 'Heat Waves',
      'artist': 'Glass Animals',
      'year': '2020',
      'genre': 'Indie Pop',
      'description': 'Chanson populaire du groupe Glass Animals sortie en 2020.',
    },
    {
      'title': 'Sunflower',
      'artist': 'Post Malone & Swae Lee',
      'year': '2018',
      'genre': 'Hip-hop',
      'description': 'Chanson du film Spider-Man: Into the Spider-Verse.',
    },
  ];

  final List<Map<String, dynamic>> _favoritesFilms = [
    {
      'title': 'Inception',
      'artist': 'Christopher Nolan',
      'year': '2010',
      'genre': 'Science-fiction',
      'description': 'Un voleur qui s\'infiltre dans les rêves.',
    },
    {
      'title': 'Interstellar',
      'artist': 'Christopher Nolan',
      'year': '2014',
      'genre': 'Science-fiction',
      'description': 'Un voyage à travers les étoiles.',
    },
  ];

  final List<Map<String, dynamic>> _favoritesImages = [
    {
      'title': 'La Nuit Étoilée',
      'artist': 'Vincent Van Gogh',
      'year': '1889',
      'genre': 'Post-impressionnisme',
      'description': 'Tableau célèbre de Van Gogh.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SpaceBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),

              const SizedBox(height: 16),

              _buildTabs(),

              const SizedBox(height: 16),

              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingScreen),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
          const Expanded(
            child: Text(
              'Mes Favoris',
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingScreen),
      child: Row(
        children: [
          _buildTab('Musiques', 0),
          const SizedBox(width: 8),
          _buildTab('Films', 1),
          const SizedBox(width: 8),
          _buildTab('Images', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryBlue
                : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? null
                : Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
          ),
          child: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return _buildFavoritesList(_favoritesMusic, Icons.music_note, AppColors.primaryBlue);
      case 1:
        return _buildFavoritesList(_favoritesFilms, Icons.movie, const Color(0xFF9B59B6));
      case 2:
        return _buildFavoritesList(_favoritesImages, Icons.image, const Color(0xFF2ECC71));
      default:
        return _buildFavoritesList(_favoritesMusic, Icons.music_note, AppColors.primaryBlue);
    }
  }

  Widget _buildFavoritesList(
    List<Map<String, dynamic>> items,
    IconData icon,
    Color color,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              color: AppColors.textSecondary,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun favori pour le moment',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scannez du contenu et sauvegardez-le !',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(
        left: AppSizes.paddingScreen,
        right: AppSizes.paddingScreen,
        bottom: AppSizes.paddingScreen + AppSizes.bottomNavHeight + 10,
      ),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildFavoriteItem(item, icon, color);
      },
    );
  }

  Widget _buildFavoriteItem(
    Map<String, dynamic> item,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              title: item['title'],
              artist: item['artist'],
              year: item['year'],
              genre: item['genre'],
              description: item['description'],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            // Miniature
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: color.withOpacity(0.4),
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),

            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['artist'],
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item['genre'],
                          style: AppTextStyles.bodySmall.copyWith(
                            color: color,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item['year'],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bouton supprimer favori
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Retiré des favoris'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(
                Icons.favorite,
                color: Colors.red,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}