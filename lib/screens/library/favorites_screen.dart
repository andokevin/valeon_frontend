import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/library_provider.dart';
import '../../widgets/library/content_list_tile.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Favoris')),
      body: favorites.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e',
          style: const TextStyle(color: AppTheme.error))),
        data: (favs) => favs.isEmpty
            ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.favorite_border_rounded, size: 64, color: AppTheme.onSurface),
                SizedBox(height: 16),
                Text('Aucun favori', style: TextStyle(color: AppTheme.onSurface, fontSize: 16)),
                Text('Scannez du contenu pour l\'ajouter ici',
                  style: TextStyle(color: AppTheme.onSurface, fontSize: 13)),
              ]))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: favs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) => ContentListTile(
                  imageUrl: favs[i].contentImage,
                  title: favs[i].contentTitle,
                  subtitle: favs[i].contentArtist ?? favs[i].contentType,
                  type: favs[i].contentType,
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite_rounded, color: AppTheme.error),
                    onPressed: () async {
                      await ref.read(libraryServiceProvider)
                          .removeFavorite(favs[i].contentId);
                      ref.invalidate(favoritesProvider);
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
