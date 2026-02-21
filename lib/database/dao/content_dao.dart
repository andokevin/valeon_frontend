import 'package:sqflite/sqflite.dart';
import '../../models/content_model.dart';
import '../database_helper.dart';

class ContentDao {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<int> insert(ContentModel content) async {
    final db = await _db.database;
    return db.insert(
      'contents',
      content.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertAll(List<ContentModel> contents) async {
    final db = await _db.database;
    int count = 0;
    final batch = db.batch();
    for (final c in contents) {
      batch.insert('contents', c.toDbMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      count++;
    }
    await batch.commit(noResult: true);
    return count;
  }

  Future<ContentModel?> getById(int id) async {
    final db = await _db.database;
    final maps = await db.query('contents',
        where: 'content_id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return ContentModel.fromDbMap(maps.first);
  }

  Future<List<ContentModel>> getByType(String type, {int limit = 50}) async {
    final db = await _db.database;
    final maps = await db.query('contents',
        where: 'content_type = ?',
        whereArgs: [type],
        orderBy: 'content_date DESC',
        limit: limit);
    return maps.map(ContentModel.fromDbMap).toList();
  }

  Future<List<ContentModel>> search(String query, {int limit = 20}) async {
    final db = await _db.database;
    final maps = await db.query(
      'contents',
      where: 'content_title LIKE ? OR content_artist LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      limit: limit,
    );
    return maps.map(ContentModel.fromDbMap).toList();
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return db.delete('contents', where: 'content_id = ?', whereArgs: [id]);
  }

  Future<int> count() async {
    final db = await _db.database;
    return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM contents')) ??
        0;
  }
}
