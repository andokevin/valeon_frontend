import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../widgets/space_background.dart';
import '../providers/auth_provider.dart';

class ProfileScreenContent extends StatelessWidget {
  const ProfileScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SpaceBackground(
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, authProvider),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.paddingScreen),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        _buildProfileHeader(authProvider),

                        const SizedBox(height: 24),

                        _buildStats(),

                        const SizedBox(height: 24),

                        _buildBio(),

                        const SizedBox(height: 32),

                        _buildTrendingSection(),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider authProvider) {
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
              'Profil',
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.textPrimary,
              size: 24,
            ),
            onSelected: (value) async {
              if (value == 'logout') {
                _showLogoutDialog(context, authProvider);
              } else if (value == 'settings') {
                // Navigation vers paramètres
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Paramètres (bientôt disponible)'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Paramètres'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Déconnexion', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Voulez-vous vraiment vous déconnecter ?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.signOut();
            },
            child: const Text(
              'Se déconnecter',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(AuthProvider authProvider) {
    final userName = authProvider.getUserName() ?? 'Alex Martin';
    final userEmail = authProvider.getUserEmail();
    final photoUrl = authProvider.getPhotoUrl();
    final isEmailVerified = authProvider.user?.emailVerified ?? false;

    return Column(
      children: [
        Stack(
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
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
              child: photoUrl != null
                  ? ClipOval(
                      child: Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          );
                        },
                      ),
                    )
                  : const Icon(Icons.person, size: 50, color: Colors.white),
            ),

            // Badge de vérification
            if (isEmailVerified)
              const Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check, size: 16, color: Colors.white),
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Nom et badge
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(userName, style: AppTextStyles.titleMedium),
            if (isEmailVerified) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.verified,
                color: AppColors.primaryBlue,
                size: 22,
              ),
            ],
          ],
        ),

        // Email
        if (userEmail != null) ...[
          const SizedBox(height: 4),
          Text(userEmail, style: AppTextStyles.bodySmall),
        ],

        // Bouton de vérification d'email - CORRIGÉ !
        if (!isEmailVerified && authProvider.user != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Builder(
              builder: (BuildContext context) {
                return TextButton(
                  onPressed: () async {
                    await authProvider.user?.sendEmailVerification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email de vérification envoyé'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Vérifier mon email',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('150', 'Scans'),
          _buildDivider(),
          _buildStatItem('500', 'Favoris'),
          _buildDivider(),
          _buildStatItem('3500', 'Followers'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.titleMedium.copyWith(fontSize: 22)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 13)),
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

  Widget _buildBio() {
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
        style: AppTextStyles.bodyMedium.copyWith(fontSize: 15),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTrendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tendances Valeon', style: AppTextStyles.titleSmall),
            TextButton(
              onPressed: () {},
              child: Text(
                'Voir tout',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildTrendingCard('Sipder Vær', 'Die Indie-Reeves djüet'),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildTrendingCard('Space Tunk', '')),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendingCard(String title, String subtitle) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.music_note, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
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
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
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
