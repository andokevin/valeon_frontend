import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../../models/content_model.dart';

class FavoriteDao {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<int> add(int contentId, {String? notes}) async {
    final db = await _db.database;
    return db.insert(
      'favorites',
      {
        'content_id': contentId,
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> remove(int contentId) async {
    final db = await _db.database;
    return db.delete('favorites',
        where: 'content_id = ?', whereArgs: [contentId]);
  }

  Future<bool> isFavorite(int contentId) async {
    final db = await _db.database;
    final maps = await db.query('favorites',
        where: 'content_id = ?', whereArgs: [contentId], limit: 1);
    return maps.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getFavoritesWithContent() async {
    final db = await _db.database;
    return db.rawQuery('''
      SELECT f.favorite_id, f.content_id, f.notes, f.created_at,
             c.content_title, c.content_type, c.content_image, c.content_artist
      FROM favorites f
      INNER JOIN contents c ON f.content_id = c.content_id
      ORDER BY f.created_at DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getUnsynced() async {
    final db = await _db.database;
    return db.query('favorites', where: 'synced = ?', whereArgs: [0]);
  }

  Future<int> markSynced(int favoriteId) async {
    final db = await _db.database;
    return db.update('favorites', {'synced': 1},
        where: 'favorite_id = ?', whereArgs: [favoriteId]);
  }

  Future<int> count() async {
    final db = await _db.database;
    return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM favorites')) ??
        0;
  }
}
