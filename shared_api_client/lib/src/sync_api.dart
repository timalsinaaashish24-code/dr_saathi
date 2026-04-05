import 'api_client.dart';

class SyncApi {
  final _client = ApiClient();

  /// Pull latest data from server since last sync
  Future<ApiResponse> pull({String? lastSyncAt, List<String>? tables}) async {
    return _client.post('/sync/pull', body: {
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (tables != null) 'tables': tables,
    });
  }

  /// Push local changes to server
  Future<ApiResponse> push(List<Map<String, dynamic>> changes) async {
    return _client.post('/sync/push', body: {'changes': changes});
  }
}
