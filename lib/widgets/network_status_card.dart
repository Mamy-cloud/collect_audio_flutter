import 'package:flutter/material.dart';

class NetworkStatusCard extends StatelessWidget {
  final bool isOnline;

  const NetworkStatusCard({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D27),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isOnline
              ? const Color(0xFF3ECF8E).withValues(alpha: 0.4)
              : Colors.red.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vérification réseau internet',
            style: TextStyle(
              color:       Color(0xFF8A8F9E),
              fontSize:    11,
              fontWeight:  FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            // Point lumineux vert / rouge
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? const Color(0xFF3ECF8E) : Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: (isOnline
                        ? const Color(0xFF3ECF8E)
                        : Colors.red).withValues(alpha: 0.5),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isOnline
                    ? 'Connexion disponible — transfert des fichiers vers le cloud'
                    : 'Pas de connexion',
                style: TextStyle(
                  color: isOnline
                      ? const Color(0xFF3ECF8E)
                      : Colors.red.shade300,
                  fontSize:   14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
