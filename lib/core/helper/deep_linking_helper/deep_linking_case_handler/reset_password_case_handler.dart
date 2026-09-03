import 'package:animate_training/core/routing/to_lamp_screen.dart';
import 'package:flutter/material.dart';
import 'deep_linking_case_handler.dart';

final class ResetPasswordCaseHandler implements DeepLinkingCaseHandler {
  const ResetPasswordCaseHandler();

  @override
  void handle(Uri uri, BuildContext context) {
   context.toLamp();
  }

  @override
  String get pathAction => 'reset-password';

  @override
  bool get requiresAuth => false;
}
