import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../widgets/space_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _darkMode = true;
  bool _offlineMode = false;
  bool _autoSave = true;
  String _language = 'Français';
  String _quality = 'Haute';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SpaceBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.paddingScreen),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Compte
                      _buildSectionTitle('Compte'),
                      const SizedBox(height: 12),
                      _buildProfileCard(),

                      const SizedBox(height: 24),

                      // Section Préférences
                      _buildSectionTitle('Préférences'),
                      const SizedBox(height: 12),
                      _buildSwitchItem(
                        icon: Icons.notifications,
                        iconColor: AppColors.primaryBlue,
                        title: 'Notifications',
                        subtitle: 'Recevoir des alertes et mises à jour',
                        value: _notifications,
                        onChanged: (val) => setState(() => _notifications = val),
                      ),
                      const SizedBox(height: 12),
                      _buildSwitchItem(
                        icon: Icons.dark_mode,
                        iconColor: const Color(0xFF9B59B6),
                        title: 'Mode Sombre',
                        subtitle: 'Thème sombre de l\'application',
                        value: _darkMode,
                        onChanged: (val) => setState(() => _darkMode = val),
                      ),
                      const SizedBox(height: 12),
                      _buildSwitchItem(
                        icon: Icons.wifi_off,
                        iconColor: const Color(0xFFE67E22),
                        title: 'Mode Hors-ligne',
                        subtitle: 'Accéder aux données sans internet',
                        value: _offlineMode,
                        onChanged: (val) => setState(() => _offlineMode = val),
                      ),
                      const SizedBox(height: 12),
                      _buildSwitchItem(
                        icon: Icons.bookmark,
                        iconColor: const Color(0xFF2ECC71),
                        title: 'Sauvegarde Auto',
                        subtitle: 'Sauvegarder automatiquement les scans',
                        value: _autoSave,
                        onChanged: (val) => setState(() => _autoSave = val),
                      ),

                      const SizedBox(height: 24),

                      // Section Application
                      _buildSectionTitle('Application'),
                      const SizedBox(height: 12),
                      _buildSelectItem(
                        icon: Icons.language,
                        iconColor: AppColors.primaryBlue,
                        title: 'Langue',
                        value: _language,
                        options: ['Français', 'English', 'Español', 'Deutsch'],
                        onChanged: (val) => setState(() => _language = val!),
                      ),
                      const SizedBox(height: 12),
                      _buildSelectItem(
                        icon: Icons.high_quality,
                        iconColor: const Color(0xFF9B59B6),
                        title: 'Qualité Scan',
                        value: _quality,
                        options: ['Basse', 'Moyenne', 'Haute'],
                        onChanged: (val) => setState(() => _quality = val!),
                      ),
                      const SizedBox(height: 12),
                      _buildNavItem(
                        icon: Icons.storage,
                        iconColor: const Color(0xFFE67E22),
                        title: 'Stockage',
                        subtitle: '245 MB utilisés',
                        onTap: () {},
                      ),

                      const SizedBox(height: 24),

                      // Section Abonnement
                      _buildSectionTitle('Abonnement'),
                      const SizedBox(height: 12),
                      _buildPremiumCard(),

                      const SizedBox(height: 24),

                      // Section Support
                      _buildSectionTitle('Support'),
                      const SizedBox(height: 12),
                      _buildNavItem(
                        icon: Icons.help_outline,
                        iconColor: AppColors.primaryBlue,
                        title: 'Centre d\'aide',
                        subtitle: 'FAQ et guides',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _buildNavItem(
                        icon: Icons.bug_report,
                        iconColor: const Color(0xFFE67E22),
                        title: 'Signaler un problème',
                        subtitle: 'Nous aider à améliorer l\'app',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _buildNavItem(
                        icon: Icons.star_outline,
                        iconColor: Colors.amber,
                        title: 'Noter l\'application',
                        subtitle: 'Donnez votre avis sur le store',
                        onTap: () {},
                      ),

                      const SizedBox(height: 24),

                      // Bouton déconnexion
                      _buildLogoutButton(),

                      const SizedBox(height: 12),

                      // Version
                      Center(
                        child: Text(
                          'Valeon v1.0.0',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
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
              'Paramètres',
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: 16,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBlue,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alex Martin',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'alex@valeon.com',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'Modifier',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
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
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryBlue,
            activeTrackColor: AppColors.primaryBlue.withOpacity(0.4),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          DropdownButton<String>(
            value: value,
            dropdownColor: const Color(0xFF2A2B5E),
            style: AppTextStyles.bodyMedium,
            underline: const SizedBox(),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
            ),
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
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
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Valeon Premium',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Scans illimités, sans pub, IA avancée',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
            child: const Text(
              'Upgrade',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2A2B5E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigation vers login
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Déconnexion'),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: Colors.red.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.red, size: 22),
            const SizedBox(width: 12),
            Text(
              'Se déconnecter',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}