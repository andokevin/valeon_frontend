import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../widgets/space_background.dart';
import 'result_screen.dart';
import 'profile_screen.dart';

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
            border: isSelected ? null : Border.all(
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
                'Rechercher',
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
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: AppSizes.paddingScreen,
        right: AppSizes.paddingScreen,
        bottom: AppSizes.paddingScreen + AppSizes.bottomNavHeight + 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMusicItem(
            'Heat Waves',
            'Glass Animals',
            'Il y a 2 min',
          ),
          const SizedBox(height: 12),
          _buildMusicItem(
            'Sunflower',
            'Post Malone & Swae Lee',
            'Il y a 20 min',
          ),
          const SizedBox(height: 12),
          _buildMusicItem(
            'Blinding Lights',
            'The Weeknd',
            'Il y a 1 jour',
          ),
          
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

  Widget _buildFavoritesSection() {
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
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13,
                    ),
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
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13,
                    ),
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