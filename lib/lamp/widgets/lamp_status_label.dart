import 'package:flutter/material.dart';

import '../pull_cord_controller.dart';

/// On/off + day/night status from brightness.
class LampStatusLabel extends StatelessWidget {
  const LampStatusLabel({
    super.key,
    required this.controller,
    required this.dayAmount,
  });

  final PullCordController controller;
  final double dayAmount;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        controller.isOn,
        controller.intensityListenable,
      ]),
      builder: (context, _) {
        final on = controller.isOn.value;
        final pct = (controller.intensity * 100).round();
        final fg = Color.lerp(
          Colors.white,
          const Color(0xFF2C2416),
          dayAmount,
        )!;

        String title;
        String subtitle;
        if (!on) {
          title = 'شد الفتلة';
          subtitle = 'اسحب السطوع بعد التشغيل · ليل ⇄ صباح';
        } else if (dayAmount < 0.35) {
          title = 'ليل';
          subtitle = 'سطوع منخفض $pct%';
        } else if (dayAmount < 0.65) {
          title = 'فجر';
          subtitle = 'بين الليل والصباح · $pct%';
        } else {
          title = 'صباح';
          subtitle = 'نور الصباح $pct%';
        }

        return Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: fg.withValues(alpha: 0.92),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: fg.withValues(alpha: 0.5),
              ),
            ),
          ],
        );
      },
    );
  }
}
