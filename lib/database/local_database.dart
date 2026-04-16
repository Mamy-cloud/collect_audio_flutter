// ─── local_database.dart ──────────────────────────────────────────────────────
// Version 2 — migration : suppression colonne age, ajout date_naissance
// La table witnesses stocke date_naissance (YYYY-MM-DD)
// Le birth_year est extrait côté WitnessModel lors de l'insert Supabase
// ─────────────────────────────────────────────────────────────────────────────

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/witness_model.dart';

class LocalDatabase {
  static Database? _db;

  // ═══════════════════════════════════════════════════════════════════════════
  // INIT
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<void> init() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), 'conta.db'),
      version:   2,            // ✅ incrémenté de 1 → 2
      onCreate:  _onCreate,
      onUpgrade: _onUpgrade,   // ✅ migration pour les appareils existants
    );
  }

  static Database get db {
    if (_db == null) throw Exception('LocalDatabase non initialisée');
    return _db!;
  }

  // ── Création initiale (nouveaux appareils) ─────────────────────────────────

  static Future<void> _onCreate(Database db, int version) async {
    // Table principale — date_naissance TEXT (pas age, pas birth_year)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS witnesses (
        id                 INTEGER PRIMARY KEY AUTOINCREMENT,
        nom                TEXT    NOT NULL,
        prenom             TEXT    NOT NULL,
        date_naissance     TEXT    NOT NULL,
        departement_id     TEXT    NOT NULL,
        region_id          TEXT    NOT NULL,
        audio_path         TEXT,
        audio_duration     TEXT,
        accept_rgpd        INTEGER NOT NULL DEFAULT 0,
        created_at         TEXT    NOT NULL,
        sync_status        TEXT    NOT NULL DEFAULT 'pending',
        supabase_id        TEXT,
        audio_supabase_id  TEXT,
        audio_public_url   TEXT,
        error_message      TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS cache_departements (
        id               TEXT PRIMARY KEY,
        name_departement TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS cache_regions_corse (
        id          TEXT PRIMARY KEY,
        name_region TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS cache_meta (
        key   TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  // ── Migration (appareils qui avaient la v1 avec colonne age) ──────────────

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // v1 → v2 : supprime age, ajoute date_naissance
    if (oldVersion < 2) {
      // Supprime l'ancienne colonne age si elle existe
      try {
        await db.execute('ALTER TABLE witnesses DROP COLUMN age');
      } catch (_) {
        // age n'existait pas → pas de problème
      }

      // Ajoute date_naissance si elle n'existe pas
      try {
        await db.execute(
            "ALTER TABLE witnesses ADD COLUMN date_naissance TEXT NOT NULL DEFAULT ''");
      } catch (_) {
        // date_naissance existait déjà → pas de problème
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WITNESSES — CRUD
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<int> insertWitness(WitnessModel w) async =>
      await db.insert('witnesses', w.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);

  static Future<List<WitnessModel>> getPendingWitnesses() async {
    final maps = await db.query('witnesses',
        where:   "sync_status IN ('pending','error','syncing')",
        orderBy: 'created_at ASC');
    return maps.map(WitnessModel.fromMap).toList();
  }

  static Future<int> countPending() async {
    final r = await db.rawQuery(
        "SELECT COUNT(*) as c FROM witnesses WHERE sync_status IN ('pending','error')");
    return r.first['c'] as int;
  }

  static Future<void> updateSyncStatus(
    int id, String status, {
    String? supabaseId,
    String? errorMessage,
  }) async {
    await db.update(
      'witnesses',
      {
        'sync_status': status,
        if (supabaseId   != null) 'supabase_id':   supabaseId,
        if (errorMessage != null) 'error_message': errorMessage,
      },
      where: 'id = ?', whereArgs: [id],
    );
  }

  static Future<void> saveAudioSupabaseId({
    required int    witnessLocalId,
    required String audioSupabaseId,
    required String audioPublicUrl,
  }) async {
    await db.update(
      'witnesses',
      {
        'audio_supabase_id': audioSupabaseId,
        'audio_public_url':  audioPublicUrl,
      },
      where: 'id = ?', whereArgs: [witnessLocalId],
    );
  }

  static Future<void> deleteWitness(int id) async =>
      await db.delete('witnesses', where: 'id = ?', whereArgs: [id]);

  // ═══════════════════════════════════════════════════════════════════════════
  // CACHE DÉPARTEMENTS
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<void> cacheDepartements(
      List<Map<String, dynamic>> rows) async {
    final b = db.batch();
    b.delete('cache_departements');
    for (final r in rows) {
      b.insert('cache_departements',
          {'id': r['id'], 'name_departement': r['name_departement']},
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    b.insert('cache_meta',
        {'key': 'departements_cached_at', 'value': DateTime.now().toIso8601String()},
        conflictAlgorithm: ConflictAlgorithm.replace);
    await b.commit(noResult: true);
  }

  static Future<List<Map<String, dynamic>>> getDepartements() async =>
      await db.query('cache_departements', orderBy: 'name_departement ASC');

  // ═══════════════════════════════════════════════════════════════════════════
  // CACHE RÉGIONS
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<void> cacheRegionsCorse(
      List<Map<String, dynamic>> rows) async {
    final b = db.batch();
    b.delete('cache_regions_corse');
    for (final r in rows) {
      b.insert('cache_regions_corse',
          {'id': r['id'], 'name_region': r['name_region']},
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    b.insert('cache_meta',
        {'key': 'regions_corse_cached_at', 'value': DateTime.now().toIso8601String()},
        conflictAlgorithm: ConflictAlgorithm.replace);
    await b.commit(noResult: true);
  }

  static Future<List<Map<String, dynamic>>> getRegionsCorse() async =>
      await db.query('cache_regions_corse', orderBy: 'name_region ASC');

  // ═══════════════════════════════════════════════════════════════════════════
  // CACHE META
  // ═══════════════════════════════════════════════════════════════════════════

  static Future<bool> isCacheValid(String key,
      {Duration maxAge = const Duration(days: 7)}) async {
    final rows = await db.query('cache_meta',
        where: 'key = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) return false;
    final d = DateTime.tryParse(rows.first['value'] as String);
    return d != null && DateTime.now().difference(d) < maxAge;
  }

  static Future<void> invalidateCache(String key) async =>
      await db.delete('cache_meta', where: 'key = ?', whereArgs: [key]);

  static Future<bool> hasOfflineData() async {
    final d = (await db.rawQuery(
        'SELECT COUNT(*) as c FROM cache_departements')).first['c'] as int;
    final r = (await db.rawQuery(
        'SELECT COUNT(*) as c FROM cache_regions_corse')).first['c'] as int;
    return d > 0 && r > 0;
  }
}
