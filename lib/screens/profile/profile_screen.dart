import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Avatar
          Center(
            child: Stack(children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppTheme.primary.withOpacity(0.15),
                child: Text(
                  user?.userFullName.isNotEmpty == true
                      ? user!.userFullName[0].toUpperCase() : 'V',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700,
                    color: AppTheme.primary),
                ),
              ),
              if (user?.isPremium == true)
                Positioned(bottom: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.premium, shape: BoxShape.circle),
                    child: const Icon(Icons.star_rounded, color: Colors.black, size: 14),
                  )),
            ]),
          ),
          const SizedBox(height: 16),
          Center(child: Text(user?.userFullName ?? '',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
              color: AppTheme.onBackground))),
          Center(child: Text(user?.userEmail ?? '',
            style: const TextStyle(color: AppTheme.onSurface))),
          const SizedBox(height: 8),
          Center(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: (user?.isPremium == true ? AppTheme.premium : AppTheme.primary).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user?.isPremium == true ? '⭐ Premium' : '${user?.subscription ?? 'Free'}',
              style: TextStyle(
                color: user?.isPremium == true ? AppTheme.premium : AppTheme.primary,
                fontWeight: FontWeight.w600),
            ),
          )),
          const SizedBox(height: 32),
          if (user?.isPremium != true) ...[
            ElevatedButton.icon(
              onPressed: () => context.go('/premium'),
              icon: const Icon(Icons.star_rounded, color: Colors.black),
              label: const Text('Passer à Premium',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.premium,
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
            const SizedBox(height: 16),
          ],
          _SettingsTile(
            icon: Icons.library_music_rounded,
            label: 'Ma bibliothèque',
            onTap: () => context.go('/library'),
          ),
          _SettingsTile(
            icon: Icons.notifications_rounded,
            label: 'Notifications',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            label: 'Aide & Support',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_rounded,
            label: 'Confidentialité',
            onTap: () {},
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
            label: const Text('Se déconnecter',
              style: TextStyle(color: AppTheme.error)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.error),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: Icon(icon, color: AppTheme.primary),
    title: Text(label, style: const TextStyle(color: AppTheme.onBackground)),
    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.onSurface),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}
