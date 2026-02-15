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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(context, 'Compte'),
                          const SizedBox(height: 12),
                          _buildProfileCard(context),

                          const SizedBox(height: 24),

                          _buildSectionTitle(context, 'Préférences'),
                          const SizedBox(height: 12),
                          _buildSwitchItem(
                            context: context,
                            icon: Icons.notifications,
                            iconColor: AppColors.primaryBlue,
                            title: 'Notifications',
                            subtitle: 'Recevoir des alertes et mises à jour',
                            value: _notifications,
                            onChanged: (val) => setState(() => _notifications = val),
                          ),
                          const SizedBox(height: 12),
                          _buildSwitchItem(
                            context: context,
                            icon: Icons.dark_mode,
                            iconColor: const Color(0xFF9B59B6),
                            title: 'Mode Sombre',
                            subtitle: 'Thème sombre de l\'application',
                            value: _darkMode,
                            onChanged: (val) => setState(() => _darkMode = val),
                          ),
                          const SizedBox(height: 12),
                          _buildSwitchItem(
                            context: context,
                            icon: Icons.wifi_off,
                            iconColor: const Color(0xFFE67E22),
                            title: 'Mode Hors-ligne',
                            subtitle: 'Accéder aux données sans internet',
                            value: _offlineMode,
                            onChanged: (val) => setState(() => _offlineMode = val),
                          ),
                          const SizedBox(height: 12),
                          _buildSwitchItem(
                            context: context,
                            icon: Icons.bookmark,
                            iconColor: const Color(0xFF2ECC71),
                            title: 'Sauvegarde Auto',
                            subtitle: 'Sauvegarder automatiquement les scans',
                            value: _autoSave,
                            onChanged: (val) => setState(() => _autoSave = val),
                          ),

                          const SizedBox(height: 24),

                          _buildSectionTitle(context, 'Application'),
                          const SizedBox(height: 12),
                          _buildSelectItem(
                            context: context,
                            icon: Icons.language,
                            iconColor: AppColors.primaryBlue,
                            title: 'Langue',
                            value: _language,
                            options: ['Français', 'English', 'Español', 'Deutsch'],
                            onChanged: (val) => setState(() => _language = val!),
                          ),
                          const SizedBox(height: 12),
                          _buildSelectItem(
                            context: context,
                            icon: Icons.high_quality,
                            iconColor: const Color(0xFF9B59B6),
                            title: 'Qualité Scan',
                            value: _quality,
                            options: ['Basse', 'Moyenne', 'Haute'],
                            onChanged: (val) => setState(() => _quality = val!),
                          ),
                          const SizedBox(height: 12),
                          _buildNavItem(
                            context: context,
                            icon: Icons.storage,
                            iconColor: const Color(0xFFE67E22),
                            title: 'Stockage',
                            subtitle: '245 MB utilisés',
                            onTap: () {},
                          ),

                          const SizedBox(height: 24),

                          _buildSectionTitle(context, 'Abonnement'),
                          const SizedBox(height: 12),
                          _buildPremiumCard(context),

                          const SizedBox(height: 24),

                          _buildSectionTitle(context, 'Support'),
                          const SizedBox(height: 12),
                          _buildNavItem(
                            context: context,
                            icon: Icons.help_outline,
                            iconColor: AppColors.primaryBlue,
                            title: 'Centre d\'aide',
                            subtitle: 'FAQ et guides',
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),
                          _buildNavItem(
                            context: context,
                            icon: Icons.bug_report,
                            iconColor: const Color(0xFFE67E22),
                            title: 'Signaler un problème',
                            subtitle: 'Nous aider à améliorer l\'app',
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),
                          _buildNavItem(
                            context: context,
                            icon: Icons.star_outline,
                            iconColor: Colors.amber,
                            title: 'Noter l\'application',
                            subtitle: 'Donnez votre avis sur le store',
                            onTap: () {},
                          ),

                          const SizedBox(height: 24),

                          _buildLogoutButton(context),

                          const SizedBox(height: 12),

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
              'Paramètres',
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: isTablet ? 26.0 : 22.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isTablet = ResponsiveHelper.isTablet(context);
    return Text(
      title,
      style: AppTextStyles.titleSmall.copyWith(
        fontSize: isTablet ? 19.0 : 16.0,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final avatarSize = isTablet ? 70.0 : 56.0;
    final avatarIconSize = isTablet ? 38.0 : 30.0;

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
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBlue,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(Icons.person, color: Colors.white, size: avatarIconSize),
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
                    fontSize: isTablet ? 18.0 : 16.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'alex@valeon.com',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: isTablet ? 14.0 : 12.0,
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
                fontSize: isTablet ? 16.0 : 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final iconBoxSize = isTablet ? 52.0 : 42.0;
    final iconSize = isTablet ? 28.0 : 22.0;

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
            width: iconBoxSize,
            height: iconBoxSize,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: iconSize),
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
                    fontSize: isTablet ? 17.0 : 15.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: isTablet ? 14.0 : 12.0,
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
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final iconBoxSize = isTablet ? 52.0 : 42.0;
    final iconSize = isTablet ? 28.0 : 22.0;

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
            width: iconBoxSize,
            height: iconBoxSize,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: iconSize),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: isTablet ? 17.0 : 15.0,
              ),
            ),
          ),
          DropdownButton<String>(
            value: value,
            dropdownColor: const Color(0xFF2A2B5E),
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: isTablet ? 16.0 : 14.0,
            ),
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
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final iconBoxSize = isTablet ? 52.0 : 42.0;
    final iconSize = isTablet ? 28.0 : 22.0;

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
              width: iconBoxSize,
              height: iconBoxSize,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: iconSize),
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
                      fontSize: isTablet ? 17.0 : 15.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: isTablet ? 14.0 : 12.0,
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

  Widget _buildPremiumCard(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    return Container(
      padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
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
          Icon(
            Icons.workspace_premium,
            color: Colors.white,
            size: isTablet ? 50.0 : 40.0,
          ),
          SizedBox(width: isTablet ? 20.0 : 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Valeon Premium',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 20.0 : 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Scans illimités, sans pub, IA avancée',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isTablet ? 14.0 : 12.0,
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
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20.0 : 16.0,
                vertical: isTablet ? 12.0 : 8.0,
              ),
            ),
            child: Text(
              'Upgrade',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 15.0 : 13.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
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
            Icon(Icons.logout, color: Colors.red, size: isTablet ? 28.0 : 22.0),
            const SizedBox(width: 12),
            Text(
              'Se déconnecter',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: isTablet ? 18.0 : 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}