import 'package:flutter/material.dart';

import '../lamp_geometry.dart';
import '../pull_cord_controller.dart';

/// Interactive pull-cord knob. Rebuilds only when
/// [PullCordController.cordListenable] notifies (pull, swing, drag).
class CordKnob extends StatelessWidget {
  const CordKnob({
    super.key,
    required this.controller,
  });

  final PullCordController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.cordListenable,
      builder: (context, _) {
        final pivot = LampGeometry.cordPivot();
        final ballCenter = LampGeometry.ballCenter(
          pivot: pivot,
          stringLength: LampGeometry.stringLength(controller.pullProgress),
          angle: controller.swingAngle,
        );

        return Positioned(
          left: ballCenter.dx - 28,
          top: ballCenter.dy - 28,
          width: 56,
          height: 56,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragStart: controller.onDragStart,
            onVerticalDragUpdate: controller.onDragUpdate,
            onVerticalDragEnd: controller.onDragEnd,
            onTap: controller.onTapPull,
            child: const Center(
              child: _KnobVisual(),
            ),
          ),
        );
      },
    );
  }
}

class _KnobVisual extends StatelessWidget {
  const _KnobVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: LampGeometry.ballSize,
      height: LampGeometry.ballSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFC9A227),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
