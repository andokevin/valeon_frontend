// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valeon/providers/connectivity_provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/layout/space_background.dart';
import 'settings_screen.dart';
import 'premium_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final hPadding = ResponsiveHelper.paddingScreen(context);
    final auth = Provider.of<AuthProvider>(context);
    final connectivity = Provider.of<ConnectivityProvider>(context);

    return SpaceBackground(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, hPadding, isTablet),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(hPadding),
                child: Column(
                  children: [
                    _buildProfileHeader(context, auth, isTablet),
                    const SizedBox(height: 24),
                    _buildStats(context, isTablet),
                    const SizedBox(height: 24),
                    _buildSubscriptionCard(context, auth, isTablet),
                    const SizedBox(height: 24),
                    _buildMenuItems(context, isTablet),
                    const SizedBox(height: 24),
                    _buildLogoutButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double hPadding, bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(hPadding),
      child: Row(
        children: [
          Container(
            width: isTablet ? 52 : 44,
            height: isTablet ? 52 : 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.lightPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          const Text(
            'Profil',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          // IconButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const SettingsScreen()),
          //     );
          //   },
          //   icon: const Icon(Icons.settings, color: Colors.white),
          // ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, AuthProvider auth, bool isTablet) {
    final avatarSize = isTablet ? 100.0 : 80.0;
    final isEmailVerified = auth.firebaseUser?.emailVerified ?? false;

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.lightPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: auth.userImage != null && auth.userImage!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        auth.userImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, color: Colors.white);
                        },
                      ),
                    )
                  : const Icon(Icons.person, color: Colors.white),
            ),
            if (auth.isPremium)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.premium,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.black,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              auth.userName,
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (isEmailVerified) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.verified,
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          auth.userEmail,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context, bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('150', 'Scans', isTablet),
          _buildStatItem('24', 'Favoris', isTablet),
          _buildStatItem('3', 'Playlists', isTablet),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, bool isTablet) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard(
      BuildContext context, AuthProvider auth, bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: auth.isPremium
              ? [AppColors.premium, AppColors.premium.withOpacity(0.7)]
              : [AppColors.primaryBlue, AppColors.lightPurple],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (auth.isPremium ? AppColors.premium : AppColors.primaryBlue)
                .withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            auth.isPremium ? Icons.star : Icons.person,
            color: Colors.white,
            size: isTablet ? 40 : 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.isPremium ? 'Valeon Premium' : 'Plan Free',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.isPremium
                      ? 'Scans illimités, sans pub, IA avancée'
                      : '5 scans/jour, 50 scans/mois',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
          if (!auth.isPremium)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PremiumScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryBlue,
              ),
              child: const Text('Upgrade'),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, bool isTablet) {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.notifications,
          label: 'Notifications',
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          icon: Icons.help,
          label: 'Aide & Support',
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          icon: Icons.privacy_tip,
          label: 'Confidentialité',
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          icon: Icons.info,
          label: 'À propos',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryBlue),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
              'Déconnexion',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Voulez-vous vraiment vous déconnecter ?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Déconnexion'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          await auth.signOut();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 12),
            Text(
              'Se déconnecter',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
