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
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveHelper.maxContentWidth(context),
              ),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildTabs(context),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildContent(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    return Padding(
      padding: EdgeInsets.all(ResponsiveHelper.paddingScreen(context)),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: isTablet ? 28.0 : 22.0,
            ),
          ),
          Expanded(
            child: Text(
              'Mes Favoris',
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: isTablet ? 26.0 : 22.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search,
              color: AppColors.textPrimary,
              size: isTablet ? 30.0 : 24.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.paddingScreen(context),
      ),
      child: Row(
        children: [
          _buildTab('Musiques', 0, isTablet),
          const SizedBox(width: 8),
          _buildTab('Films', 1, isTablet),
          const SizedBox(width: 8),
          _buildTab('Images', 2, isTablet),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, bool isTablet) {
    final isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: isTablet ? 14.0 : 10.0,
          ),
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
              fontSize: isTablet ? 15.0 : 13.0,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (_selectedTab) {
      case 0:
        return _buildFavoritesList(context, _favoritesMusic, Icons.music_note, AppColors.primaryBlue);
      case 1:
        return _buildFavoritesList(context, _favoritesFilms, Icons.movie, const Color(0xFF9B59B6));
      case 2:
        return _buildFavoritesList(context, _favoritesImages, Icons.image, const Color(0xFF2ECC71));
      default:
        return _buildFavoritesList(context, _favoritesMusic, Icons.music_note, AppColors.primaryBlue);
    }
  }

  Widget _buildFavoritesList(
    BuildContext context,
    List<Map<String, dynamic>> items,
    IconData icon,
    Color color,
  ) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final hPadding = ResponsiveHelper.paddingScreen(context);
    final navHeight = ResponsiveHelper.bottomNavHeight(context);

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              color: AppColors.textSecondary,
              size: isTablet ? 80.0 : 60.0,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun favori pour le moment',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontSize: isTablet ? 20.0 : 16.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scannez du contenu et sauvegardez-le !',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary.withOpacity(0.7),
                fontSize: isTablet ? 16.0 : 14.0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(
        left: hPadding,
        right: hPadding,
        bottom: AppSizes.paddingScreen + navHeight + 10,
      ),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildFavoriteItem(context, item, icon, color, isTablet);
      },
    );
  }

  Widget _buildFavoriteItem(
    BuildContext context,
    Map<String, dynamic> item,
    IconData icon,
    Color color,
    bool isTablet,
  ) {
    final thumbSize = isTablet ? 76.0 : 60.0;
    final thumbIconSize = isTablet ? 40.0 : 30.0;

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
            Container(
              width: thumbSize,
              height: thumbSize,
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
                size: thumbIconSize,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 18.0 : 16.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['artist'],
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: isTablet ? 15.0 : 14.0,
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
                            fontSize: isTablet ? 13.0 : 11.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item['year'],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary.withOpacity(0.7),
                          fontSize: isTablet ? 13.0 : 12.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

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
              icon: Icon(
                Icons.favorite,
                color: Colors.red,
                size: isTablet ? 30.0 : 24.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}