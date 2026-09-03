import 'package:animate_training/features/users/data/models/user_model.dart';
import 'package:animate_training/features/users/domain/repositories/users_repository.dart';
import 'package:animate_training/features/users/presentation/cubit/users_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit({
    required this.repository,
    this.pageSize = 10,
  }) : super(const UsersInitial());

  final UsersRepository repository;
  final int pageSize;

  List<UserModel> get _currentUsers {
    return switch (state) {
      UsersSuccess(:final users) => users,
      UsersLoadingMore(:final users) => users,
      UsersFailure(:final users) => users,
      _ => const [],
    };
  }

  bool get _hasMore {
    return switch (state) {
      UsersSuccess(:final hasMore) => hasMore,
      _ => true,
    };
  }

  Future<void> loadUsers({bool refresh = false}) async {
    if (state is UsersLoading || state is UsersLoadingMore) return;

    final existing = _currentUsers;

    if (refresh || existing.isEmpty) {
      emit(const UsersLoading());
    } else {
      if (!_hasMore) return;
      emit(UsersLoadingMore(existing));
    }

    try {
      final result = await repository.getUsers(
        limit: pageSize,
        refresh: refresh || existing.isEmpty,
      );

      final users = (refresh || existing.isEmpty)
          ? result.items
          : [...existing, ...result.items];

      emit(UsersSuccess(users: users, hasMore: result.hasMore));
    } catch (error) {
      emit(UsersFailure(error.toString(), users: existing));
    }
  }

  Future<void> createUser({
    required String name,
    required String email,
  }) async {
    final existing = _currentUsers;
    try {
      final user = await repository.createUser(name: name, email: email);
      emit(
        UsersSuccess(
          users: [user, ...existing],
          hasMore: _hasMore,
        ),
      );
    } catch (error) {
      emit(UsersFailure(error.toString(), users: existing));
    }
  }

  Future<void> updateUser(UserModel user) async {
    final existing = _currentUsers;
    try {
      final updated = await repository.updateUser(user);
      final users = existing
          .map((item) => item.id == updated.id ? updated : item)
          .toList();
      emit(UsersSuccess(users: users, hasMore: _hasMore));
    } catch (error) {
      emit(UsersFailure(error.toString(), users: existing));
    }
  }

  Future<void> deleteUser(String id) async {
    final existing = _currentUsers;
    try {
      await repository.deleteUser(id);
      emit(
        UsersSuccess(
          users: existing.where((user) => user.id != id).toList(),
          hasMore: _hasMore,
        ),
      );
    } catch (error) {
      emit(UsersFailure(error.toString(), users: existing));
    }
  }
}
