// lib/screens/profile/settings_screen.dart (CORRIGÉ - version simple)
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/layout/space_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _darkMode = false;
  bool _autoSave = true;
  bool _offlineMode = true;
  String _language = 'Français';
  String _quality = 'Haute';

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final hPadding = ResponsiveHelper.paddingScreen(context);

    return SpaceBackground(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, hPadding, isTablet),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(hPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Préférences', isTablet),
                    const SizedBox(height: 12),
                    _buildSwitchTile(
                      icon: Icons.notifications,
                      iconColor: AppColors.primaryBlue,
                      title: 'Notifications',
                      subtitle: 'Recevoir des alertes',
                      value: _notifications,
                      onChanged: (v) => setState(() => _notifications = v),
                    ),
                    _buildSwitchTile(
                      icon: Icons.dark_mode,
                      iconColor: Colors.purple,
                      title: 'Mode sombre',
                      subtitle: 'Thème sombre de l\'application',
                      value: _darkMode,
                      onChanged: (v) => setState(() => _darkMode = v),
                    ),
                    _buildSwitchTile(
                      icon: Icons.save,
                      iconColor: Colors.green,
                      title: 'Sauvegarde auto',
                      subtitle: 'Sauvegarder automatiquement les scans',
                      value: _autoSave,
                      onChanged: (v) => setState(() => _autoSave = v),
                    ),
                    _buildSwitchTile(
                      icon: Icons.wifi_off,
                      iconColor: Colors.orange,
                      title: 'Mode hors ligne',
                      subtitle: 'Accéder aux données sans internet',
                      value: _offlineMode,
                      onChanged: (v) => setState(() => _offlineMode = v),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Application', isTablet),
                    const SizedBox(height: 12),
                    _buildDropdownTile(
                      icon: Icons.language,
                      iconColor: AppColors.primaryBlue,
                      title: 'Langue',
                      value: _language,
                      items: ['Français', 'English', 'Español', 'Deutsch'],
                      onChanged: (v) => setState(() => _language = v!),
                    ),
                    _buildDropdownTile(
                      icon: Icons.high_quality,
                      iconColor: Colors.purple,
                      title: 'Qualité scan',
                      value: _quality,
                      items: ['Basse', 'Moyenne', 'Haute'],
                      onChanged: (v) => setState(() => _quality = v!),
                    ),
                    _buildNavTile(
                      icon: Icons.storage,
                      iconColor: Colors.orange,
                      title: 'Stockage',
                      subtitle: '245 Mo utilisés',
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('À propos', isTablet),
                    const SizedBox(height: 12),
                    _buildNavTile(
                      icon: Icons.info,
                      iconColor: AppColors.primaryBlue,
                      title: 'Version',
                      subtitle: '2.0.0',
                      onTap: () {},
                    ),
                    _buildNavTile(
                      icon: Icons.description,
                      iconColor: Colors.green,
                      title: 'Conditions d\'utilisation',
                      subtitle: 'Lire les conditions',
                      onTap: () {},
                    ),
                    _buildNavTile(
                      icon: Icons.privacy_tip,
                      iconColor: Colors.purple,
                      title: 'Politique de confidentialité',
                      subtitle: 'Comment nous protégeons vos données',
                      onTap: () {},
                    ),
                    const SizedBox(height: 40),
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
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const Expanded(
            child: Text(
              'Paramètres',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isTablet) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isTablet ? 16 : 14,
        fontWeight: FontWeight.w600,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          DropdownButton<String>(
            value: value,
            dropdownColor: AppColors.surface,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 13),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
