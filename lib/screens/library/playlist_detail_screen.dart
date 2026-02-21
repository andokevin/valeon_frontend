import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/library_provider.dart';
import '../../widgets/library/content_list_tile.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  final int playlistId;
  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistAsync = ref.watch(
      FutureProvider.autoDispose((r) => r.watch(libraryServiceProvider).getPlaylist(playlistId))
    );

    return Scaffold(
      body: playlistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (playlist) => CustomScrollView(slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(playlist.playlistName,
                style: const TextStyle(fontWeight: FontWeight.w700)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.playlist_play_rounded, size: 64, color: Colors.white24),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: playlist.contents.isEmpty
                ? const SliverFillRemaining(child: Center(
                    child: Text('Playlist vide', style: TextStyle(color: AppTheme.onSurface))))
                : SliverList(delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ContentListTile(
                        imageUrl: playlist.contents[i].contentImage,
                        title: playlist.contents[i].contentTitle,
                        subtitle: playlist.contents[i].contentArtist ?? '',
                        type: playlist.contents[i].contentType,
                      ),
                    ),
                    childCount: playlist.contents.length,
                  )),
          ),
        ]),
      ),
    );
  }
}
