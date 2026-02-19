// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../widgets/space_background.dart';
import '../providers/auth_provider.dart';
import 'settings_screen.dart';
import 'favorites_screen.dart';

class ProfileScreenContent extends StatelessWidget {
  const ProfileScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SpaceBackground(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveHelper.maxContentWidth(context),
                ),
                child: Column(
                  children: [
                    _buildHeader(context),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(
                          ResponsiveHelper.paddingScreen(context),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildProfileHeader(context, authProvider),
                            const SizedBox(height: 24),
                            _buildStats(context),
                            const SizedBox(height: 24),
                            _buildBio(context),
                            const SizedBox(height: 32),
                            _buildTrendingSection(context),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
              'Profil',
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: isTablet ? 26.0 : 22.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: Icon(
              Icons.settings,
              color: AppColors.textPrimary,
              size: isTablet ? 30.0 : 24.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthProvider authProvider) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final avatarSize = isTablet ? 130.0 : 100.0;
    final avatarIconSize = isTablet ? 66.0 : 50.0;

    // ✅ Utilisation correcte des getters
    final userName = authProvider.getUserName;
    final userEmail = authProvider.getUserEmail;
    final photoUrl = authProvider.getUserProfilePicture;
    final isEmailVerified = authProvider.firebaseUser?.emailVerified ?? false;

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBlue,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: (photoUrl != null && photoUrl.isNotEmpty)
                  ? ClipOval(
                      child: Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: avatarIconSize,
                            color: Colors.white,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: avatarIconSize,
                      color: Colors.white,
                    ),
            ),
            if (isEmailVerified)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 6.0 : 4.0),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: isTablet ? 26.0 : 20.0,
                  ),
                ),
              ),
          ],
        ),

        SizedBox(height: isTablet ? 20.0 : 16.0),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              userName,
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: isTablet ? 28.0 : 22.0,
              ),
            ),
            if (isEmailVerified) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.verified,
                color: AppColors.primaryBlue,
                size: isTablet ? 28.0 : 22.0,
              ),
            ],
          ],
        ),

        const SizedBox(height: 4),
        Text(
          userEmail,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: isTablet ? 16.0 : 14.0,
          ),
        ),

        if (!isEmailVerified && authProvider.firebaseUser != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Builder(
              builder: (BuildContext context) {
                return TextButton(
                  onPressed: () async {
                    try {
                      await authProvider.firebaseUser?.sendEmailVerification();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Email de vérification envoyé'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: $e'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    'Vérifier mon email',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 16.0 : 14.0,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildStats(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32.0 : 24.0,
        vertical: isTablet ? 24.0 : 20.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, '150', 'Scans', isTablet),
          _buildDivider(),
          _buildStatItem(context, '500', 'Favoris', isTablet),
          _buildDivider(),
          _buildStatItem(context, '3500', 'Followers', isTablet),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    bool isTablet,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontSize: isTablet ? 28.0 : 22.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: isTablet ? 15.0 : 13.0,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildBio(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        'Passionné de musique et de cinéma 🎬🎵',
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: isTablet ? 18.0 : 15.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTrendingSection(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final cardHeight = isTablet ? 190.0 : 150.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tendances Valeon',
              style: AppTextStyles.titleSmall.copyWith(
                fontSize: isTablet ? 22.0 : 18.0,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                  ),
                );
              },
              child: Text(
                'Voir tout',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryBlue,
                  fontSize: isTablet ? 16.0 : 14.0,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildTrendingCard(
                context,
                'Sipder Vær',
                'Die Indie-Reeves djüet',
                cardHeight,
                isTablet,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTrendingCard(
                context,
                'Space Tunk',
                '',
                cardHeight,
                isTablet,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendingCard(
    BuildContext context,
    String title,
    String subtitle,
    double cardHeight,
    bool isTablet,
  ) {
    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isTablet ? 76.0 : 60.0,
            height: isTablet ? 76.0 : 60.0,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.music_note,
              color: Colors.white,
              size: isTablet ? 40.0 : 30.0,
            ),
          ),
          SizedBox(height: isTablet ? 14.0 : 10.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: isTablet ? 16.0 : 14.0,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (subtitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: isTablet ? 13.0 : 11.0,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
