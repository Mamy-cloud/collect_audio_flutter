import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../database/local_database.dart';
import '../../../models/witness_model.dart';
import 'audio_upload_service.dart';

class SyncResult {
  final int uploaded, failed, resumed;
  final List<String> errors;
  const SyncResult({required this.uploaded, required this.failed,
      required this.resumed, required this.errors});
  bool get isSuccess => failed == 0;
  @override
  String toString() => '$uploaded transféré(s), $failed échoué(s)';
}

class ResilientSyncService {
  static final _sb = Supabase.instance.client;

  static Future<bool> isOnline() async {
    final r = await Connectivity().checkConnectivity();
    return r.any((c) => c != ConnectivityResult.none);
  }

  static void enableAutoSync({
    void Function(SyncResult)? onComplete,
    void Function(int, int)? onProgress,
  }) {
    Connectivity().onConnectivityChanged.listen((r) {
      if (r.any((c) => c != ConnectivityResult.none)) {
        syncAll(onComplete: onComplete, onProgress: onProgress);
      }
    });
  }

  static Future<SyncResult> syncAll({
    void Function(int, int)? onProgress,
    void Function(SyncResult)? onComplete,
  }) async {
    int uploaded = 0, failed = 0, resumed = 0;
    final errors = <String>[];
    final pending = await LocalDatabase.getPendingWitnesses();

    if (pending.isEmpty) {
      const r = SyncResult(uploaded:0, failed:0, resumed:0, errors:[]);
      onComplete?.call(r);
      return r;
    }

    for (final w in pending) {
      try {
        final wasResumed = await _syncOne(w);
        if (wasResumed) resumed++;
        uploaded++;
        onProgress?.call(uploaded, pending.length);
      } catch (e) {
        failed++;
        errors.add('id=${w.id}: $e');
        await LocalDatabase.updateSyncStatus(w.id!, 'error',
            errorMessage: e.toString());
      }
    }

    final result = SyncResult(
        uploaded: uploaded, failed: failed, resumed: resumed, errors: errors);
    onComplete?.call(result);
    return result;
  }

  static Future<bool> _syncOne(WitnessModel w) async {
    bool isResumed = false;
    await LocalDatabase.updateSyncStatus(w.id!, 'syncing');

    // ── Étape 1 : Upload audio ────────────────────────────────────────────────
    String? audioId = w.audioSupabaseId;

    if (w.audioPath != null && audioId == null) {
      final result = await AudioUploadService.uploadAndSave(
        filePath:  w.audioPath!,
        duration:  w.audioDuration ?? '00:00:00',
        createdAt: w.createdAt,
      );
      audioId = result.audioSupabaseId;
      await LocalDatabase.saveAudioSupabaseId(
        witnessLocalId:  w.id!,
        audioSupabaseId: audioId,
        audioPublicUrl:  result.publicUrl,
      );
    } else if (audioId != null) {
      isResumed = true;
    }

    // ── Étape 2 : INSERT collect_info_temoin ──────────────────────────────────
    if (w.supabaseId == null) {
      if (audioId == null) throw Exception('audio_id manquant');
      final r = await _sb
          .from('collect_info_temoin')
          .insert(w.toSupabaseInsert(audioId: audioId))
          .select('id')
          .single();
      await LocalDatabase.updateSyncStatus(w.id!, 'synced',
          supabaseId: r['id'] as String);
    } else {
      isResumed = true;
    }

    // ── Étape 3 : Nettoyage ───────────────────────────────────────────────────
    await LocalDatabase.deleteWitness(w.id!);
    if (w.audioPath != null) {
      final f = File(w.audioPath!);
      if (await f.exists()) await f.delete();
    }

    return isResumed;
  }

  static Future<SyncResult> retryFailed() async {
    final pending = await LocalDatabase.getPendingWitnesses();
    for (final w in pending.where((w) => w.syncStatus == 'error')) {
      await LocalDatabase.updateSyncStatus(w.id!, 'pending');
    }
    return await syncAll();
  }
}
