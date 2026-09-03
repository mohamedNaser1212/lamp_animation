import 'package:animate_training/core/helper/service_helper/pagination.dart';
import 'package:animate_training/core/helper/service_helper/service_helper.dart';
import 'package:animate_training/features/users/data/models/user_model.dart';

abstract interface class UsersRemoteDataSource {
  Future<PaginatedResult<UserModel>> getUsers({
    int limit = 10,
    bool refresh = false,
  });

  Future<UserModel?> getUser(String id);

  Future<UserModel> createUser(UserModel user);

  Future<UserModel> updateUser(UserModel user);

  Future<void> deleteUser(String id);
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  UsersRemoteDataSourceImpl({
    required this.serviceHelper,
    this.collectionPath = 'users',
  });

  final ServiceHelper serviceHelper;
  final String collectionPath;

  @override
  Future<PaginatedResult<UserModel>> getUsers({
    int limit = 10,
    bool refresh = false,
  }) async {
    final result = await serviceHelper.getWithPagination(
      path: collectionPath,
      limit: limit,
      refresh: refresh,
    );

    return result.map(UserModel.fromMap);
  }

  @override
  Future<UserModel?> getUser(String id) async {
    final data = await serviceHelper.get(path: collectionPath, id: id);
    if (data == null) return null;
    return UserModel.fromMap(data);
  }

  @override
  Future<UserModel> createUser(UserModel user) async {
    final id = await serviceHelper.post(
      path: collectionPath,
      data: user.toMap(),
      id: user.id.isEmpty ? null : user.id,
    );
    return UserModel(id: id, name: user.name, email: user.email);
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    await serviceHelper.put(
      path: collectionPath,
      id: user.id,
      data: user.toMap(),
    );
    return user;
  }

  @override
  Future<void> deleteUser(String id) {
    return serviceHelper.delete(path: collectionPath, id: id);
  }
}
