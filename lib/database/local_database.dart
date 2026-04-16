import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static Database? _db;

  static Future<void> init() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'conta_mobile.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS temoins (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            nom         TEXT NOT NULL,
            prenom      TEXT NOT NULL,
            date_naissance TEXT,
            departement TEXT,
            region      TEXT,
            chemin_audio TEXT,
            duree_audio TEXT,
            accept_rgpd INTEGER DEFAULT 0,
            date_creation TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Database get db {
    if (_db == null) throw Exception('Database non initialisée');
    return _db!;
  }

  /// Insère un témoin — retourne l'id auto-incrémenté
  static Future<int> insertTemoin(Map<String, dynamic> data) async {
    return await db.insert('temoins', data);
  }

  /// Récupère tous les témoins, du plus récent au plus ancien
  static Future<List<Map<String, dynamic>>> getAllTemoins() async {
    return await db.query('temoins', orderBy: 'id DESC');
  }

  /// Supprime un témoin par id
  static Future<void> deleteTemoin(int id) async {
    await db.delete('temoins', where: 'id = ?', whereArgs: [id]);
  }

  /// Retourne vrai si la table contient au moins une ligne
  static Future<bool> hasOfflineData() async {
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM temoins');
    return (result.first['c'] as int) > 0;
  }
}
