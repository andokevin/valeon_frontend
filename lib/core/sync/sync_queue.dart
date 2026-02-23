// lib/core/sync/sync_queue.dart
import 'package:flutter/material.dart';

import '../database/database_service.dart';
import '../network/api_client.dart';
import 'dart:convert';

class SyncQueue {
  final DatabaseService _db = DatabaseService();
  final ApiClient _api = ApiClient();

  Future<void> processQueue() async {
    final queue = await _db.getSyncQueue();

    for (final item in queue) {
      try {
        final data = jsonDecode(item['data'] as String);

        switch (item['operation']) {
          case 'INSERT':
          case 'UPDATE':
            await _api.post('/${item['table_name']}/sync', data: data);
            break;
          case 'DELETE':
            await _api.delete('/${item['table_name']}/${data['id']}');
            break;
        }

        await _db.removeFromSyncQueue(item['id'] as String);
      } catch (e) {
        await _db.incrementRetryCount(item['id'] as String);
        debugPrint('❌ Erreur sync queue ${item['id']}: $e');
      }
    }
  }
}
