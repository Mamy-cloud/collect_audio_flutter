// create_table_collect.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CreateTableTemoin {
  static Database? _db;

  static Database get db {
    if (_db == null) throw Exception('Base de données non initialisée');
    return _db!;
  }

  static Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path   = join(dbPath, 'mon_app.db');

    _db = await openDatabase(
      path,
      version: 3,

      onCreate: (db, version) async {
        await _createInfoPersoTemoin(db);
        await _createLoginUser(db);
        await _createCollectInfoFromTemoin(db);
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE info_perso_temoin ADD COLUMN img_temoin TEXT',
          );
        }
        if (oldVersion < 3) {
          await _createLoginUser(db);
          await _createCollectInfoFromTemoin(db);
        }
      },

      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');

        // Utilisateur de test — à retirer quand le login sera implémenté
        await db.execute('''
          INSERT OR IGNORE INTO login_user (id, identifiant, password, created_at)
          VALUES ('test', 'test', 'test', '2024-01-01T00:00:00.000')
        ''');
      },
    );
  }

  // ─────────────────────────────────────────
  // CRÉATION DES TABLES
  // ─────────────────────────────────────────

  static Future<void> _createInfoPersoTemoin(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS info_perso_temoin (
        id             TEXT PRIMARY KEY,
        nom            TEXT NOT NULL,
        prenom         TEXT NOT NULL,
        date_naissance TEXT,
        departement    TEXT,
        region         TEXT,
        img_temoin     TEXT,
        date_creation  TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createLoginUser(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS login_user (
        id          TEXT PRIMARY KEY,
        identifiant TEXT NOT NULL UNIQUE,
        password    TEXT NOT NULL,
        created_at  TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createCollectInfoFromTemoin(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS collect_info_from_temoin (
        id            TEXT PRIMARY KEY,
        user_id       TEXT NOT NULL,
        questionnaire TEXT NOT NULL DEFAULT '[]',
        url_audio     TEXT,
        created_at    TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES login_user(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS info_perso_temoin_collect (
        id          TEXT PRIMARY KEY,
        collect_id  TEXT NOT NULL,
        created_at  TEXT NOT NULL,
        FOREIGN KEY (collect_id) REFERENCES collect_info_from_temoin(id)
      )
    ''');
  }
}
