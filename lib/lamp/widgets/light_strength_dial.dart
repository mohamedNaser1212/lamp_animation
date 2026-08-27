import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../pull_cord_controller.dart';

class LightStrengthDial extends StatefulWidget {
  const LightStrengthDial({
    super.key,
    required this.controller,
    this.dayAmount = 0,
  });

  final PullCordController controller;
  final double dayAmount;

  @override
  State<LightStrengthDial> createState() => _LightStrengthDialState();
}

class _LightStrengthDialState extends State<LightStrengthDial> {
  static const double _trackH = 168;
  double? _lastHapticStep;

  void _fromDy(double localY) {
    final t = (1 - (localY / _trackH)).clamp(0.0, 1.0);
    widget.controller.setIntensityImmediate(0.08 + t * 0.92);
    final step = (t * 8).roundToDouble();
    if (_lastHapticStep != step) {
      _lastHapticStep = step;
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.controller.intensityListenable,
        widget.controller.isOn,
        widget.controller.lampListenable,
      ]),
      builder: (context, _) {
        final intensity = widget.controller.intensity;
        final isOn = widget.controller.isOn.value;
        final day = widget.dayAmount;
        final t = ((intensity - 0.08) / 0.92).clamp(0.0, 1.0);
        final fg = Color.lerp(
          Colors.white,
          const Color(0xFF2C2416),
          day,
        )!;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(intensity * 100).round()}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1,
                color: Color.lerp(
                  const Color(0xFF9AA3B2),
                  const Color(0xFFC9851A),
                  day,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              day > 0.55 ? 'صباح' : (day > 0.25 ? 'فجر' : 'ليل'),
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
                color: fg.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragStart: (d) => _fromDy(d.localPosition.dy),
              onVerticalDragUpdate: (d) => _fromDy(d.localPosition.dy),
              onTapDown: (d) => _fromDy(d.localPosition.dy),
              child: SizedBox(
                width: 56,
                height: _trackH,
                child: CustomPaint(
                  painter: _DimmerPainter(
                    progress: t,
                    active: isOn,
                    pulse: widget.controller.ambientPhase,
                    dayAmount: day,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Icon(
              day > 0.45 ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              size: 18,
              color: day > 0.45
                  ? const Color(0xFFE8A020).withValues(alpha: 0.9)
                  : fg.withValues(alpha: 0.45),
            ),
          ],
        );
      },
    );
  }
}

class _DimmerPainter extends CustomPainter {
  _DimmerPainter({
    required this.progress,
    required this.active,
    required this.pulse,
    required this.dayAmount,
  });

  final double progress;
  final bool active;
  final double pulse;
  final double dayAmount;

  @override
  void paint(Canvas canvas, Size size) {
    final day = dayAmount;
    final railFill = Color.lerp(
      const Color(0xFF1A1F2B),
      const Color(0xFFE8DCC8),
      day,
    )!;
    final railStroke = Color.lerp(
      Colors.white.withValues(alpha: 0.12),
      const Color(0xFF8B7355).withValues(alpha: 0.45),
      day,
    )!;
    final tickOff = Color.lerp(
      Colors.white.withValues(alpha: 0.18),
      const Color(0xFF8B7355).withValues(alpha: 0.35),
      day,
    )!;

    final rail = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: 18,
        height: size.height,
      ),
      const Radius.circular(12),
    );

    canvas.drawRRect(rail, Paint()..color = railFill);
    canvas.drawRRect(
      rail,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = railStroke,
    );

    const segments = 8;
    for (var i = 0; i <= segments; i++) {
      final y = size.height * (i / segments);
      final lit = (1 - i / segments) <= progress + 0.001;
      canvas.drawLine(
        Offset(size.width / 2 - 14, y),
        Offset(size.width / 2 - 8, y),
        Paint()
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round
          ..color = lit && active
              ? const Color(0xFFE8B84A).withValues(alpha: 0.75)
              : tickOff,
      );
    }

    final fillH = size.height * progress;
    if (fillH > 0) {
      final fillTop = size.height - fillH;
      final fillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width / 2 - 7, fillTop, 14, fillH),
        const Radius.circular(9),
      );

      final breath = 1 + 0.04 * math.sin(pulse * math.pi * 2);
      final low = Color.lerp(
        const Color(0xFF3D5A80),
        const Color(0xFFE8B84A),
        day,
      )!;
      final high = Color.lerp(
        const Color(0xFF9BB7D4),
        const Color(0xFFFFF1C1),
        day,
      )!;

      canvas.drawRRect(
        fillRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              active ? low : low.withValues(alpha: 0.4),
              active ? high : high.withValues(alpha: 0.35),
            ],
          ).createShader(fillRect.outerRect),
      );

      if (active) {
        canvas.drawRRect(
          fillRect.inflate(6 * breath),
          Paint()
            ..color = Color.lerp(
              const Color(0xFF7EB6FF),
              const Color(0xFFE8B84A),
              day,
            )!.withValues(alpha: 0.16 * progress)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
      }
    }

    final thumbY = size.height * (1 - progress);
    final thumb = Offset(size.width / 2, thumbY.clamp(10.0, size.height - 10));
    canvas.drawCircle(
      thumb,
      13,
      Paint()
        ..color = Color.lerp(
          const Color(0xFF2A3142),
          const Color(0xFFFFF8EE),
          day,
        )!,
    );
    canvas.drawCircle(
      thumb,
      13,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = active
            ? Color.lerp(
                const Color(0xFF9BB7D4),
                const Color(0xFFE8A020),
                day,
              )!
            : Colors.white38,
    );
    canvas.drawCircle(
      thumb,
      5,
      Paint()
        ..color = active
            ? Color.lerp(
                const Color(0xFFB8D4F0),
                const Color(0xFFFFE08A),
                day,
              )!
            : Colors.white.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(covariant _DimmerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.active != active ||
        oldDelegate.pulse != pulse ||
        oldDelegate.dayAmount != dayAmount;
  }
}
