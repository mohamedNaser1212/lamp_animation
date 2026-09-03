import 'package:animate_training/core/helper/service_helper/pagination.dart';
import 'package:animate_training/features/users/data/models/user_model.dart';
import 'package:animate_training/features/users/domain/repositories/users_repository.dart';
import 'package:animate_training/features/users/presentation/cubit/users_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit({
    required this.repository,
    this.pageSize = 10,
  }) : super(const UsersState());

  final UsersRepository repository;
  final int pageSize;

  Future<void> loadUsers({bool refresh = false}) async {
    if (state.isLoading || state.isLoadingMore) return;

    if (refresh) {
      emit(
        state.copyWith(
          status: UsersStatus.loading,
          users: const [],
          hasMore: true,
          clearCursor: true,
          clearError: true,
        ),
      );
    } else if (state.users.isEmpty) {
      emit(state.copyWith(status: UsersStatus.loading, clearError: true));
    } else {
      if (!state.hasMore) return;
      emit(state.copyWith(status: UsersStatus.loadingMore, clearError: true));
    }

    try {
      final result = await repository.getUsers(
        params: PaginationParams(
          limit: pageSize,
          startAfter: refresh ? null : state.lastCursor,
          orderBy: 'createdAt',
          descending: true,
        ),
      );

      emit(
        state.copyWith(
          status: UsersStatus.success,
          users: refresh || state.users.isEmpty
              ? result.items
              : [...state.users, ...result.items],
          hasMore: result.hasMore,
          lastCursor: result.lastCursor,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: UsersStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> createUser({
    required String name,
    required String email,
  }) async {
    try {
      final user = await repository.createUser(name: name, email: email);
      emit(
        state.copyWith(
          status: UsersStatus.success,
          users: [user, ...state.users],
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: UsersStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      final updated = await repository.updateUser(user);
      final users = state.users
          .map((item) => item.id == updated.id ? updated : item)
          .toList();
      emit(
        state.copyWith(
          status: UsersStatus.success,
          users: users,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: UsersStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await repository.deleteUser(id);
      emit(
        state.copyWith(
          status: UsersStatus.success,
          users: state.users.where((user) => user.id != id).toList(),
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: UsersStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
