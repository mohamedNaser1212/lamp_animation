import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'lamp_geometry.dart';

/// Paints the bedside lamp, glow, and hanging cord.
class LampPainter extends CustomPainter {
  const LampPainter({
    required this.isOn,
    required this.glow,
    required this.pullProgress,
    required this.swingRadians,
    required this.isDark,
  });

  final bool isOn;
  final double glow;
  final double pullProgress;
  final double swingRadians;
  final bool isDark;

  Color get _brass => Color.lerp(
        const Color(0xFFB08D3A),
        const Color(0xFFFFE082),
        glow * 0.65,
      )!;

  Color get _metal =>
      isDark ? const Color(0xFFE8DFD0) : const Color(0xFF3D342C);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width * 0.42;
    final shadeTop = size.height * 0.10;
    final shadeBottom = size.height * 0.38;
    final baseY = size.height * 0.90;

    _drawTableGlow(canvas, size, centerX, baseY);
    _drawBase(canvas, centerX, baseY);
    _drawStem(canvas, centerX, shadeBottom, baseY);
    _drawShade(canvas, centerX, shadeTop, shadeBottom);
    _drawCord(canvas, centerX, shadeBottom);
  }

  void _drawTableGlow(
    Canvas canvas,
    Size size,
    double centerX,
    double baseY,
  ) {
    if (glow <= 0) return;

    final pool = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF1C1).withValues(alpha: 0.42 * glow),
          const Color(0xFFFFD56A).withValues(alpha: 0.16 * glow),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(
        Rect.fromCenter(
          center: Offset(centerX, baseY + 6),
          width: 200,
          height: 56,
        ),
      );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, baseY + 6),
        width: 200,
        height: 56,
      ),
      pool,
    );

    final bloom = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF6D0).withValues(alpha: 0.5 * glow),
          const Color(0xFFFFD36A).withValues(alpha: 0.22 * glow),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: Offset(centerX, size.height * 0.38 + 18),
          radius: 95,
        ),
      );
    canvas.drawCircle(
      Offset(centerX, size.height * 0.38 + 18),
      95,
      bloom,
    );
  }

  void _drawBase(Canvas canvas, double centerX, double baseY) {
    final ceramic = Color.lerp(
      isDark ? const Color(0xFF7A7166) : const Color(0xFF5C4E42),
      const Color(0xFF8A7048),
      glow * 0.25,
    )!;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, baseY + 2),
          width: 78,
          height: 8,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = _metal,
    );

    final bodyPath = Path()
      ..moveTo(centerX - 18, baseY - 52)
      ..cubicTo(
        centerX - 34,
        baseY - 46,
        centerX - 40,
        baseY - 28,
        centerX - 36,
        baseY - 8,
      )
      ..quadraticBezierTo(centerX, baseY + 2, centerX + 36, baseY - 8)
      ..cubicTo(
        centerX + 40,
        baseY - 28,
        centerX + 34,
        baseY - 46,
        centerX + 18,
        baseY - 52,
      )
      ..close();

    canvas.drawPath(bodyPath, Paint()..color = ceramic);

    final highlight = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.08 : 0.14),
          Colors.transparent,
          Colors.black.withValues(alpha: 0.12),
        ],
        stops: const [0.15, 0.45, 0.9],
      ).createShader(
        Rect.fromLTRB(centerX - 40, baseY - 52, centerX + 40, baseY),
      );
    canvas.drawPath(bodyPath, highlight);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, baseY - 54),
          width: 28,
          height: 8,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = _brass,
    );
  }

  void _drawStem(
    Canvas canvas,
    double centerX,
    double shadeBottom,
    double baseY,
  ) {
    final stemTop = shadeBottom - 8;
    final stemBottom = baseY - 54;

    canvas.drawLine(
      Offset(centerX, stemTop),
      Offset(centerX, stemBottom),
      Paint()
        ..color = _brass
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    final collarPaint = Paint()..color = _brass;
    for (final y in [
      stemTop + 10.0,
      (stemTop + stemBottom) / 2,
      stemBottom - 6,
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(centerX, y), width: 14, height: 5),
          const Radius.circular(2),
        ),
        collarPaint,
      );
    }
  }

  void _drawShade(
    Canvas canvas,
    double centerX,
    double shadeTop,
    double shadeBottom,
  ) {
    final shadeColor = Color.lerp(
      isDark ? const Color(0xFF8A8072) : const Color(0xFFD7CBB8),
      const Color(0xFFFFE7A3),
      glow * 0.8,
    )!;

    final shadePath = Path()
      ..moveTo(centerX - 22, shadeTop + 8)
      ..cubicTo(
        centerX - 26,
        shadeTop + 4,
        centerX - 20,
        shadeTop,
        centerX,
        shadeTop,
      )
      ..cubicTo(
        centerX + 20,
        shadeTop,
        centerX + 26,
        shadeTop + 4,
        centerX + 22,
        shadeTop + 8,
      )
      ..cubicTo(
        centerX + 56,
        shadeTop + 22,
        centerX + 62,
        shadeBottom - 8,
        centerX + 58,
        shadeBottom,
      )
      ..lineTo(centerX - 58, shadeBottom)
      ..cubicTo(
        centerX - 62,
        shadeBottom - 8,
        centerX - 56,
        shadeTop + 22,
        centerX - 22,
        shadeTop + 8,
      )
      ..close();

    canvas.drawPath(shadePath, Paint()..color = shadeColor);

    if (glow > 0) {
      final lit = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFF8E1).withValues(alpha: 0.2 * glow),
            const Color(0xFFFFE082).withValues(alpha: 0.55 * glow),
            const Color(0xFFFFC107).withValues(alpha: 0.25 * glow),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(
          Rect.fromLTRB(centerX - 62, shadeTop, centerX + 62, shadeBottom),
        );
      canvas.drawPath(shadePath, lit);
    }

    final innerBand = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: isDark ? 0.18 : 0.10),
        ],
      ).createShader(
        Rect.fromLTRB(
          centerX - 58,
          shadeBottom - 22,
          centerX + 58,
          shadeBottom,
        ),
      );
    canvas.drawRect(
      Rect.fromLTRB(centerX - 56, shadeBottom - 20, centerX + 56, shadeBottom),
      innerBand,
    );

    canvas.drawLine(
      Offset(centerX - 58, shadeBottom),
      Offset(centerX + 58, shadeBottom),
      Paint()
        ..color = _brass
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );

    if (glow > 0.05) {
      final bulb = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFFDE7).withValues(alpha: 0.9 * glow),
            const Color(0xFFFFE082).withValues(alpha: 0.35 * glow),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(centerX, shadeBottom - 18),
            radius: 22,
          ),
        );
      canvas.drawCircle(Offset(centerX, shadeBottom - 18), 22, bulb);
    }

    canvas.drawCircle(
      Offset(centerX, shadeTop - 2),
      4.5,
      Paint()..color = _brass,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, shadeTop + 6),
          width: 16,
          height: 8,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = _metal,
    );
  }

  void _drawCord(Canvas canvas, double centerX, double shadeBottom) {
    final cordStart = Offset(centerX + 46, shadeBottom - 2);
    final length = LampGeometry.stringLength(pullProgress);

    final cordEnd = Offset(
      cordStart.dx + length * math.sin(swingRadians),
      cordStart.dy + length * math.cos(swingRadians),
    );

    final midAngle = swingRadians * 0.42;
    final midLen = length * 0.52;
    final mid = Offset(
      cordStart.dx + midLen * math.sin(midAngle),
      cordStart.dy + midLen * math.cos(midAngle),
    );

    canvas.drawPath(
      Path()
        ..moveTo(cordStart.dx, cordStart.dy)
        ..quadraticBezierTo(mid.dx, mid.dy, cordEnd.dx, cordEnd.dy),
      Paint()
        ..color = isDark ? const Color(0xFFCFC6B6) : const Color(0xFF5C5348)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    canvas.drawCircle(cordStart, 2.8, Paint()..color = _brass);
  }

  @override
  bool shouldRepaint(covariant LampPainter oldDelegate) {
    return oldDelegate.isOn != isOn ||
        oldDelegate.glow != glow ||
        oldDelegate.pullProgress != pullProgress ||
        oldDelegate.swingRadians != swingRadians ||
        oldDelegate.isDark != isDark;
  }
}
