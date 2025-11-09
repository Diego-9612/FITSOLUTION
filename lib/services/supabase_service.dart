import 'package:supabase_flutter/supabase_flutter.dart';
import '../env.dart';

class SupabaseService {
  static Future<void> init() async {
    await Supabase.initialize(
      url: AppEnv.supabaseUrl,
      anonKey: AppEnv.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
