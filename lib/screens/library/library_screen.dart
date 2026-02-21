import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/library_provider.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bibliothèque')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          stats.when(
            data: (s) => Row(children: [
              _StatCard(icon: Icons.qr_code_scanner_rounded, label: 'Scans',
                value: s['total_scans']?.toString() ?? '0', color: AppTheme.primary),
              const SizedBox(width: 12),
              _StatCard(icon: Icons.favorite_rounded, label: 'Favoris',
                value: s['total_favorites']?.toString() ?? '0', color: AppTheme.error),
              const SizedBox(width: 12),
              _StatCard(icon: Icons.playlist_play_rounded, label: 'Playlists',
                value: s['total_playlists']?.toString() ?? '0', color: AppTheme.secondary),
            ]),
            loading: () => const SizedBox(height: 80,
              child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 32),
          const Text('Ma collection',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
              color: AppTheme.onBackground)),
          const SizedBox(height: 16),
          _LibraryItem(
            icon: Icons.favorite_rounded,
            color: AppTheme.error,
            title: 'Mes favoris',
            subtitle: 'Contenus sauvegardés',
            onTap: () => context.go('/library/favorites'),
          ),
          const SizedBox(height: 12),
          _LibraryItem(
            icon: Icons.history_rounded,
            color: AppTheme.primary,
            title: 'Historique',
            subtitle: 'Scans récents',
            onTap: () => context.go('/library/history'),
          ),
          const SizedBox(height: 12),
          _LibraryItem(
            icon: Icons.playlist_play_rounded,
            color: AppTheme.secondary,
            title: 'Playlists',
            subtitle: 'Mes collections',
            onTap: () => context.go('/library/playlists'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label,
    required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: const TextStyle(color: AppTheme.onSurface, fontSize: 12)),
      ]),
    ),
  );
}

class _LibraryItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _LibraryItem({required this.icon, required this.color,
    required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600,
            color: AppTheme.onBackground)),
          Text(subtitle, style: const TextStyle(color: AppTheme.onSurface, fontSize: 13)),
        ])),
        const Icon(Icons.chevron_right_rounded, color: AppTheme.onSurface),
      ]),
    ),
  );
}
