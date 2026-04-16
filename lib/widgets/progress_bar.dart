import 'package:flutter/material.dart';

/// Barre de progression animée style WhatsApp
/// Animation infinie — avance et revient en boucle
class AnimatedProgressBar extends StatefulWidget {
  const AnimatedProgressBar({super.key});

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        height: 4,
        decoration: BoxDecoration(
          color:        const Color(0xFF2D3142),
          borderRadius: BorderRadius.circular(2),
        ),
        child: FractionallySizedBox(
          alignment:   Alignment.centerLeft,
          widthFactor: _anim.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: const LinearGradient(
                colors: [Color(0xFF3ECF8E), Color(0xFF00D4AA)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3ECF8E).withValues(alpha: 0.6),
                  blurRadius:  8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
