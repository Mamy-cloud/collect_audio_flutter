import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../database/conserve_data/conserve_data_to_sqlite.dart';
import '../../widgets/global/app_styles.dart';
import '../widgets/notifications_widget/notification_addtemoin_widgets.dart';

class NotificationAddTemoinScreen extends StatefulWidget {
  final Map<String, dynamic> temoinData;

  const NotificationAddTemoinScreen({
    super.key,
    required this.temoinData,
  });

  @override
  State<NotificationAddTemoinScreen> createState() =>
      _NotificationAddTemoinScreenState();
}

class _NotificationAddTemoinScreenState
    extends State<NotificationAddTemoinScreen> {

  bool    _success      = false;
  bool    _isLoading    = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _saveTemoin();
  }

  // ── Sauvegarde SQLite ─────────────────────────────────────────────────────

  Future<void> _saveTemoin() async {
    try {
      await ConserveDataToSqlite.insertInfoPersoTemoin(
        nom:           widget.temoinData['nom']            as String,
        prenom:        widget.temoinData['prenom']         as String,
        dateNaissance: widget.temoinData['date_naissance'] as String?,
        departement:   widget.temoinData['departement']    as String?,
        region:        widget.temoinData['region']         as String?,
      );

      if (!mounted) return;
      setState(() {
        _success   = true;
        _isLoading = false;
      });

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _success      = false;
        _isLoading    = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _goToList() {
    if (!mounted) return;
    context.go('/list_temoin');
  }

  void _retry() {
    setState(() {
      _isLoading    = true;
      _errorMessage = null;
    });
    _saveTemoin();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: _isLoading ? _buildLoading() : _buildResult(),
        ),
      ),
    );
  }

  // ── Loading ───────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 20),
          Text(
            'Enregistrement en cours...',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── Résultat succès ou erreur ─────────────────────────────────────────────

  Widget _buildResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // ── Icône ───────────────────────────────────────────────────────
          NotificationIcon(success: _success),

          const SizedBox(height: 24),

          // ── Titre ───────────────────────────────────────────────────────
          NotificationTitle(success: _success),

          const SizedBox(height: 12),

          // ── Message ─────────────────────────────────────────────────────
          NotificationMessage(
            success:      _success,
            errorMessage: _errorMessage,
          ),

          const SizedBox(height: 40),

          // ── Barre de progression (succès uniquement) ─────────────────────
          if (_success) ...[
            RedirectProgressBar(
              seconds:    3,
              onComplete: _goToList,
            ),
            const SizedBox(height: 32),
          ],

          if (!_success) const SizedBox(height: 32),

          // ── Bouton ──────────────────────────────────────────────────────
          NotificationBackButton(
            success: _success,
            onTap:   _success ? _goToList : _retry,
          ),
        ],
      ),
    );
  }
}
