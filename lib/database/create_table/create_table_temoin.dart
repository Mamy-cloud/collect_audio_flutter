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

    _db = await openDatabase(
      join(dbPath, 'mon_app.db'),
      version: 2,

      onCreate: (db, version) async {
        await _createInfoPersoTemoin(db);
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE info_perso_temoin ADD COLUMN img_temoin TEXT'
          );
        }
      },

      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  static Future<void> _createInfoPersoTemoin(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS info_perso_temoin (
        id             TEXT    PRIMARY KEY,
        nom            TEXT    NOT NULL,
        prenom         TEXT    NOT NULL,
        date_naissance TEXT,
        departement    TEXT,
        region         TEXT,
        img_temoin     TEXT,
        date_creation  TEXT    NOT NULL
      )
    ''');
  }
}
