import 'deep_linking_case_handler/deep_linking_case_handler.dart';
import 'deep_linking_case_handler/reset_password_case_handler.dart';

enum DeepLinkingCases {
  resetPassword(
    handler: ResetPasswordCaseHandler(),
    redirectTo: 'semat://app/reset-password',
  );

  final DeepLinkingCaseHandler handler;

  final String redirectTo;

  const DeepLinkingCases({
    required this.handler,
    required this.redirectTo,
  });

  static DeepLinkingCases? fromUri(Uri uri) {
    for (final deepLinkCase in values) {
      final action = deepLinkCase.handler.pathAction;

      if (uri.pathSegments.contains(action) || uri.host == action) {
        return deepLinkCase;
      }
    }

    return null;
  }
}
