import '../database/database_service.dart';
import '../network/api_client.dart';
import 'dart:convert';

class SyncQueue {
  final DatabaseService _db = DatabaseService();

  // ✅ Singleton — pas de new ApiClient()
  final ApiClient _api = ApiClient.instance;

  Future<void> processQueue() async {
    final queue = await _db.getSyncQueue();

    for (final item in queue) {
      try {
        final data = jsonDecode(item['data'] as String);

        switch (item['operation']) {
          case 'INSERT':
          case 'UPDATE':
            await _api.post('/${item['tableName']}/sync', data: data);
            break;
          case 'DELETE':
            await _api.delete('/${item['tableName']}/${data['id']}');
            break;
        }

        await _db.removeFromSyncQueue(item['id'] as String);
      } catch (e) {
        // Incrémenter le compteur de retry
        await _db.incrementRetryCount(item['id'] as String);
        print('❌ Erreur sync queue ${item['id']}: $e');
      }
    }
  }
}
