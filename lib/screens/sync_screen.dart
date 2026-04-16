import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../database/local_database.dart';
import '../services/resilient_sync_service.dart';
import '../widgets/network_status_card.dart';
import '../widgets/progress_bar.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});
  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  int    _pendingCount = 0;
  bool   _isOnline     = false;
  bool   _isSyncing    = false;
  String _statusMsg    = '';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final count  = await LocalDatabase.countPending();
    final online = await ResilientSyncService.isOnline();
    if (mounted) setState(() { _pendingCount = count; _isOnline = online; });
  }

  Future<void> _startSync() async {
    if (!_isOnline) { _snack('Aucune connexion internet', error: true); return; }

    setState(() { _isSyncing = true; _statusMsg = 'Transfert en cours...'; });

    final result = await ResilientSyncService.syncAll(
      onProgress: (synced, total) {
        if (mounted) setState(() => _statusMsg = 'Transfert $synced / $total...');
      },
    );

    if (mounted) {
      setState(() { _isSyncing = false; _statusMsg = ''; });
      await _checkStatus();
      _snack(
        result.isSuccess
            ? (result.uploaded > 0
                ? '${result.uploaded} enregistrement(s) transféré(s) ✓'
                : 'Aucun enregistrement en attente')
            : '${result.uploaded} transféré(s) — ${result.failed} échec(s)',
        success: result.isSuccess,
        error:   !result.isSuccess,
      );
    }
  }

  void _snack(String msg,
      {bool success = false, bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success
          ? Colors.green.shade600
          : error ? Colors.red.shade600 : null,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D27),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/formulaire'),
        ),
        title: const Text('Transfert cloud',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── Titre ─────────────────────────────────────────────────────
            const Text('Transférer vers le cloud',
                style: TextStyle(color: Colors.white, fontSize: 22,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Envoyez les enregistrements locaux vers Supabase',
                style: TextStyle(color: Color(0xFF8A8F9E), fontSize: 13)),
            const SizedBox(height: 28),

            // ── NetworkStatusCard ─────────────────────────────────────────
            NetworkStatusCard(isOnline: _isOnline),
            const SizedBox(height: 16),

            // ── Carte données en attente ──────────────────────────────────
            _pendingCard(),
            const SizedBox(height: 20),

            // ── AnimatedProgressBar ───────────────────────────────────────
            if (_isSyncing) ...[
              const AnimatedProgressBar(),
              const SizedBox(height: 8),
              Text(_statusMsg,
                  style: const TextStyle(color: Color(0xFF3ECF8E), fontSize: 12),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
            ],

            const Spacer(),

            // ── Bouton transfert ──────────────────────────────────────────
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: (_isSyncing || !_isOnline || _pendingCount == 0)
                    ? null : _startSync,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3ECF8E),
                  foregroundColor: Colors.black,
                  disabledBackgroundColor:
                      const Color(0xFF3ECF8E).withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: _isSyncing
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.cloud_upload_outlined, size: 22),
                label: Text(
                  _isSyncing ? 'Transfert en cours...' : 'Envoyer vers le cloud',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),

            // ── Actualiser ────────────────────────────────────────────────
            TextButton.icon(
              onPressed: _checkStatus,
              icon:  const Icon(Icons.refresh, color: Color(0xFF8A8F9E), size: 16),
              label: const Text('Actualiser le statut',
                  style: TextStyle(color: Color(0xFF8A8F9E), fontSize: 13)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _pendingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D27),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2D3142)),
      ),
      child: Row(children: [
        const Icon(Icons.storage_outlined,
            color: Color(0xFF8A8F9E), size: 28),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Données sauvegardées localement',
                style: TextStyle(color: Colors.white, fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('$_pendingCount enregistrement(s) en attente de transfert',
                style: const TextStyle(
                    color: Color(0xFF8A8F9E), fontSize: 12)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _pendingCount > 0
                ? Colors.orange.withValues(alpha: 0.15)
                : const Color(0xFF3ECF8E).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _pendingCount > 0
                  ? Colors.orange.withValues(alpha: 0.4)
                  : const Color(0xFF3ECF8E).withValues(alpha: 0.4)),
          ),
          child: Text(
            _pendingCount > 0 ? '$_pendingCount' : '✓',
            style: TextStyle(
              color: _pendingCount > 0
                  ? Colors.orange : const Color(0xFF3ECF8E),
              fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ]),
    );
  }
}
