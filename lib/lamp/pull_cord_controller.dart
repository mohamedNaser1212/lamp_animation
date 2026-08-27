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
    _intensityController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 420),
      value: 0.7,
    );
    _flickerController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1800),
    );
    _ambientController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 8),
    )..repeat();

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
      _intensityController,
      _flickerController,
      _ambientController,
    ]);
  }

  late final AnimationController _pullController;
  late final AnimationController _glowController;
  late final AnimationController _swingController;
  late final AnimationController _intensityController;
  late final AnimationController _flickerController;
  late final AnimationController _ambientController;

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
  double _intensityTarget = 0.7;

  /// 0–1 brightness when the lamp is on.
  double get intensity => _intensityController.value;

  AnimationController get intensityListenable => _intensityController;

  /// Soft breathing / flicker layered on glow while the lamp is lit.
  double get flicker {
    if (!isOn.value || glowAnimation.value <= 0) return 1;
    final t = _flickerController.value;
    final ambient = _ambientController.value;
    return 0.93 +
        0.05 * math.sin(t * math.pi * 2) +
        0.02 * math.sin(ambient * math.pi * 6);
  }

  /// Glow used by the painter: on/off × brightness × flicker.
  double get effectiveGlow => glowAnimation.value * intensity * flicker;

  double get ambientPhase => _ambientController.value;

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
    _intensityController.dispose();
    _flickerController.dispose();
    _ambientController.dispose();
    isOn.dispose();
    isPulling.dispose();
    dragOffset.dispose();
  }

  Future<void> setIntensity(double value) async {
    _intensityTarget = value.clamp(0.08, 1.0);
    await _intensityController.animateTo(
      _intensityTarget,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void setIntensityImmediate(double value) {
    _intensityTarget = value.clamp(0.08, 1.0);
    _intensityController.value = _intensityTarget;
  }

  Future<void> toggleLight() async {
    HapticFeedback.mediumImpact();
    isOn.value = !isOn.value;

    if (isOn.value) {
      _flickerController.repeat(reverse: true);
      await _glowController.forward();
    } else {
      await _glowController.reverse();
      _flickerController
        ..stop()
        ..value = 0;
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
