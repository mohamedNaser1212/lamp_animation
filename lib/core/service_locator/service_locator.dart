import 'package:animate_training/core/helper/deep_linking_helper/deep_linking_helper.dart';
import 'package:app_links/app_links.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

class ServiceLocator {
  
void init() {
  sl.registerLazySingleton<DeepLinkingHelper>(
    () => AppLinksDeepLinkingHelper(
      appLinks: AppLinks()
    ),
  );
}

}