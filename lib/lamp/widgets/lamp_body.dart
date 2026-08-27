import 'package:flutter/material.dart';

import '../lamp_geometry.dart';
import '../lamp_painter.dart';
import '../pull_cord_controller.dart';

class LampBody extends StatelessWidget {
  const LampBody({
    super.key,
    required this.controller,
    required this.isDark,
  });

  final PullCordController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.lampListenable,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(LampGeometry.canvasW, LampGeometry.canvasH),
          painter: LampPainter(
            isOn: controller.isOn.value,
            glow: controller.effectiveGlow,
            intensity: controller.intensity,
            pullProgress: controller.pullProgress,
            swingRadians: controller.swingAngle,
            isDark: isDark,
            ambientPhase: controller.ambientPhase,
          ),
        );
      },
    );
  }
}
