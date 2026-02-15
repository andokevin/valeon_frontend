import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../widgets/space_background.dart';
import 'result_screen.dart';
import 'favorites_screen.dart'; // ✅ AJOUTÉ

class LibraryScreenContent extends StatefulWidget {
  const LibraryScreenContent({Key? key}) : super(key: key);

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
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: _buildContent(),
            ),
          ],
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
              'Écran Bibliothèque',
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
          _buildTab('Films/Vidéos', 1),
          const SizedBox(width: 8),
          _buildTab('Photos', 2),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingScreen),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Reccher',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Text(
              '⌘C',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return _buildMusicContent();
      case 1:
        return _buildFilmsContent();
      case 2:
        return _buildPhotosContent();
      default:
        return _buildMusicContent();
    }
  }

  // ✅ TAB MUSIQUES
  Widget _buildMusicContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: AppSizes.paddingScreen,
        right: AppSizes.paddingScreen,
        bottom: AppSizes.paddingScreen + AppSizes.bottomNavHeight + 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMusicItem('Heat Waves', 'Glass Animals', 'Il y a 2 min'),
          const SizedBox(height: 12),
          _buildMusicItem('Sunflower', 'Post Malone & Swae Lee', 'Il y a 20 min'),
          const SizedBox(height: 12),
          _buildMusicItem('Blinding Lights', 'The Weeknd', 'Il y a 1 jour'),
          const SizedBox(height: 12),
          _buildMusicItem('Another Love', 'Tom Odell', 'Il y a 2 jours'),
          const SizedBox(height: 12),
          _buildMusicItem('Lose Yourself', 'Eminem', 'Il y a 3 jours'),

          const SizedBox(height: 32),

          _buildPlaylistsSection(),

          const SizedBox(height: 24),

          _buildFavoritesSection(),

          const SizedBox(height: 24),

          _buildProfileSection(),
        ],
      ),
    );
  }

  // ✅ TAB FILMS/VIDÉOS
  Widget _buildFilmsContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: AppSizes.paddingScreen,
        right: AppSizes.paddingScreen,
        bottom: AppSizes.paddingScreen + AppSizes.bottomNavHeight + 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilmItem(
            'Inception',
            'Christopher Nolan',
            '2010 - Science-fiction',
            'Il y a 2 min',
          ),
          const SizedBox(height: 12),
          _buildFilmItem(
            'Interstellar',
            'Christopher Nolan',
            '2014 - Science-fiction',
            'Il y a 1 heure',
          ),
          const SizedBox(height: 12),
          _buildFilmItem(
            'The Dark Knight',
            'Christopher Nolan',
            '2008 - Action',
            'Il y a 2 jours',
          ),
          const SizedBox(height: 12),
          _buildFilmItem(
            'Avengers: Endgame',
            'Russo Brothers',
            '2019 - Action',
            'Il y a 3 jours',
          ),
          const SizedBox(height: 12),
          _buildFilmItem(
            'The Matrix',
            'Wachowski',
            '1999 - Science-fiction',
            'Il y a 1 semaine',
          ),

          const SizedBox(height: 32),

          _buildFavoritesSection(),

          const SizedBox(height: 24),

          _buildProfileSection(),
        ],
      ),
    );
  }

  // ✅ TAB PHOTOS
  Widget _buildPhotosContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: AppSizes.paddingScreen,
        right: AppSizes.paddingScreen,
        bottom: AppSizes.paddingScreen + AppSizes.bottomNavHeight + 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return _buildPhotoCard(index);
            },
          ),

          const SizedBox(height: 32),

          _buildFavoritesSection(),

          const SizedBox(height: 24),

          _buildProfileSection(),
        ],
      ),
    );
  }

  Widget _buildMusicItem(String title, String artist, String time) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              title: title,
              artist: artist,
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
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.music_note,
                color: Colors.white,
                size: 30,
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
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    artist,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.favorite_border,
                color: AppColors.primaryBlue,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilmItem(
      String title, String director, String details, String time) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              title: title,
              artist: director,
              genre: details,
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
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.movie,
                color: Colors.white,
                size: 30,
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
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    director,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    details,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.favorite_border,
                color: AppColors.primaryBlue,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(int index) {
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
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
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
                  child: const Icon(
                    Icons.image,
                    color: Colors.white54,
                    size: 50,
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
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    photos[index]['subtitle']!,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
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

  Widget _buildPlaylistsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Playlists',
          style: AppTextStyles.titleSmall.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          child: Center(
            child: Text(
              'Aucune playlist pour le moment',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ✅ FAVORIS AVEC NAVIGATION
  Widget _buildFavoritesSection() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FavoritesScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.favorite,
                color: AppColors.primaryBlue,
                size: 26,
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
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '3 éléments',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textPrimary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.primaryBlue,
                size: 26,
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
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Voir mon profil',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textPrimary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}