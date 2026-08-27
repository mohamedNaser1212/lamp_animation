import 'package:flutter/material.dart';

import '../pull_cord_controller.dart';

/// On/off status text. Rebuilds only when [PullCordController.isOn] changes.
class LampStatusLabel extends StatelessWidget {
  const LampStatusLabel({
    super.key,
    required this.controller,
  });

  final PullCordController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.isOn,
      builder: (context, _) {
        return Text(
          controller.isOn.value ? 'النور ولّع' : 'شد الفتلة',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}
