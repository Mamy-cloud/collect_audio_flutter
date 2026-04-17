import 'package:flutter/material.dart';
import '../widgets/global/app_styles.dart';
import '../widgets/screens_widgets/list_temoin_widgets.dart';
import 'display_data_temoin_screen.dart';
import 'formulaire_creer_temoin_screen.dart';

class ListTemoinScreen extends StatefulWidget {
  const ListTemoinScreen({super.key});

  @override
  State<ListTemoinScreen> createState() => _ListTemoinScreenState();
}

class _ListTemoinScreenState extends State<ListTemoinScreen> {
  final _searchCtrl = TextEditingController();
  String _query     = '';

  // Clé pour rafraîchir DisplayDataTemoinScreen après ajout
  final GlobalKey<State> _displayKey = GlobalKey();

  void _ouvrirFormulaire() {
    showModalBottomSheet(
      context:             context,
      isScrollControlled:  true,
      backgroundColor:     Colors.transparent,
      builder: (_) => const FormulaireCreerTemoinScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [

              const SizedBox(height: 24),

              // ── Titre ──────────────────────────────────────────────────
              const ListTemoinTitle(),

              const SizedBox(height: 20),

              // ── Recherche ──────────────────────────────────────────────
              SearchField(
                controller: _searchCtrl,
                onChanged:  (v) => setState(() => _query = v),
              ),

              const SizedBox(height: 16),

              // ── Liste des témoins depuis SQLite ────────────────────────
              const Expanded(
                child: DisplayDataTemoinScreen(),
              ),
            ],
          ),
        ),
      ),

      // ── Bouton Ajouter ─────────────────────────────────────────────────
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AddTemoinButton(onTap: _ouvrirFormulaire),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}
