import 'package:supabase_flutter/supabase_flutter.dart';

class ProgressRepository {
  final SupabaseClient _client;
  ProgressRepository(this._client);

  Future<void> setCompletion({
    required String userId,
    required String exerciseId,
    required DateTime date,
    required bool done,
  }) async {
    final ymd = DateTime.utc(date.year, date.month, date.day);
    await _client.from('completions').upsert({
      'user_id': userId,
      'exercise_id': exerciseId,
      'date_ymd': ymd.toIso8601String().substring(0, 10),
      'done': done,
    }, onConflict: 'user_id,exercise_id,date_ymd');
  }

  
  Future<List<Map<String, dynamic>>> getCompletionsForDate({
    required String userId,
    required DateTime date,
  }) async {
    final ymd = DateTime.utc(date.year, date.month, date.day)
        .toIso8601String()
        .substring(0, 10);

    final rows = await _client
        .from('completions')
        .select('''
          id,
          done,
          date_ymd,
          exercise:exercise_id (
            id,
            name,
            routine_day:routine_day_id (
              split,
              weekday
            )
          )
        ''')
        .eq('user_id', userId)
        .eq('date_ymd', ymd)
        .eq('done', true) 
        .order('id');

    return (rows as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

 
  Future<List<Map<String, dynamic>>> getAllForDate({
    required String userId,
    required DateTime date,
  }) async {
    final ymd = DateTime.utc(date.year, date.month, date.day)
        .toIso8601String()
        .substring(0, 10);

    final rows = await _client
        .from('completions')
        .select('''
          id,
          done,
          date_ymd,
          exercise:exercise_id (
            id,
            name,
            routine_day:routine_day_id (
              split,
              weekday
            )
          )
        ''')
        .eq('user_id', userId)
        .eq('date_ymd', ymd)
        .order('id');

    return (rows as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>?> getStreak(String userId) async {
    return await _client
        .from('streaks')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
  }

  Future<void> updateStreakOnDayCompleted(String userId, DateTime day) async {
    final ymd = DateTime.utc(day.year, day.month, day.day)
        .toIso8601String()
        .substring(0, 10);
    final current = await getStreak(userId);
    if (current == null) {
      await _client.from('streaks').insert({
        'user_id': userId,
        'current_streak': 1,
        'longest_streak': 1,
        'last_completed': ymd
      });
      return;
    }
    final last = current['last_completed'] != null
        ? DateTime.parse(current['last_completed'])
        : null;
    int cur = current['current_streak'];
    int best = current['longest_streak'];

    final yesterday = DateTime.utc(day.year, day.month, day.day)
        .subtract(const Duration(days: 1));
    final continued = last != null &&
        last.year == yesterday.year &&
        last.month == yesterday.month &&
        last.day == yesterday.day;

    if (continued) {
      cur += 1;
    } else {
      cur = 1;
    }
    if (cur > best) best = cur;

    await _client.from('streaks').upsert({
      'user_id': userId,
      'current_streak': cur,
      'longest_streak': best,
      'last_completed': ymd
    });
  }
}
