import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../create_table/create_table_temoin.dart';

class ConserveDataToSqlite {
  static const _uuid = Uuid();

  // ── Copie l'image dans le dossier privé de l'app ──────────────────────────

  /// Copie le fichier image source vers le dossier documents de l'app.
  /// Retourne le chemin de destination.
  static Future<String> _copyImageToAppDir(String sourcePath) async {
    final Directory appDir;

    // Linux → getApplicationDocumentsDirectory
    // Android/iOS → getApplicationSupportDirectory
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
      appDir = await getApplicationDocumentsDirectory();
    } else {
      appDir = await getApplicationSupportDirectory();
    }

    final imgDir  = Directory('${appDir.path}/images');
    await imgDir.create(recursive: true);

    final fileName = 'temoin_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final destPath = '${imgDir.path}/$fileName';

    await File(sourcePath).copy(destPath);
    return destPath;
  }

  // ── INSERT info_perso_temoin ──────────────────────────────────────────────

  static Future<String> insertInfoPersoTemoin({
    required String nom,
    required String prenom,
    String? dateNaissance,
    String? departement,
    String? region,
    String? imgTemoinPath,     // chemin temporaire de l'image choisie
  }) async {
    final id = _uuid.v4();

    // Si une image est fournie, on la copie dans le dossier privé de l'app
    String? imgDestPath;
    if (imgTemoinPath != null) {
      imgDestPath = await _copyImageToAppDir(imgTemoinPath);
    }

    final Map<String, dynamic> data = {
      'id':             id,
      'nom':            nom,
      'prenom':         prenom,
      'date_naissance': dateNaissance,
      'departement':    departement,
      'region':         region,
      'img_temoin':     imgDestPath,    // chemin permanent stocké
      'date_creation':  DateTime.now().toIso8601String(),
    };

    await CreateTableTemoin.db.insert('info_perso_temoin', data);
    return id;
  }

  // ── SELECT tous les témoins ───────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getAllInfoPersoTemoin() async {
    return await CreateTableTemoin.db.query(
      'info_perso_temoin',
      orderBy: 'date_creation DESC',
    );
  }

  // ── SELECT par id ─────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getInfoPersoTemoinById(
      String id) async {
    final result = await CreateTableTemoin.db.query(
      'info_perso_temoin',
      where:     'id = ?',
      whereArgs: [id],
      limit:     1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ── DELETE ────────────────────────────────────────────────────────────────

  static Future<void> deleteInfoPersoTemoin(String id) async {
    // Récupère le chemin de l'image pour la supprimer aussi
    final temoin = await getInfoPersoTemoinById(id);
    if (temoin != null && temoin['img_temoin'] != null) {
      final file = File(temoin['img_temoin'] as String);
      if (await file.exists()) await file.delete();
    }

    await CreateTableTemoin.db.delete(
      'info_perso_temoin',
      where:     'id = ?',
      whereArgs: [id],
    );
  }
}
