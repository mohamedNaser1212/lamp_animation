import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../lamp_geometry.dart';
import '../pull_cord_controller.dart';

class DustMotes extends StatelessWidget {
  const DustMotes({
    super.key,
    required this.controller,
  });

  final PullCordController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.lampListenable,
      builder: (context, _) {
        final glow = controller.effectiveGlow;
        if (glow <= 0.02) return const SizedBox.shrink();
        return CustomPaint(
          size: const Size(LampGeometry.canvasW, LampGeometry.canvasH),
          painter: _DustPainter(
            phase: controller.ambientPhase,
            glow: glow,
            intensity: controller.intensity,
          ),
        );
      },
    );
  }
}

class _DustPainter extends CustomPainter {
  _DustPainter({
    required this.phase,
    required this.glow,
    required this.intensity,
  });

  final double phase;
  final double glow;
  final double intensity;

  static final _seeds = List.generate(22, (i) {
    final rng = math.Random(i * 41 + 7);
    return (
      x: 0.28 + rng.nextDouble() * 0.36,
      y: 0.34 + rng.nextDouble() * 0.42,
      speed: 0.3 + rng.nextDouble() * 0.9,
      size: 0.8 + rng.nextDouble() * 1.8,
      drift: rng.nextDouble() * math.pi * 2,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width * 0.42;
    for (final s in _seeds) {
      final t = (phase * s.speed + s.drift) % 1.0;
      final y = (s.y + t * 0.22) % 0.55 + 0.32;
      final x = s.x + 0.04 * math.sin(phase * math.pi * 2 * s.speed + s.drift);
      final pos = Offset(x * size.width, y * size.height);

      // Soft cone: brighter near center / under shade
      final dx = (pos.dx - centerX).abs() / 55;
      final cone = (1 - dx).clamp(0.0, 1.0);

      final alpha = glow * intensity * cone * 0.55;
      if (alpha < 0.02) continue;

      canvas.drawCircle(
        pos,
        s.size,
        Paint()..color = const Color(0xFFFFF6D0).withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DustPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.glow != glow ||
        oldDelegate.intensity != intensity;
  }
}
