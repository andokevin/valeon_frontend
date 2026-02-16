import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../widgets/space_background.dart';
import 'result_screen.dart';
import 'favorites_screen.dart';

class LibraryScreenContent extends StatefulWidget {
  const LibraryScreenContent({super.key});

  @override
  State<LibraryScreenContent> createState() => _LibraryScreenContentState();
}

class _LibraryScreenContentState extends State<LibraryScreenContent> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return SpaceBackground(
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.maxContentWidth(context),
            ),
            child: Column(
              children: [
                _buildHeader(context),
                _buildTabs(context),
                const SizedBox(height: 16),
                _buildSearchBar(context),
                const SizedBox(height: 16),
                Expanded(child: _buildContent(context)),
              ],
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
              'Écran Bibliothèque',
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
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.paddingScreen(context),
      ),
      child: Row(
        children: [
          _buildTab('Musiques', 0, context),
          const SizedBox(width: 8),
          _buildTab('Films/Vidéos', 1, context),
          const SizedBox(width: 8),
          _buildTab('Photos', 2, context),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index, BuildContext context) {
    final isSelected = _selectedTab == index;
    final isTablet = ResponsiveHelper.isTablet(context);

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
                : Border.all(color: Colors.white.withOpacity(0.3), width: 1),
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

  Widget _buildSearchBar(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.paddingScreen(context),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isTablet ? 16.0 : 12.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: isTablet ? 24.0 : 20.0,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Reccher',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: isTablet ? 16.0 : 14.0,
                ),
              ),
            ),
            Text(
              '⌘C',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: isTablet ? 13.0 : 11.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (_selectedTab) {
      case 0:
        return _buildMusicContent(context);
      case 1:
        return _buildFilmsContent(context);
      case 2:
        return _buildPhotosContent(context);
      default:
        return _buildMusicContent(context);
    }
  }

  Widget _buildMusicContent(BuildContext context) {
    final hPadding = ResponsiveHelper.paddingScreen(context);
    final navHeight = ResponsiveHelper.bottomNavHeight(context);

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: hPadding,
        right: hPadding,
        bottom: AppSizes.paddingScreen + navHeight + 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMusicItem(
            context,
            'Heat Waves',
            'Glass Animals',
            'Il y a 2 min',
          ),
          const SizedBox(height: 12),
          _buildMusicItem(
            context,
            'Sunflower',
            'Post Malone & Swae Lee',
            'Il y a 20 min',
          ),
          const SizedBox(height: 12),
          _buildMusicItem(
            context,
            'Blinding Lights',
            'The Weeknd',
            'Il y a 1 jour',
          ),
          const SizedBox(height: 12),
          _buildMusicItem(
            context,
            'Another Love',
            'Tom Odell',
            'Il y a 2 jours',
          ),
          const SizedBox(height: 12),
          _buildMusicItem(context, 'Lose Yourself', 'Eminem', 'Il y a 3 jours'),

          const SizedBox(height: 32),
          _buildPlaylistsSection(context),
          const SizedBox(height: 24),
          _buildFavoritesSection(context),
          const SizedBox(height: 24),
          _buildProfileSection(context),
        ],
      ),
    );
  }

  Widget _buildFilmsContent(BuildContext context) {
    final hPadding = ResponsiveHelper.paddingScreen(context);
    final navHeight = ResponsiveHelper.bottomNavHeight(context);

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: hPadding,
        right: hPadding,
        bottom: AppSizes.paddingScreen + navHeight + 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilmItem(
            context,
            'Inception',
            'Christopher Nolan',
            '2010 - Science-fiction',
            'Il y a 2 min',
          ),
          const SizedBox(height: 12),
          _buildFilmItem(
            context,
            'Interstellar',
            'Christopher Nolan',
            '2014 - Science-fiction',
            'Il y a 1 heure',
          ),
          const SizedBox(height: 12),
          _buildFilmItem(
            context,
            'The Dark Knight',
            'Christopher Nolan',
            '2008 - Action',
            'Il y a 2 jours',
          ),
          const SizedBox(height: 12),
          _buildFilmItem(
            context,
            'Avengers: Endgame',
            'Russo Brothers',
            '2019 - Action',
            'Il y a 3 jours',
          ),
          const SizedBox(height: 12),
          _buildFilmItem(
            context,
            'The Matrix',
            'Wachowski',
            '1999 - Science-fiction',
            'Il y a 1 semaine',
          ),

          const SizedBox(height: 32),
          _buildFavoritesSection(context),
          const SizedBox(height: 24),
          _buildProfileSection(context),
        ],
      ),
    );
  }

  Widget _buildPhotosContent(BuildContext context) {
    final hPadding = ResponsiveHelper.paddingScreen(context);
    final navHeight = ResponsiveHelper.bottomNavHeight(context);
    final columns = ResponsiveHelper.photoGridColumns(context);

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: hPadding,
        right: hPadding,
        bottom: AppSizes.paddingScreen + navHeight + 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return _buildPhotoCard(context, index);
            },
          ),

          const SizedBox(height: 32),
          _buildFavoritesSection(context),
          const SizedBox(height: 24),
          _buildProfileSection(context),
        ],
      ),
    );
  }

  Widget _buildMusicItem(
    BuildContext context,
    String title,
    String artist,
    String time,
  ) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final thumbSize = isTablet ? 76.0 : 60.0;
    final thumbIconSize = isTablet ? 38.0 : 30.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(title: title, artist: artist),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: thumbSize,
              height: thumbSize,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.music_note,
                color: Colors.white,
                size: thumbIconSize,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 18.0 : 16.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    artist,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: isTablet ? 15.0 : 14.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontSize: isTablet ? 13.0 : 12.0,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.favorite_border,
                color: AppColors.primaryBlue,
                size: isTablet ? 28.0 : 22.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilmItem(
    BuildContext context,
    String title,
    String director,
    String details,
    String time,
  ) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final thumbSize = isTablet ? 76.0 : 60.0;
    final thumbIconSize = isTablet ? 38.0 : 30.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ResultScreen(title: title, artist: director, genre: details),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: thumbSize,
              height: thumbSize,
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.movie,
                color: Colors.white,
                size: thumbIconSize,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 18.0 : 16.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    director,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: isTablet ? 15.0 : 14.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    details,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontSize: isTablet ? 13.0 : 12.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary.withOpacity(0.5),
                      fontSize: isTablet ? 12.0 : 11.0,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.favorite_border,
                color: AppColors.primaryBlue,
                size: isTablet ? 28.0 : 22.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(BuildContext context, int index) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final List<Map<String, String>> photos = [
      {'title': 'Vincent Van Gogh', 'subtitle': 'La Nuit Étoilée - 1889'},
      {'title': 'Tour Eiffel', 'subtitle': 'Paris, France'},
      {'title': 'Paysage Montagne', 'subtitle': 'Alpes, 2024'},
      {'title': 'Portrait Inconnu', 'subtitle': 'Analysé il y a 1j'},
      {'title': 'Tableau Moderne', 'subtitle': 'Art Contemporain'},
      {'title': 'Architecture', 'subtitle': 'Bâtiment Identifié'},
    ];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              title: photos[index]['title']!,
              artist: photos[index]['subtitle']!,
              genre: 'Image',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusMedium),
                ),
                child: Container(
                  width: double.infinity,
                  color: AppColors.primaryBlue.withOpacity(0.2),
                  child: Icon(
                    Icons.image,
                    color: Colors.white54,
                    size: isTablet ? 70.0 : 50.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photos[index]['title']!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 15.0 : 13.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    photos[index]['subtitle']!,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: isTablet ? 13.0 : 11.0,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistsSection(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Playlists',
          style: AppTextStyles.titleSmall.copyWith(
            fontSize: isTablet ? 22.0 : 18.0,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Center(
            child: Text(
              'Aucune playlist pour le moment',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: isTablet ? 16.0 : 14.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesSection(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final thumbSize = isTablet ? 62.0 : 50.0;
    final thumbIconSize = isTablet ? 30.0 : 26.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FavoritesScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: thumbSize,
              height: thumbSize,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.favorite,
                color: AppColors.primaryBlue,
                size: thumbIconSize,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Favoris',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 18.0 : 16.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '3 éléments',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: isTablet ? 14.0 : 13.0,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textPrimary,
              size: isTablet ? 20.0 : 16.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final thumbSize = isTablet ? 62.0 : 50.0;
    final thumbIconSize = isTablet ? 30.0 : 26.0;

    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: thumbSize,
              height: thumbSize,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person,
                color: AppColors.primaryBlue,
                size: thumbIconSize,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profil',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 18.0 : 16.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Voir mon profil',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: isTablet ? 14.0 : 13.0,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textPrimary,
              size: isTablet ? 20.0 : 16.0,
            ),
          ],
        ),
      ),
    );
  }
}
