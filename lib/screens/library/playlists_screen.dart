import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/library_provider.dart';

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  Future<void> _createPlaylist(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Nouvelle playlist', style: TextStyle(color: AppTheme.onBackground)),
        content: TextField(
          controller: nameCtrl,
          style: const TextStyle(color: AppTheme.onBackground),
          decoration: const InputDecoration(hintText: 'Nom de la playlist',
            hintStyle: TextStyle(color: AppTheme.onSurface)),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, nameCtrl.text.trim()),
            child: const Text('Créer'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await ref.read(libraryServiceProvider).createPlaylist(name);
      ref.invalidate(playlistsProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _createPlaylist(context, ref),
          ),
        ],
      ),
      body: playlists.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (ps) => ps.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.playlist_add_rounded, size: 64, color: AppTheme.onSurface),
                const SizedBox(height: 16),
                const Text('Aucune playlist', style: TextStyle(color: AppTheme.onSurface, fontSize: 16)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _createPlaylist(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Créer une playlist'),
                ),
              ]))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: ps.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) => InkWell(
                  onTap: () => context.go('/library/playlists/${ps[i].playlistId}'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface, borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.playlist_play_rounded,
                          color: AppTheme.primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(ps[i].playlistName,
                          style: const TextStyle(fontWeight: FontWeight.w600,
                            color: AppTheme.onBackground)),
                        Text('${ps[i].contentCount} contenus',
                          style: const TextStyle(color: AppTheme.onSurface, fontSize: 13)),
                      ])),
                      const Icon(Icons.chevron_right_rounded, color: AppTheme.onSurface),
                    ]),
                  ),
                ),
              ),
      ),
    );
  }
}
