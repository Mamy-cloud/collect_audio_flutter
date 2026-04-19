// list_collect_data.dart
// Liste des questionnaires et enregistrements audio d'un témoin

import 'dart:convert';
import 'package:flutter/material.dart';
import '../../database/create_table/create_table_temoin.dart';
import '../../widgets/global/app_styles.dart';
import '../../widgets/screens_widgets/save_local_widget.dart';

class ListCollectData extends StatefulWidget {
  final Map<String, dynamic> temoin;

  const ListCollectData({super.key, required this.temoin});

  @override
  State<ListCollectData> createState() => _ListCollectDataState();
}

class _ListCollectDataState extends State<ListCollectData> {
  List<Map<String, dynamic>> _collectes = [];
  bool                       _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollectes();
  }

  Future<void> _loadCollectes() async {
    final db   = CreateTableTemoin.db;
    final rows = await db.rawQuery('''
      SELECT
        c.id,
        c.questionnaire,
        c.url_audio,
        c.created_at
      FROM collect_info_from_temoin c
      WHERE json_extract(c.questionnaire, '\$[0].valeur') = ?
      ORDER BY c.created_at DESC
    ''', [widget.temoin['id']]);

    final collectes = rows.map((row) {
      final r = Map<String, dynamic>.from(row);
      try {
        r['questionnaire'] = jsonDecode(r['questionnaire'] as String);
      } catch (_) {
        r['questionnaire'] = [];
      }
      return r;
    }).toList();

    setState(() {
      _collectes = collectes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.temoin;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation:       0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          '${t['prenom']} ${t['nom']}',
          style: const TextStyle(
            fontSize:   17,
            fontWeight: FontWeight.w600,
            color:      AppColors.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Infos personnelles ──────────────────────────────────
                  InfoPersoCard(temoin: t),

                  const SizedBox(height: 24),

                  // ── Titre section ───────────────────────────────────────
                  Row(
                    children: [
                      const Text(
                        'Témoignages enregistrés',
                        style: TextStyle(
                          fontSize:      13,
                          fontWeight:    FontWeight.w600,
                          color:         AppColors.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:        AppColors.inputFill,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_collectes.length}',
                          style: AppTextStyles.label.copyWith(fontSize: 11),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Liste collectes ─────────────────────────────────────
                  if (_collectes.isEmpty)
                    const CollecteEmptyState()
                  else
                    ..._collectes.map((c) => CollecteCard(collecte: c)),

                ],
              ),
            ),
    );
  }
}
