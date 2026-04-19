// modify_info_temoin.dart
// Modification et suppression d'un témoin dans info_perso_temoin

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

  static Future<void> delete(String id) async {
    final db = CreateTableTemoin.db;

    // Suppression des collectes liées avant le témoin
    // (les collectes référencent l'id du témoin dans le champ questionnaire)
    final collectes = await db.rawQuery('''
      SELECT id FROM collect_info_from_temoin
      WHERE json_extract(questionnaire, '\$[0].valeur') = ?
    ''', [id]);

    for (final c in collectes) {
      await db.delete(
        'info_perso_temoin_collect',
        where:     'collect_id = ?',
        whereArgs: [c['id']],
      );
    }

    await db.rawDelete('''
      DELETE FROM collect_info_from_temoin
      WHERE json_extract(questionnaire, '\$[0].valeur') = ?
    ''', [id]);

    await db.delete(
      'info_perso_temoin',
      where:     'id = ?',
      whereArgs: [id],
    );
  }
}
