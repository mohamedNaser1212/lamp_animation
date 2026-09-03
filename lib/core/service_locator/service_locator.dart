import 'package:animate_training/core/helper/deep_linking_helper/deep_linking_helper.dart';
import 'package:animate_training/core/helper/service_helper/firebase_service_helper.dart';
import 'package:animate_training/core/helper/service_helper/service_helper.dart';
import 'package:animate_training/features/users/data/datasources/users_remote_data_source.dart';
import 'package:animate_training/features/users/data/repositories/users_repository_impl.dart';
import 'package:animate_training/features/users/domain/repositories/users_repository.dart';
import 'package:animate_training/features/users/presentation/cubit/users_cubit.dart';
import 'package:app_links/app_links.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

class ServiceLocator {
  void init() {
    sl.registerLazySingleton<DeepLinkingHelper>(
      () => AppLinksDeepLinkingHelper(appLinks: AppLinks()),
    );

    sl.registerLazySingleton<ServiceHelper>(
      () => FirebaseServiceHelper(),
    );

    sl.registerLazySingleton<UsersRemoteDataSource>(
      () => UsersRemoteDataSourceImpl(serviceHelper: sl()),
    );

    sl.registerLazySingleton<UsersRepository>(
      () => UsersRepositoryImpl(remoteDataSource: sl()),
    );

    sl.registerFactory(
      () => UsersCubit(repository: sl()),
    );
  }
}
