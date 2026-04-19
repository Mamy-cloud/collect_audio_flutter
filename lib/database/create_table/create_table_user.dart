// create_table_user.dart
// Gestion de la table login_user
// Relation : login_user (1) ──────< collect_info_from_temoin (N)
//
// ⚠️ N'ouvre pas sa propre connexion — utilise CreateTableTemoin.db
//    CreateTableTemoin.init() doit être appelé dans main.dart avant tout.

import 'package:sqflite/sqflite.dart';
import 'create_table_temoin.dart';

class CreateTableUser {
  static Database get _db => CreateTableTemoin.db;

  // ─────────────────────────────────────────
  // WRITE
  // ─────────────────────────────────────────

  /// Insère un utilisateur en local
  /// [id] → UUID généré côté Dart avec le package uuid
  Future<void> insertUser({
    required String id,
    required String identifiant,
    required String password,
  }) async {
    await _db.insert(
      'login_user',
      {
        'id':          id,
        'identifiant': identifiant,
        'password':    password,
        'created_at':  DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─────────────────────────────────────────
  // READ
  // ─────────────────────────────────────────

  /// Récupère un utilisateur par son identifiant
  Future<Map<String, dynamic>?> getUserByIdentifiant(
      String identifiant) async {
    final result = await _db.query(
      'login_user',
      where:     'identifiant = ?',
      whereArgs: [identifiant],
      limit:     1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Récupère un utilisateur par son id
  Future<Map<String, dynamic>?> getUserById(String id) async {
    final result = await _db.query(
      'login_user',
      where:     'id = ?',
      whereArgs: [id],
      limit:     1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Récupère un utilisateur avec toutes ses collectes associées
  Future<Map<String, dynamic>?> getUserWithCollects(String userId) async {
    final userResult = await _db.query(
      'login_user',
      where:     'id = ?',
      whereArgs: [userId],
      limit:     1,
    );
    if (userResult.isEmpty) return null;

    final user    = Map<String, dynamic>.from(userResult.first);
    final collects = await _db.query(
      'collect_info_from_temoin',
      where:     'user_id = ?',
      whereArgs: [userId],
      orderBy:   'created_at DESC',
    );
    user['collect_info_from_temoin'] = collects;
    return user;
  }

  // ─────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────

  /// Supprime un utilisateur et toutes ses collectes associées
  Future<void> deleteUser(String id) async {
    await _db.delete(
      'collect_info_from_temoin',
      where:     'user_id = ?',
      whereArgs: [id],
    );
    await _db.delete(
      'login_user',
      where:     'id = ?',
      whereArgs: [id],
    );
  }
}
