import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/favorite_model.dart';
import '../models/playlist_model.dart';
import '../models/scan_model.dart';
import '../services/library_service.dart';

final libraryServiceProvider = Provider((_) => LibraryService());

final favoritesProvider = FutureProvider.autoDispose<List<FavoriteModel>>((ref) async {
  return ref.watch(libraryServiceProvider).getFavorites();
});

final playlistsProvider = FutureProvider.autoDispose<List<PlaylistModel>>((ref) async {
  return ref.watch(libraryServiceProvider).getPlaylists();
});

final historyProvider = FutureProvider.autoDispose<List<ScanModel>>((ref) async {
  return ref.watch(libraryServiceProvider).getHistory();
});

final statsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.watch(libraryServiceProvider).getStats();
});

final favoriteCheckProvider = FutureProvider.autoDispose.family<bool, int>((ref, contentId) async {
  return ref.watch(libraryServiceProvider).checkFavorite(contentId);
});
