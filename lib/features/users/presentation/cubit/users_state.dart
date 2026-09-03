import 'package:animate_training/features/users/data/models/user_model.dart';

sealed class UsersState {
  const UsersState();
}

final class UsersInitial extends UsersState {
  const UsersInitial();
}

final class UsersLoading extends UsersState {
  const UsersLoading();
}

final class UsersLoadingMore extends UsersState {
  const UsersLoadingMore(this.users);

  final List<UserModel> users;
}

final class UsersSuccess extends UsersState {
  const UsersSuccess({
    required this.users,
    required this.hasMore,
  });

  final List<UserModel> users;
  final bool hasMore;
}

final class UsersFailure extends UsersState {
  const UsersFailure(this.message, {this.users = const []});

  final String message;
  final List<UserModel> users;
}
