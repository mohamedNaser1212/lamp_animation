import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shared layout constants and cord geometry for the pull-cord lamp.
abstract final class LampGeometry {
  static const double canvasW = 220;
  static const double canvasH = 280;
  static const double maxPull = 48;
  static const double toggleThreshold = 28;
  static const double cordRestLength = 72;
  static const double ballSize = 18;
  static const double ballRadius = ballSize / 2;

  static Offset cordPivot() {
    final centerX = canvasW * 0.42;
    final shadeBottom = canvasH * 0.38;
    return Offset(centerX + 46, shadeBottom - 2);
  }

  static Offset ballCenter({
    required Offset pivot,
    required double stringLength,
    required double angle,
  }) {
    return Offset(
      pivot.dx + stringLength * math.sin(angle),
      pivot.dy + stringLength * math.cos(angle),
    );
  }

  static double stringLength(double pullProgress) {
    return cordRestLength + (maxPull * pullProgress) + ballRadius;
  }
}
