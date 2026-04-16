import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AudioUploadResult {
  final String audioSupabaseId;
  final String publicUrl;
  const AudioUploadResult({required this.audioSupabaseId, required this.publicUrl});
}

class AudioUploadService {
  static final _sb     = Supabase.instance.client;
  static const _bucket = 'collect_audio';
  static const _folder = 'audios';

  static Future<AudioUploadResult> uploadAndSave({
    required String filePath,
    required String duration,
    required String createdAt,
  }) async {
    final file        = File(filePath);
    final ext         = filePath.split('.').last.toLowerCase();
    final fileName    = '${DateTime.now().millisecondsSinceEpoch}_audio.$ext';
    final storagePath = '$_folder/$fileName';

    await _sb.storage.from(_bucket).upload(
      storagePath, file,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );

    final publicUrl = _sb.storage.from(_bucket).getPublicUrl(storagePath);

    final data = await _sb
        .from('collect_audio')
        .insert({'url': publicUrl, 'duration': duration, 'created_at': createdAt})
        .select('id')
        .single();

    return AudioUploadResult(
      audioSupabaseId: data['id'] as String,
      publicUrl:       publicUrl,
    );
  }
}
