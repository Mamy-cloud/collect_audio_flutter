import 'package:flutter/material.dart';
import '../database/local_database.dart';
import '../widgets/network_status_card.dart';
import '../widgets/progress_bar.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});
  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  int  _pendingCount = 0;
  bool _isOnline     = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    // Compte tous les témoins en attente de transfert
    final temoins = await LocalDatabase.getAllTemoins();
    if (mounted) {
      setState(() {
        _pendingCount = temoins.length;
        // TODO : vérifier la connectivité réseau quand FastAPI sera prêt
        _isOnline = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D27),
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
            const Text('Envoyez les enregistrements locaux vers le serveur',
                style: TextStyle(color: Color(0xFF8A8F9E), fontSize: 13)),
            const SizedBox(height: 28),

            // ── Statut réseau ─────────────────────────────────────────────
            NetworkStatusCard(isOnline: _isOnline),
            const SizedBox(height: 16),

            // ── Carte données en attente ──────────────────────────────────
            _pendingCard(),
            const SizedBox(height: 20),

            const Spacer(),

            // ── Bouton transfert (désactivé jusqu'à FastAPI) ──────────────
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: null, // activé quand FastAPI sera connecté
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3ECF8E),
                  foregroundColor: Colors.black,
                  disabledBackgroundColor:
                      const Color(0xFF3ECF8E).withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.cloud_upload_outlined, size: 22),
                label: const Text('Envoyer vers le cloud',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 8),

            // ── Mention en attente ────────────────────────────────────────
            const Center(
              child: Text(
                'Fonctionnalité disponible dès que FastAPI sera connecté',
                style: TextStyle(color: Color(0xFF3D4155), fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),

            // ── Actualiser ────────────────────────────────────────────────
            TextButton.icon(
              onPressed: _checkStatus,
              icon:  const Icon(Icons.refresh,
                  color: Color(0xFF8A8F9E), size: 16),
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
