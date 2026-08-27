import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../lamp_geometry.dart';
import '../pull_cord_controller.dart';

class FireflyOrbit extends StatelessWidget {
  const FireflyOrbit({
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
        if (glow <= 0.05) return const SizedBox.shrink();

        final phase = controller.ambientPhase * math.pi * 2;
        final centerX = LampGeometry.canvasW * 0.42;
        final shadeY = LampGeometry.canvasH * 0.38;
        final rx = 48.0 + 10 * controller.intensity;
        final ry = 22.0 + 6 * controller.intensity;
        final pos = Offset(
          centerX + math.cos(phase * 1.3) * rx,
          shadeY - 8 + math.sin(phase * 1.3) * ry,
        );

        return Positioned(
          left: pos.dx - 6,
          top: pos.dy - 6,
          width: 12,
          height: 12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.lerp(
                const Color(0xFFB8F27A),
                const Color(0xFFFFF59D),
                0.4 + 0.4 * math.sin(phase * 3),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC6F56B).withValues(alpha: 0.55 * glow),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
