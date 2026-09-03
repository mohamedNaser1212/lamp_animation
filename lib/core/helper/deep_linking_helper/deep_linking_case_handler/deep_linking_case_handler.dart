import 'dart:async';

import 'package:flutter/material.dart';

abstract interface class DeepLinkingCaseHandler {
  const DeepLinkingCaseHandler();

  String get pathAction;

  FutureOr<void> handle(Uri uri, BuildContext context);

  bool get requiresAuth;
}
