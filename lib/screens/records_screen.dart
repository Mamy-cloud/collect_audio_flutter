import 'dart:io';
import 'package:flutter/material.dart';
import '../database/local_database.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});
  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  List<Map<String, dynamic>> _temoins = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemoins();
  }

  Future<void> _loadTemoins() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final data = await LocalDatabase.getAllTemoins();
    if (!mounted) return;
    setState(() {
      _temoins   = data;
      _isLoading = false;
    });
  }

  Future<void> _deleteTemoin(Map<String, dynamic> temoin) async {
    // Confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D27),
        title: const Text('Supprimer', style: TextStyle(color: Colors.white)),
        content: const Text(
            'Supprimer ce témoin et son fichier audio localement ?',
            style: TextStyle(color: Color(0xFF8A8F9E))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler',
                style: TextStyle(color: Color(0xFF8A8F9E))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    // Annulé ou widget démonté → on ne fait rien
    if (confirm != true) return;
    if (!mounted) return;

    // 1. Supprimer le fichier audio local s'il existe
    final audioPath = temoin['chemin_audio'] as String?;
    if (audioPath != null) {
      try {
        final file = File(audioPath);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }

    // 2. Supprimer la ligne SQLite
    await LocalDatabase.deleteTemoin(temoin['id'] as int);

    // 3. Retirer l'élément de la liste en mémoire — pas de rechargement,
    //    pas de navigation, l'utilisateur reste sur l'onglet
    if (!mounted) return;
    setState(() {
      _temoins.removeWhere((t) => t['id'] == temoin['id']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D27),
        title: const Text('Enregistrements',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF3ECF8E)),
            onPressed: _loadTemoins,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(
              color: Color(0xFF3ECF8E)))
          : _temoins.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  color: const Color(0xFF3ECF8E),
                  onRefresh: _loadTemoins,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _temoins.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _TemoinCard(
                      temoin:   _temoins[i],
                      onDelete: () => _deleteTemoin(_temoins[i]),
                    ),
                  ),
                ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.folder_open_outlined,
            size: 64, color: Colors.white.withValues(alpha: 0.15)),
        const SizedBox(height: 16),
        const Text('Aucun enregistrement',
            style: TextStyle(color: Color(0xFF8A8F9E), fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Remplissez un formulaire pour commencer',
            style: TextStyle(color: Color(0xFF3D4155), fontSize: 13)),
      ],
    ),
  );
}

// ── Card témoin ───────────────────────────────────────────────────────────────

class _TemoinCard extends StatelessWidget {
  final Map<String, dynamic> temoin;
  final VoidCallback onDelete;

  const _TemoinCard({required this.temoin, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final hasAudio = temoin['chemin_audio'] != null;
    final nom      = '${temoin['prenom'] ?? ''} ${temoin['nom'] ?? ''}'.trim();
    final date     = temoin['date_creation'] != null
        ? _formatDate(temoin['date_creation'] as String)
        : '—';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D27),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2D3142)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF3ECF8E).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('#${temoin['id']}',
                    style: const TextStyle(
                        color: Color(0xFF3ECF8E),
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(nom.isEmpty ? 'Sans nom' : nom,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.redAccent, size: 20),
                onPressed: onDelete,
                tooltip: 'Supprimer le témoin et l\'audio',
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(Icons.cake_outlined, temoin['date_naissance'] ?? '—'),
                const SizedBox(height: 6),
                _infoRow(Icons.location_on_outlined,
                    [temoin['departement'], temoin['region']]
                        .where((v) => v != null && v.toString().isNotEmpty)
                        .join(' — ')),
                const SizedBox(height: 6),
                _infoRow(Icons.access_time_outlined, date),
                const SizedBox(height: 8),

                if (hasAudio)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3ECF8E).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: const Color(0xFF3ECF8E).withValues(alpha: 0.2)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.audio_file,
                          color: Color(0xFF3ECF8E), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (temoin['chemin_audio'] as String).split('/').last,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (temoin['duree_audio'] != null)
                              Text(temoin['duree_audio'] as String,
                                  style: const TextStyle(
                                      color: Color(0xFF8A8F9E), fontSize: 11)),
                          ],
                        ),
                      ),
                    ]),
                  )
                else
                  Row(children: [
                    const Icon(Icons.mic_off_outlined,
                        color: Color(0xFF3D4155), size: 14),
                    const SizedBox(width: 6),
                    const Text('Aucun audio',
                        style: TextStyle(color: Color(0xFF3D4155), fontSize: 12)),
                  ]),

                const SizedBox(height: 8),
                Row(children: [
                  Icon(
                    temoin['accept_rgpd'] == 1
                        ? Icons.verified_outlined
                        : Icons.cancel_outlined,
                    size: 13,
                    color: temoin['accept_rgpd'] == 1
                        ? const Color(0xFF3ECF8E)
                        : const Color(0xFF3D4155),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    temoin['accept_rgpd'] == 1 ? 'RGPD accepté' : 'RGPD non accepté',
                    style: TextStyle(
                      fontSize: 11,
                      color: temoin['accept_rgpd'] == 1
                          ? const Color(0xFF3ECF8E)
                          : const Color(0xFF3D4155),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 14, color: const Color(0xFF8A8F9E)),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          value.isEmpty ? '—' : value,
          style: const TextStyle(color: Color(0xFF8A8F9E), fontSize: 12),
        ),
      ),
    ],
  );

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/'
             '${d.month.toString().padLeft(2, '0')}/'
             '${d.year}  ${d.hour.toString().padLeft(2, '0')}:'
             '${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
