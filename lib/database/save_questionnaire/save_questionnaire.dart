// save_questionnaire.dart
// Sauvegarde le questionnaire de contexte et l'url audio associée
// dans la table collect_info_from_temoin, reliée à login_user.
//
// Relations :
//   info_perso_temoin       (témoin sélectionné)
//   collect_info_from_temoin (questionnaire + url_audio)
//   login_user              (utilisateur connecté)

import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../create_table/create_table_temoin.dart';

class SaveQuestionnaire {
  static const _uuid = Uuid();

  /// Sauvegarde un questionnaire complet avec son enregistrement audio.
  ///
  /// [userId]         → id de login_user (utilisateur connecté)
  /// [temoinId]       → id de info_perso_temoin (témoin sélectionné)
  /// [accompagnant]   → champ libre "accompagnants présents"
  /// [lieu]           → lieu de l'enregistrement
  /// [periodeEvoquee] → ex: "Années 50", "Avant-guerre"
  /// [themes]         → liste de tags sélectionnés, ex: ['Enfance', 'Travail']
  /// [sujetDuJour]    → note courte sur le sujet
  /// [urlAudio]       → chemin local du fichier audio enregistré
  static Future<String> save({
    required String       userId,
    required String       temoinId,
    String?               accompagnant,
    String?               lieu,
    String?               periodeEvoquee,
    required List<String> themes,
    String?               sujetDuJour,
    String?               urlAudio,
  }) async {
    final db = CreateTableTemoin.db;
    final id = _uuid.v4();

    final questionnaire = [
      {'champ': 'temoin_id',       'valeur': temoinId},
      {'champ': 'accompagnant',    'valeur': accompagnant   ?? ''},
      {'champ': 'lieu',            'valeur': lieu           ?? ''},
      {'champ': 'periode_evoquee', 'valeur': periodeEvoquee ?? ''},
      {'champ': 'themes',          'valeur': themes.join(',')},
      {'champ': 'sujet_du_jour',   'valeur': sujetDuJour    ?? ''},
    ];

    await db.insert(
      'collect_info_from_temoin',
      {
        'id':            id,
        'user_id':       userId,
        'questionnaire': jsonEncode(questionnaire),
        'url_audio':     urlAudio,
        'created_at':    DateTime.now().toIso8601String(),
      },
    );

    return id;
  }

  /// Met à jour uniquement l'url_audio après enregistrement
  static Future<void> updateAudio({
    required String collectId,
    required String urlAudio,
  }) async {
    final db = CreateTableTemoin.db;

    await db.update(
      'collect_info_from_temoin',
      {'url_audio': urlAudio},
      where:     'id = ?',
      whereArgs: [collectId],
    );
  }

  /// Récupère tous les questionnaires d'un utilisateur
  /// avec le nom/prénom du témoin associé via json_extract
  static Future<List<Map<String, dynamic>>> getByUser(String userId) async {
    final db = CreateTableTemoin.db;

    final rows = await db.rawQuery('''
      SELECT
        c.id,
        c.questionnaire,
        c.url_audio,
        c.created_at,
        t.nom,
        t.prenom
      FROM collect_info_from_temoin c
      LEFT JOIN info_perso_temoin t
        ON json_extract(c.questionnaire, '\$[0].valeur') = t.id
      WHERE c.user_id = ?
      ORDER BY c.created_at DESC
    ''', [userId]);

    return rows.map((row) {
      final r = Map<String, dynamic>.from(row);
      r['questionnaire'] = jsonDecode(r['questionnaire'] as String);
      return r;
    }).toList();
  }
}
