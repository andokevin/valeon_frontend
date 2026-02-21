import 'package:dio/dio.dart';
import '../core/errors/app_exception.dart';
import '../core/network/api_client.dart';
import '../models/favorite_model.dart';
import '../models/playlist_model.dart';
import '../models/scan_model.dart';

class LibraryService {
  final _api = ApiClient.instance;

  Future<List<FavoriteModel>> getFavorites({String? contentType}) async {
    try {
      final res = await _api.get('/library/favorites',
          params: contentType != null ? {'content_type': contentType} : null);
      return (res.data as List).map((j) => FavoriteModel.fromJson(j)).toList();
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<void> addFavorite(int contentId, {String? notes}) async {
    try {
      await _api.post('/library/favorites/$contentId',
          data: notes != null ? {'notes': notes} : null);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<void> removeFavorite(int contentId) async {
    try {
      await _api.delete('/library/favorites/$contentId');
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<bool> checkFavorite(int contentId) async {
    try {
      final res = await _api.get('/library/favorites/check/$contentId');
      return res.data['is_favorite'] ?? false;
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<List<PlaylistModel>> getPlaylists() async {
    try {
      final res = await _api.get('/library/playlists');
      return (res.data as List).map((j) => PlaylistModel.fromJson(j)).toList();
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<PlaylistModel> createPlaylist(String name, {String? description}) async {
    try {
      final res = await _api.post('/library/playlists', data: {
        'playlist_name': name,
        if (description != null) 'playlist_description': description,
      });
      return PlaylistModel.fromJson(res.data);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<PlaylistModel> getPlaylist(int id) async {
    try {
      final res = await _api.get('/library/playlists/$id');
      return PlaylistModel.fromJson(res.data);
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<void> deletePlaylist(int id) async {
    try {
      await _api.delete('/library/playlists/$id');
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<void> addToPlaylist(int playlistId, int contentId) async {
    try {
      await _api.post('/library/playlists/$playlistId/add',
          data: {'content_id': contentId});
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<List<ScanModel>> getHistory({int skip = 0, int limit = 50}) async {
    try {
      final res = await _api.get('/library/history',
          params: {'skip': skip, 'limit': limit});
      return (res.data as List).map((j) => ScanModel.fromJson(j)).toList();
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    try {
      final res = await _api.get('/library/stats');
      return res.data;
    } on DioException catch (e) {
      throw AppException.fromDio(e);
    }
  }
}
