// lib/core/sync/sync_queue.dart
import '../database/database_service.dart';
import '../network/api_client.dart';
import 'dart:convert';

class SyncQueue {
  final DatabaseService _db = DatabaseService();
  final ApiClient _api = ApiClient();

  Future<void> processQueue() async {
    final queue = await _db.getSyncQueue();

    for (var item in queue) {
      try {
        final data = jsonDecode(item['data']);

        switch (item['operation']) {
          case 'INSERT':
          case 'UPDATE':
            await _api.post('/${item['tableName']}/sync', data: data);
            break;
          case 'DELETE':
            await _api.delete('/${item['tableName']}/${data['id']}');
            break;
        }

        await _db.removeFromSyncQueue(item['id']);
      } catch (e) {
        // Incrémenter le compteur de retry
        await _db.incrementRetryCount(item['id']);
      }
    }
  }
}
