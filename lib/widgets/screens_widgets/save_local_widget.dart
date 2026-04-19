import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../global/app_styles.dart';
import '../../database/update_delete/modify_info_temoin.dart';
import '../../database/update_delete/delete_collect_questionnaire.dart';
import '../../screens/formulaire_creer_temoin_screen.dart';
import '../../screens/display_info_collect_screen.dart';

class EnregistrementEmptyState extends StatelessWidget {
  const EnregistrementEmptyState({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mic_none, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('Aucun témoin',
              style: AppTextStyles.headline
                  .copyWith(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text("Créez d'abord un témoin depuis l'onglet Témoins.",
              style: AppTextStyles.label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class TemoinEnregistrementCard extends StatelessWidget {
  final Map<String, dynamic> temoin;
  final VoidCallback onTap;
  const TemoinEnregistrementCard(
      {super.key, required this.temoin, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = temoin['prenom'] as String? ?? '?';
    final n = temoin['nom'] as String? ?? '?';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.inputFill,
                border: Border.all(color: const Color(0xFF444444)),
              ),
              child: Center(
                child: Text(
                  '${p[0].toUpperCase()}${n[0].toUpperCase()}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$p $n',
                      style: AppTextStyles.input
                          .copyWith(fontWeight: FontWeight.w600)),
                  if (temoin['date_naissance'] != null) ...[
                    const SizedBox(height: 3),
                    Text(temoin['date_naissance'] as String,
                        style: AppTextStyles.label),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── InfoPersoCard ──────────────────────────────────────────────────────────────

class InfoPersoCard extends StatelessWidget {
  final Map<String, dynamic> temoin;
  const InfoPersoCard({super.key, required this.temoin});

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit_outlined,
                  color: AppColors.textPrimary),
              title: const Text('Modifier',
                  style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) =>
                      FormulaireCreerTemoinScreen(temoin: temoin),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  color: Color(0xFFE53935)),
              title: const Text('Supprimer le témoin',
                  style: TextStyle(color: Color(0xFFE53935))),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                showDialog(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    title: const Text('Supprimer le témoin',
                        style: TextStyle(color: AppColors.textPrimary)),
                    content: Text(
                      'Supprimer "${temoin["prenom"]} ${temoin["nom"]}" et tous ses témoignages ?',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        child: const Text('Annuler',
                            style: TextStyle(color: AppColors.textMuted)),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(dialogCtx).pop();
                          final router = GoRouter.of(context);
                          try {
                            await ModifyInfoTemoin.delete(
                                temoin['id'] as String);
                            router.go('/notification_update_delete',
                                extra: {'success': true, 'message': null});
                          } catch (e) {
                            router.go('/notification_update_delete',
                                extra: {'success': false, 'message': e.toString()});
                          }
                        },
                        child: const Text('Supprimer',
                            style: TextStyle(color: Color(0xFFE53935))),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p       = temoin['prenom'] as String? ?? '?';
    final n       = temoin['nom'] as String? ?? '?';
    final imgPath = temoin['img_temoin'] as String?;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: () => _showOptions(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
              ),
              child: const Text('Options',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // ── Avatar — Image.file pour chemin local ────────────
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.inputFill,
                        border: Border.all(color: const Color(0xFF444444)),
                      ),
                      child: imgPath != null && File(imgPath).existsSync()
                          ? ClipOval(
                              child: Image.file(
                                File(imgPath),
                                fit: BoxFit.cover,
                                width: 52, height: 52,
                              ),
                            )
                          : Center(
                              child: Text(
                                '${p[0].toUpperCase()}${n[0].toUpperCase()}',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary),
                              ),
                            ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$p $n',
                            style: AppTextStyles.input.copyWith(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                        if (temoin['date_naissance'] != null)
                          Text(temoin['date_naissance'] as String,
                              style: AppTextStyles.label),
                      ],
                    ),
                  ],
                ),
                if (temoin['departement'] != null ||
                    temoin['region'] != null) ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFF333333)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 15, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        [temoin['departement'], temoin['region']]
                            .where((v) => v != null)
                            .join(', '),
                        style: AppTextStyles.label,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── CollecteEmptyState ─────────────────────────────────────────────────────────

class CollecteEmptyState extends StatelessWidget {
  const CollecteEmptyState({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Center(
        child: Text('Aucun témoignage enregistré pour ce témoin.',
            style: AppTextStyles.label, textAlign: TextAlign.center),
      ),
    );
  }
}

// ── CollecteCard ───────────────────────────────────────────────────────────────

class CollecteCard extends StatelessWidget {
  final Map<String, dynamic> collecte;
  const CollecteCard({super.key, required this.collecte});

  String _val(List<dynamic> q, String champ) {
    try {
      return q.firstWhere((e) => e['champ'] == champ,
              orElse: () => {'valeur': ''})['valeur'] as String? ?? '';
    } catch (_) {
      return '';
    }
  }

  void _showOptions(BuildContext context) {
    final String collectId = collecte['id'] as String;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  color: Color(0xFFE53935)),
              title: const Text('Supprimer ce témoignage',
                  style: TextStyle(color: Color(0xFFE53935))),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                showDialog(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    title: const Text('Supprimer le témoignage',
                        style: TextStyle(color: AppColors.textPrimary)),
                    content: const Text(
                      'Ce témoignage et son enregistrement audio seront supprimés définitivement.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        child: const Text('Annuler',
                            style: TextStyle(color: AppColors.textMuted)),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(dialogCtx).pop();
                          final router = GoRouter.of(context);
                          try {
                            await DeleteCollectQuestionnaire.delete(collectId);
                            router.go('/notification_update_delete',
                                extra: {'success': true, 'message': null});
                          } catch (e) {
                            router.go('/notification_update_delete',
                                extra: {'success': false, 'message': e.toString()});
                          }
                        },
                        child: const Text('Supprimer',
                            style: TextStyle(color: Color(0xFFE53935))),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q      = collecte['questionnaire'] as List<dynamic>? ?? [];
    final lieu   = _val(q, 'lieu');
    final period = _val(q, 'periode_evoquee');
    final themes = _val(q, 'themes');
    final sujet  = _val(q, 'sujet_du_jour');
    final accomp = _val(q, 'accompagnant');
    final date   = (collecte['created_at'] as String? ?? '').split('T').first;
    final audio  = collecte['url_audio'] as String?;

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => DisplayInfoCollectScreen(collecte: collecte),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _showOptions(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textMuted,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                ),
                child: const Text('Options',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(date, style: AppTextStyles.label),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFF2A2A2A)),
                  const SizedBox(height: 12),
                  if (lieu.isNotEmpty)
                    _QRow(icon: Icons.location_on_outlined,
                        label: 'Lieu', value: lieu),
                  if (period.isNotEmpty)
                    _QRow(icon: Icons.access_time_outlined,
                        label: 'Période', value: period),
                  if (accomp.isNotEmpty)
                    _QRow(icon: Icons.people_outline,
                        label: 'Accompagnants', value: accomp),
                  if (sujet.isNotEmpty)
                    _QRow(icon: Icons.notes_outlined,
                        label: 'Sujet', value: sujet),
                  if (themes.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: themes.split(',').map((t) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(t.trim(),
                            style: AppTextStyles.label.copyWith(fontSize: 11)),
                      )).toList(),
                    ),
                  ],
                  if (audio != null) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFF2A2A2A)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.audio_file_outlined,
                            size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(audio,
                              style: AppTextStyles.label.copyWith(fontSize: 11),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _QRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text('$label : ',
              style: AppTextStyles.label.copyWith(fontSize: 12)),
          Expanded(
            child: Text(value,
                style: AppTextStyles.input.copyWith(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
