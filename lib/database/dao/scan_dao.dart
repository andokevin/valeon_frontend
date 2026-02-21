import 'package:sqflite/sqflite.dart';
import '../../models/scan_model.dart';
import '../database_helper.dart';

class ScanDao {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<int> insert(ScanModel scan) async {
    final db = await _db.database;
    return db.insert('scans', scan.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ScanModel>> getAll({int limit = 100, int offset = 0}) async {
    final db = await _db.database;
    final maps = await db.query('scans',
        orderBy: 'scan_date DESC', limit: limit, offset: offset);
    return maps.map(ScanModel.fromDbMap).toList();
  }

  Future<List<ScanModel>> getByType(ScanType type,
      {int limit = 50}) async {
    final db = await _db.database;
    final maps = await db.query('scans',
        where: 'scan_type = ?',
        whereArgs: [type.name],
        orderBy: 'scan_date DESC',
        limit: limit);
    return maps.map(ScanModel.fromDbMap).toList();
  }

  Future<List<ScanModel>> getUnsynced() async {
    final db = await _db.database;
    final maps = await db.query('scans',
        where: 'synced = ?', whereArgs: [0]);
    return maps.map(ScanModel.fromDbMap).toList();
  }

  Future<int> markSynced(int scanId) async {
    final db = await _db.database;
    return db.update('scans', {'synced': 1},
        where: 'scan_id = ?', whereArgs: [scanId]);
  }

  Future<int> updateStatus(int scanId, String status,
      {Map<String, dynamic>? result, String? error}) async {
    final db = await _db.database;
    final data = {'status': status};
    if (result != null) data['result'] = result.toString();
    if (error != null) data['error'] = error;
    return db.update('scans', data,
        where: 'scan_id = ?', whereArgs: [scanId]);
  }

  Future<int> countToday() async {
    final db = await _db.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return Sqflite.firstIntValue(await db.rawQuery(
          "SELECT COUNT(*) FROM scans WHERE scan_date LIKE '$today%'")) ??
        0;
  }

  Future<int> delete(int scanId) async {
    final db = await _db.database;
    return db.delete('scans', where: 'scan_id = ?', whereArgs: [scanId]);
  }

  Future<int> clearAll() async {
    final db = await _db.database;
    return db.delete('scans');
  }
}
