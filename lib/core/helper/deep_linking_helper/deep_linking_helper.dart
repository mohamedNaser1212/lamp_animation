import 'dart:async';
import 'dart:developer';

import 'package:animate_training/main.dart';
import 'package:app_links/app_links.dart';

import 'deep_linking_cases.dart';

abstract interface class DeepLinkingHelper {
  const DeepLinkingHelper();

  FutureOr<void> init();

  bool get noAuthNeeded;

  void setPendingAction(FutureOr<void> Function() action);

  Future<void> handlePendingIfExists();

  void clearPendingAction();

  void dispose();
}

class AppLinksDeepLinkingHelper implements DeepLinkingHelper {
  final AppLinks appLinks;

  StreamSubscription<Uri>? _streamSubscription;

  bool _noAuthNeeded = false;

  FutureOr<void> Function()? _pendingHandler;

  AppLinksDeepLinkingHelper({
    required this.appLinks,
  });

  @override
  bool get noAuthNeeded => _noAuthNeeded;

  @override
  Future<void> init() async {
    final initialLink = await appLinks.getInitialLink();

    if (initialLink != null) {
      _onReceivedUri(initialLink);
    }

    _streamSubscription = appLinks.uriLinkStream.listen(
      _onReceivedUri,
    );
  }

  void _onReceivedUri(Uri uri) {
    log('Received uri: $uri');

    final receivedCase = DeepLinkingCases.fromUri(uri);

    if (receivedCase == null) {
      log('No case found');

      return;
    }

    log('Received case: $receivedCase');


    if (!receivedCase.handler.requiresAuth) {
      receivedCase.handler.handle(
        uri,
        navigatorKey.currentContext!,
      );

      _noAuthNeeded = true;

      return;
    }

    setPendingAction(
      () => receivedCase.handler.handle(
        uri,
        navigatorKey.currentContext!,
      ),
    );

    _noAuthNeeded = false;
  }

  @override
  void setPendingAction(
    FutureOr<void> Function() action,
  ) {
    _pendingHandler = action;
  }

  @override
  Future<void> handlePendingIfExists() async {
    if (_pendingHandler == null) {
      return;
    }

    print('Pending handler: ${_pendingHandler?.toString()}');

    await _pendingHandler?.call();

    clearPendingAction();
  }

  @override
  void clearPendingAction() {
    _pendingHandler = null;
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();

    _streamSubscription = null;
  }
}
