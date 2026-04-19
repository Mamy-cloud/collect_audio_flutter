// enregistrement_screen.dart
// Liste des témoins avec barre de recherche
// Clic → nouvelle page avec toutes les infos + collectes

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../database/create_table/create_table_temoin.dart';
import '../../../widgets/global/app_styles.dart';
import '../widgets/screens_widgets/save_local_widget.dart';

class EnregistrementScreen extends StatefulWidget {
  const EnregistrementScreen({super.key});

  @override
  State<EnregistrementScreen> createState() => _EnregistrementScreenState();
}

class _EnregistrementScreenState extends State<EnregistrementScreen> {
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _temoins    = [];
  List<Map<String, dynamic>> _filtered   = [];
  bool                       _isLoading  = true;

  @override
  void initState() {
    super.initState();
    _loadTemoins();
  }

  Future<void> _loadTemoins() async {
    final db   = CreateTableTemoin.db;
    final rows = await db.query(
      'info_perso_temoin',
      orderBy: 'nom ASC',
    );
    setState(() {
      _temoins   = rows;
      _filtered  = rows;
      _isLoading = false;
    });
  }

  void _onSearch(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      _filtered = q.isEmpty
          ? _temoins
          : _temoins.where((t) =>
              (t['nom']    as String).toLowerCase().contains(q) ||
              (t['prenom'] as String).toLowerCase().contains(q),
            ).toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation:       0,
        title: const Text(
          'Enregistrements',
          style: TextStyle(
            fontSize:   17,
            fontWeight: FontWeight.w600,
            color:      AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [

          // ── Barre de recherche ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              style:      AppTextStyles.input,
              onChanged:  _onSearch,
              decoration: AppInputDecoration.of(
                'Rechercher un témoin',
                hint: 'Nom ou prénom…',
              ),
            ),
          ),

          // ── Liste ────────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : _filtered.isEmpty
                    ? const EnregistrementEmptyState()
                    : ListView.builder(
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final t = _filtered[i];
                          return TemoinEnregistrementCard(
                            temoin: t,
                            onTap:  () => context.push(
                              '/enregistrement/detail',
                              extra: t,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
