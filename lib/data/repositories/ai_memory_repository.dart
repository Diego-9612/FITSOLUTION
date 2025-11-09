import 'package:supabase_flutter/supabase_flutter.dart';

class AiMemoryRepository {
  final SupabaseClient _client;
  AiMemoryRepository(this._client);

  Future<String?> getLatestSummary(String userId) async {
    final rows = await _client
        .from('ai_memory')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1);
    if ((rows as List).isEmpty) return '';
    final mem = rows.first['memory'];
    if (mem is Map && mem['summary'] is String) return mem['summary'];
    return '';
  }

  Future<void> appendMemory(String userId, Map<String, dynamic> toAdd) async {
    await _client.from('ai_memory').insert({'user_id': userId, 'memory': toAdd});
  }

  Future<void> saveRoutineContext(String userId, Map<String, dynamic> routineJson) async {
    await appendMemory(userId, {
      'type': 'routine_generated',
      'summary': 'Rutina PPL generada para el usuario',
      'data': routineJson,
    });
  }
}
