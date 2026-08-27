import 'package:flutter/material.dart';

import 'lamp_geometry.dart';
import 'pull_cord_controller.dart';
import 'widgets/cord_knob.dart';
import 'widgets/lamp_body.dart';
import 'widgets/lamp_status_label.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: LampGeometry.canvasW,
              height: LampGeometry.canvasH,
              child: Stack(
                children: [
                  LampBody(controller: _controller, isDark: isDark),
                  CordKnob(controller: _controller),
                ],
              ),
            ),
            const SizedBox(height: 12),
            LampStatusLabel(controller: _controller),
          ],
        ),
      ),
    );
  }
}
