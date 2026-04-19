// modify_info_temoin.dart
// Modification et suppression d'un témoin dans info_perso_temoin

import 'dart:convert';
import '../create_table/create_table_temoin.dart';

class ModifyInfoTemoin {

  // ── Modifier les infos d'un témoin ────────────────────────────────────────

  static Future<void> update({
    required String  id,
    required String  nom,
    required String  prenom,
    String?          dateNaissance,
    String?          departement,
    String?          region,
    String?          imgTemoin,
  }) async {
    final db = CreateTableTemoin.db;

    await db.update(
      'info_perso_temoin',
      {
        'nom':            nom,
        'prenom':         prenom,
        'date_naissance': dateNaissance,
        'departement':    departement,
        'region':         region,
        'img_temoin':     imgTemoin,
      },
      where:     'id = ?',
      whereArgs: [id],
    );
  }

  // ── Supprimer un témoin et toutes ses collectes associées ─────────────────
  // Filtrage côté Dart pour éviter json_extract (non supporté sur Android ancien)

  static Future<void> delete(String id) async {
    final db = CreateTableTemoin.db;

    // Récupère toutes les collectes et filtre en Dart
    final allCollectes = await db.query('collect_info_from_temoin');
    final collectesLiees = <String>[];

    for (final c in allCollectes) {
      try {
        final q = jsonDecode(c['questionnaire'] as String) as List<dynamic>;
        if (q.isNotEmpty &&
            q.first['champ'] == 'temoin_id' &&
            q.first['valeur'] == id) {
          collectesLiees.add(c['id'] as String);
        }
      } catch (_) {}
    }

    // Suppression des tables liées
    for (final collectId in collectesLiees) {
      await db.delete(
        'info_perso_temoin_collect',
        where:     'collect_id = ?',
        whereArgs: [collectId],
      );
      await db.delete(
        'collect_info_from_temoin',
        where:     'id = ?',
        whereArgs: [collectId],
      );
    }

    // Suppression du témoin
    await db.delete(
      'info_perso_temoin',
      where:     'id = ?',
      whereArgs: [id],
    );
  }
}
