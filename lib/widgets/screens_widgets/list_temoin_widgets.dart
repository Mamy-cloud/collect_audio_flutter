import 'package:flutter/material.dart';
import '../global/app_styles.dart';

// ── Titre Liste témoin ────────────────────────────────────────────────────────

class ListTemoinTitle extends StatelessWidget {
  const ListTemoinTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Liste témoin',
        style: TextStyle(
          fontSize:      22,
          fontWeight:    FontWeight.w700,
          color:         AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

// ── Barre de recherche ────────────────────────────────────────────────────────

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const SearchField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:   controller,
      style:        AppTextStyles.input,
      onChanged:    onChanged,
      keyboardType: TextInputType.text,
      decoration: AppInputDecoration.of('Rechercher un témoin').copyWith(
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textMuted,
          size:  20,
        ),
      ),
    );
  }
}

// ── Card témoin ───────────────────────────────────────────────────────────────

class TemoinCard extends StatelessWidget {
  final Map<String, dynamic> temoin;
  const TemoinCard({super.key, required this.temoin});

  @override
  Widget build(BuildContext context) {
    final nom    = '${temoin['prenom'] ?? ''} ${temoin['nom'] ?? ''}'.trim();
    final region = temoin['region'] ?? '—';
    final date   = temoin['date_creation'] != null
        ? _formatDate(temoin['date_creation'] as String)
        : '—';

    return Container(
      margin:     const EdgeInsets.only(bottom: 12),
      padding:    const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(children: [
        // Avatar initiales
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color:        Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(22),
            border:       Border.all(color: Colors.white24),
          ),
          child: Center(
            child: Text(
              _initiales(nom),
              style: const TextStyle(
                color:      AppColors.textPrimary,
                fontSize:   16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nom.isEmpty ? 'Sans nom' : nom,
                  style: const TextStyle(
                      color:      AppColors.textPrimary,
                      fontSize:   14,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(region,
                  style: const TextStyle(
                      color:   AppColors.textMuted,
                      fontSize: 12)),
            ],
          ),
        ),
        Text(date,
            style: const TextStyle(
                color:   AppColors.textMuted,
                fontSize: 11)),
      ]),
    );
  }

  String _initiales(String nom) {
    final parts = nom.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/'
             '${d.month.toString().padLeft(2, '0')}/'
             '${d.year}';
    } catch (_) {
      return iso;
    }
  }
}

// ── État vide ─────────────────────────────────────────────────────────────────

class EmptyTemoinState extends StatelessWidget {
  const EmptyTemoinState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline,
              size: 56, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          const Text('Aucun témoin enregistré',
              style: TextStyle(color: AppColors.textMuted, fontSize: 15)),
          const SizedBox(height: 6),
          const Text('Ajoutez un témoin pour commencer',
              style: TextStyle(color: Color(0xFF555555), fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Bouton Ajouter un témoin ──────────────────────────────────────────────────

class AddTemoinButton extends StatelessWidget {
  final VoidCallback? onTap;
  const AddTemoinButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:        Colors.black,
          borderRadius: BorderRadius.circular(10),
          border:       Border.all(color: Colors.white, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.add,
                  color: Colors.black, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'Ajouter un témoin',
              style: TextStyle(
                color:      Colors.white,
                fontSize:   14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
