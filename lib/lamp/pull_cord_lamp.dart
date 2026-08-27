import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'lamp_geometry.dart';
import 'pull_cord_controller.dart';
import 'widgets/cord_knob.dart';
import 'widgets/dust_motes.dart';
import 'widgets/firefly_orbit.dart';
import 'widgets/lamp_body.dart';
import 'widgets/light_strength_dial.dart';

class PullCordLamp extends StatefulWidget {
  const PullCordLamp({super.key});

  @override
  State<PullCordLamp> createState() => _PullCordLampState();
}

class _PullCordLampState extends State<PullCordLamp>
    with TickerProviderStateMixin {
  late final PullCordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PullCordController(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _dayAmount {
    if (!_controller.isOn.value) return 0;
    return Curves.easeInOut.transform(_controller.intensity.clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller.lampListenable,
      builder: (context, _) {
        final day = _dayAmount;
        final night = 1 - day;
        final lampIsDarkScene = day < 0.45;
        final fg = Color.lerp(
          Colors.white,
          const Color(0xFF2C2416),
          day,
        )!;

        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _DayNightRoomPainter(
                  dayAmount: day,
                  glow: _controller.effectiveGlow,
                  phase: _controller.ambientPhase,
                ),
              ),
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          LightStrengthDial(
                            controller: _controller,
                            dayAmount: day,
                          ),
                          const SizedBox(width: 18),
                          SizedBox(
                            width: LampGeometry.canvasW,
                            height: LampGeometry.canvasH,
                            child: Stack(
                              children: [
                                LampBody(
                                  controller: _controller,
                                  isDark: lampIsDarkScene,
                                ),
                                DustMotes(controller: _controller),
                                // Firefly only in night / dusk
                                if (night > 0.35)
                                  Opacity(
                                    opacity: night,
                                    child: FireflyOrbit(
                                      controller: _controller,
                                    ),
                                  ),
                                CordKnob(controller: _controller),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // LampStatusLabel(
                      //   controller: _controller,
                      //   dayAmount: day,
                      // ),
                      const SizedBox(height: 10),
                      Text(
                        day > 0.55
                            ? 'صباح مشرق · اخفض السطوع لليل'
                            : 'ليل هادئ · ارفع السطوع للصباح',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: fg.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DayNightRoomPainter extends CustomPainter {
  _DayNightRoomPainter({
    required this.dayAmount,
    required this.glow,
    required this.phase,
  });

  final double dayAmount;
  final double glow;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final day = dayAmount;
    final night = 1 - day;

    // --- Sky gradient ---
    final nightTop = const Color(0xFF070B18);
    final nightMid = const Color(0xFF121A2E);
    final nightBot = const Color(0xFF1A1524);

    final dawnTop = const Color(0xFF5B7C9D);
    final dawnMid = const Color(0xFFE8A06A);
    final dawnBot = const Color(0xFFFFD9A8);

    final morningTop = const Color(0xFF87B8E8);
    final morningMid = const Color(0xFFBFDFFF);
    final morningBot = const Color(0xFFFFF4E0);

    // Blend night → dawn (0–0.45) → morning (0.45–1)
    Color top;
    Color mid;
    Color bot;
    if (day < 0.45) {
      final t = day / 0.45;
      top = Color.lerp(nightTop, dawnTop, t)!;
      mid = Color.lerp(nightMid, dawnMid, t)!;
      bot = Color.lerp(nightBot, dawnBot, t)!;
    } else {
      final t = ((day - 0.45) / 0.55).clamp(0.0, 1.0);
      top = Color.lerp(dawnTop, morningTop, t)!;
      mid = Color.lerp(dawnMid, morningMid, t)!;
      bot = Color.lerp(dawnBot, morningBot, t)!;
    }

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, mid, bot],
          stops: const [0.0, 0.42, 1.0],
        ).createShader(Offset.zero & size),
    );

    // Soft sun glow wash (morning)
    if (day > 0.2) {
      final sunGlow = Offset(size.width * 0.78, size.height * (0.28 - day * 0.08));
      canvas.drawCircle(
        sunGlow,
        size.width * 0.42,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFF0C2).withValues(alpha: 0.45 * day),
              const Color(0xFFFFC978).withValues(alpha: 0.12 * day),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(center: sunGlow, radius: size.width * 0.42),
          ),
      );
    }

    // Lamp warm pool (stronger at night when lamp is on)
    if (glow > 0.01 && night > 0.15) {
      final washCenter = Offset(size.width * 0.58, size.height * 0.62);
      canvas.drawCircle(
        washCenter,
        size.width * 0.5,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFD27A).withValues(alpha: 0.28 * glow * night),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(center: washCenter, radius: size.width * 0.5),
          ),
      );
    }

    // --- Moon (fades out as day rises) ---
    if (night > 0.05) {
      final moon = Offset(size.width * 0.82, size.height * 0.14);
      final moonA = night;
      canvas.drawCircle(
        moon,
        28,
        Paint()
          ..color = const Color(0xFFE8EEF8).withValues(alpha: 0.14 * moonA)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
      canvas.drawCircle(
        moon,
        16,
        Paint()
          ..color = const Color(0xFFD9E2F2).withValues(alpha: 0.65 * moonA),
      );
      canvas.drawCircle(
        moon + const Offset(5, -3),
        14,
        Paint()..color = nightTop.withValues(alpha: 0.65 * moonA),
      );
    }

    // --- Sun (rises with brightness) ---
    if (day > 0.15) {
      final sunY = size.height * (0.22 - (day - 0.15) * 0.08);
      final sun = Offset(size.width * 0.8, sunY);
      final sunA = ((day - 0.15) / 0.85).clamp(0.0, 1.0);
      canvas.drawCircle(
        sun,
        36,
        Paint()
          ..color = const Color(0xFFFFE08A).withValues(alpha: 0.35 * sunA)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
      );
      canvas.drawCircle(
        sun,
        18,
        Paint()
          ..color = Color.lerp(
            const Color(0xFFFFB347),
            const Color(0xFFFFF6C8),
            sunA,
          )!.withValues(alpha: 0.95 * sunA),
      );
    }

    // Stars — only at night
    if (night > 0.08) {
      final rng = math.Random(42);
      for (var i = 0; i < 48; i++) {
        final p = Offset(
          rng.nextDouble() * size.width,
          rng.nextDouble() * size.height * 0.45,
        );
        final twinkle =
            0.25 + 0.55 * (0.5 + 0.5 * math.sin(phase * math.pi * 2 + i));
        canvas.drawCircle(
          p,
          0.6 + rng.nextDouble() * 1.2,
          Paint()
            ..color = Colors.white.withValues(alpha: twinkle * night),
        );
      }
    }

    // Soft morning clouds
    if (day > 0.35) {
      final cloudA = ((day - 0.35) / 0.65).clamp(0.0, 1.0) * 0.55;
      _cloud(
        canvas,
        Offset(size.width * 0.2, size.height * 0.16),
        38,
        cloudA,
      );
      _cloud(
        canvas,
        Offset(size.width * 0.55, size.height * 0.11),
        28,
        cloudA * 0.85,
      );
    }

    // Window
    final window = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.06,
        size.height * 0.12,
        size.width * 0.2,
        size.height * 0.28,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(
      window,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(const Color(0xFF0A1222), const Color(0xFF9EC8F0), day)!,
            Color.lerp(const Color(0xFF152038), const Color(0xFFFFE0B8), day)!,
          ],
        ).createShader(window.outerRect),
    );
    final frameColor = Color.lerp(
      const Color(0xFF3A455C),
      const Color(0xFF8B7355),
      day,
    )!;
    canvas.drawRRect(
      window,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = frameColor.withValues(alpha: 0.85),
    );
    final wb = window.outerRect;
    canvas.drawLine(
      Offset(wb.center.dx, wb.top + 4),
      Offset(wb.center.dx, wb.bottom - 4),
      Paint()
        ..color = frameColor.withValues(alpha: 0.65)
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(wb.left + 4, wb.center.dy),
      Offset(wb.right - 4, wb.center.dy),
      Paint()
        ..color = frameColor.withValues(alpha: 0.65)
        ..strokeWidth = 2,
    );

    // Floor
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.78, size.width, size.height * 0.22),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Color.lerp(
              const Color(0xFF12101A),
              const Color(0xFFD4B896),
              day,
            )!,
          ],
        ).createShader(
          Rect.fromLTWH(0, size.height * 0.78, size.width, size.height * 0.22),
        ),
    );
  }

  void _cloud(Canvas canvas, Offset c, double r, double a) {
    final paint = Paint()..color = Colors.white.withValues(alpha: a);
    canvas.drawCircle(c, r, paint);
    canvas.drawCircle(c + Offset(-r * 0.7, 4), r * 0.7, paint);
    canvas.drawCircle(c + Offset(r * 0.65, 6), r * 0.75, paint);
  }

  @override
  bool shouldRepaint(covariant _DayNightRoomPainter oldDelegate) {
    return oldDelegate.dayAmount != dayAmount ||
        oldDelegate.glow != glow ||
        oldDelegate.phase != phase;
  }
}
