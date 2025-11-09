import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _client;
  StorageService(this._client);

  Future<String> uploadUserMemory({
    required String userId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final path = '$userId/$fileName';
    await _client.storage.from('user-memory').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );
    return path;
  }

  Future<Uint8List?> downloadUserMemory({
    required String userId,
    required String fileName,
  }) async {
    final path = '$userId/$fileName';
    return _client.storage.from('user-memory').download(path);
  }
}
