import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'lamp_geometry.dart';

class PullCordController {
  PullCordController(TickerProvider vsync) {
    _pullController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 15),
    );
    _glowController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 15),
    );
    _swingController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 15),
    );

    pullAnimation = CurvedAnimation(
      parent: _pullController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );
    glowAnimation = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    cordListenable = Listenable.merge([
      _pullController,
      _swingController,
      isPulling,
      dragOffset,
    ]);
    lampListenable = Listenable.merge([
      cordListenable,
      _glowController,
    ]);
  }

  late final AnimationController _pullController;
  late final AnimationController _glowController;
  late final AnimationController _swingController;

  late final Animation<double> pullAnimation;
  late final Animation<double> glowAnimation;

  /// Rebuilds cord painting + knob position.
  late final Listenable cordListenable;

  /// Rebuilds the full lamp paint (includes [cordListenable] + glow).
  late final Listenable lampListenable;

  final ValueNotifier<bool> isOn = ValueNotifier(false);
  final ValueNotifier<bool> isPulling = ValueNotifier(false);
  final ValueNotifier<double> dragOffset = ValueNotifier(0);

  double _swingAmplitude = 0.28;

  double get pullProgress => isPulling.value
      ? (dragOffset.value / LampGeometry.maxPull)
      : pullAnimation.value;

  /// Damped pendulum angle (0 = hanging straight down).
  double get swingAngle {
    final t = _swingController.value;
    if (t <= 0 || t >= 1) return 0;
    const decay = 3.4;
    const cycles = 2.75;
    return _swingAmplitude *
        math.exp(-decay * t) *
        math.sin(cycles * 2 * math.pi * t);
  }

  void dispose() {
    _pullController.dispose();
    _glowController.dispose();
    _swingController.dispose();
    isOn.dispose();
    isPulling.dispose();
    dragOffset.dispose();
  }

  Future<void> toggleLight() async {
    HapticFeedback.mediumImpact();
    isOn.value = !isOn.value;

    if (isOn.value) {
      await _glowController.forward();
    } else {
      await _glowController.reverse();
    }
  }

  void _startSwing(double pulledAmount) {
    _swingAmplitude = 0.14 +
        (pulledAmount / LampGeometry.maxPull).clamp(0.0, 1.0) * 0.34;
    _swingController.forward(from: 0);
  }

  Future<void> _releaseWithMidSwing(double pulledAmount) async {
    var swingStarted = false;

    void onPullTick() {
      if (swingStarted) return;
      if (_pullController.value <= 0.9) {
        swingStarted = true;
        _startSwing(pulledAmount);
      }
    }

    _pullController.addListener(onPullTick);
    try {
      await _pullController.reverse();
      if (!swingStarted) {
        _startSwing(pulledAmount);
      }
    } finally {
      _pullController.removeListener(onPullTick);
    }
  }

  Future<void> playPullRelease(double pulledAmount) async {
    final shouldToggle = pulledAmount >= LampGeometry.toggleThreshold;

    _pullController.value =
        (pulledAmount / LampGeometry.maxPull).clamp(0.0, 1.0);
    await _releaseWithMidSwing(pulledAmount);

    if (shouldToggle) {
      await toggleLight();
    }
  }

  void onDragStart(DragStartDetails _) {
    isPulling.value = true;
    dragOffset.value = 0;
  }

  void onDragUpdate(DragUpdateDetails details) {
    dragOffset.value =
        (dragOffset.value + details.delta.dy).clamp(0.0, LampGeometry.maxPull);
  }

  Future<void> onDragEnd(DragEndDetails _) async {
    final pulled = dragOffset.value;
    isPulling.value = false;
    dragOffset.value = 0;
    await playPullRelease(pulled);
  }

  Future<void> onTapPull() async {
    await _pullController.forward(from: 0);
    await _releaseWithMidSwing(LampGeometry.maxPull * 0.85);
    await toggleLight();
  }
}
