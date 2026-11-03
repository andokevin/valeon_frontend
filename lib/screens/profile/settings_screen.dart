// lib/screens/profile/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_links.dart';
import '../../widgets/layout/space_background.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _clearImageCache(BuildContext context) {
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache des images vidé')),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final hPadding = ResponsiveHelper.paddingScreen(context);

    return SpaceBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Paramètres')),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(hPadding),
            children: [
              _sectionTitle('Apparence'),
              _switchTile(
                icon: Icons.dark_mode,
                iconColor: Colors.indigoAccent,
                title: 'Mode sombre',
                subtitle: theme.isDarkMode ? 'Activé' : 'Désactivé',
                value: theme.isDarkMode,
                onChanged: (_) => theme.toggleTheme(),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Compte'),
              _navTile(
                icon: Icons.person_outline,
                iconColor: AppColors.primaryBlue,
                title: 'Modifier le profil',
                subtitle: 'Nom affiché',
                onTap: () => _push(context, const EditProfileScreen()),
              ),
              _navTile(
                icon: Icons.lock_outline,
                iconColor: Colors.orange,
                title: 'Mot de passe',
                subtitle: 'Changer votre mot de passe',
                onTap: () => _push(context, const ChangePasswordScreen()),
              ),
              _navTile(
                icon: Icons.delete_outline,
                iconColor: Colors.redAccent,
                title: 'Supprimer mon compte',
                subtitle: 'Supprimer le compte et toutes ses données',
                onTap: () => AppLinks.open(context, AppLinks.deleteAccount),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Données'),
              _navTile(
                icon: Icons.cleaning_services_outlined,
                iconColor: Colors.teal,
                title: 'Vider le cache des images',
                subtitle: 'Libère la mémoire utilisée par les pochettes',
                onTap: () => _clearImageCache(context),
              ),
              const SizedBox(height: 24),
              _sectionTitle('À propos'),
              _navTile(
                icon: Icons.info_outline,
                iconColor: AppColors.primaryBlue,
                title: 'Version',
                subtitle: AppLinks.appVersion,
                onTap: () => AppLinks.showAbout(context),
              ),
              _navTile(
                icon: Icons.public,
                iconColor: Colors.green,
                title: 'Site web',
                subtitle: 'Présentation de Valeon',
                onTap: () => AppLinks.open(context, AppLinks.website),
              ),
              _navTile(
                icon: Icons.privacy_tip_outlined,
                iconColor: Colors.purpleAccent,
                title: 'Politique de confidentialité',
                subtitle: 'Comment nous protégeons vos données',
                onTap: () => AppLinks.open(context, AppLinks.privacyPolicy),
              ),
              _navTile(
                icon: Icons.mail_outline,
                iconColor: Colors.amber,
                title: 'Contacter le support',
                subtitle: AppLinks.supportEmail,
                onTap: () => AppLinks.contactSupport(context),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
      );

  BoxDecoration get _tileDecoration => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      );

  Widget _leadingIcon(IconData icon, Color color) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      );

  Widget _texts(String title, String subtitle) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      );

  Widget _switchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: _tileDecoration,
      child: Row(
        children: [
          _leadingIcon(icon, iconColor),
          const SizedBox(width: 12),
          Expanded(child: _texts(title, subtitle)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _navTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: _tileDecoration,
            child: Row(
              children: [
                _leadingIcon(icon, iconColor),
                const SizedBox(width: 12),
                Expanded(child: _texts(title, subtitle)),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white54, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
