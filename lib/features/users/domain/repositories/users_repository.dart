import 'package:animate_training/core/helper/service_helper/pagination.dart';
import 'package:animate_training/features/users/data/models/user_model.dart';

abstract interface class UsersRepository {
  Future<PaginatedResult<UserModel>> getUsers({
    required PaginationParams params,
  });

  Future<UserModel?> getUser(String id);

  Future<UserModel> createUser({
    required String name,
    required String email,
  });

  Future<UserModel> updateUser(UserModel user);

  Future<void> deleteUser(String id);
}
