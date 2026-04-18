import '../conserve_data/conserve_data_to_sqlite.dart';

class ResearchTemoin {

  /// Recherche les témoins dont le nom OU le prénom
  /// contient [query] (insensible à la casse).
  /// Retourne tous les témoins si [query] est vide.
  static Future<List<Map<String, dynamic>>> search(String query) async {
    final all = await ConserveDataToSqlite.getAllInfoPersoTemoin();

    if (query.trim().isEmpty) return all;

    final q = query.trim().toLowerCase();

    return all.where((t) {
      final nom    = (t['nom']    as String? ?? '').toLowerCase();
      final prenom = (t['prenom'] as String? ?? '').toLowerCase();
      return nom.contains(q) || prenom.contains(q);
    }).toList();
  }
}
