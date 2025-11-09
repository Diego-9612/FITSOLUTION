import 'package:supabase_flutter/supabase_flutter.dart';

class RoutineRepository {
  final SupabaseClient _client;
  RoutineRepository(this._client);

  /// Devuelve la rutina activa más reciente del usuario.
  /// Usamos order + limit(1) para evitar el error 406 (múltiples filas).
  Future<Map<String, dynamic>?> getActiveRoutine(String userId) async {
    final res = await _client
        .from('routines')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return res;
  }

  /// Desactiva todas las rutinas activas del usuario (seguridad antes de crear una nueva).
  Future<void> deactivateAllActives(String userId) async {
    await _client
        .from('routines')
        .update({'is_active': false})
        .eq('user_id', userId)
        .eq('is_active', true);
  }

  Future<String> createRoutine(String userId, String title) async {
    final inserted = await _client
        .from('routines')
        .insert({'user_id': userId, 'title': title, 'is_active': true})
        .select('id')
        .single();
    return inserted['id'] as String;
  }

  Future<void> clearRoutineDays(String routineId) async {
    await _client.from('routine_days').delete().eq('routine_id', routineId);
  }

  Future<String> addRoutineDay({
    required String routineId,
    required int weekday,
    required String split,
    required int position,
  }) async {
    final m = await _client
        .from('routine_days')
        .insert({
          'routine_id': routineId,
          'weekday': weekday,
          'split': split,
          'position': position,
        })
        .select('id')
        .single();
    return m['id'];
  }

  Future<void> addExercise({
    required String routineDayId,
    required Map<String, dynamic> exercise,
  }) async {
    await _client.from('exercises').insert({
      'routine_day_id': routineDayId,
      'name': exercise['name'],
      'muscle_groups': exercise['muscle_groups'],
      'description': exercise['description'],
      'how_to': exercise['how_to'],
      'sets': exercise['sets'],
      'reps': exercise['reps'],
    });
  }

  Future<List<Map<String, dynamic>>> getRoutineForWeek(String routineId) async {
    final days = await _client
        .from('routine_days')
        .select(
          'id, weekday, split, position, '
          'exercises(id, name, muscle_groups, description, how_to, sets, reps)',
        )
        .eq('routine_id', routineId)
        .order('position');
    return (days as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
