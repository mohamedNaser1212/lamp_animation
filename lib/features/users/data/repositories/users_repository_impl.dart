import 'package:animate_training/core/helper/service_helper/pagination.dart';
import 'package:animate_training/features/users/data/datasources/users_remote_data_source.dart';
import 'package:animate_training/features/users/data/models/user_model.dart';
import 'package:animate_training/features/users/domain/repositories/users_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  UsersRepositoryImpl({required this.remoteDataSource});

  final UsersRemoteDataSource remoteDataSource;

  @override
  Future<PaginatedResult<UserModel>> getUsers({
    required PaginationParams params,
  }) {
    return remoteDataSource.getUsers(params: params);
  }

  @override
  Future<UserModel?> getUser(String id) {
    return remoteDataSource.getUser(id);
  }

  @override
  Future<UserModel> createUser({
    required String name,
    required String email,
  }) {
    return remoteDataSource.createUser(
      UserModel(id: '', name: name, email: email),
    );
  }

  @override
  Future<UserModel> updateUser(UserModel user) {
    return remoteDataSource.updateUser(user);
  }

  @override
  Future<void> deleteUser(String id) {
    return remoteDataSource.deleteUser(id);
  }
}
