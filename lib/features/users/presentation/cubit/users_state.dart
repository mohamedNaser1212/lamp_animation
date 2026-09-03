import 'package:animate_training/features/users/data/models/user_model.dart';
import 'package:equatable/equatable.dart';

enum UsersStatus { initial, loading, loadingMore, success, failure }

class UsersState extends Equatable {
  const UsersState({
    this.status = UsersStatus.initial,
    this.users = const [],
    this.hasMore = true,
    this.lastCursor,
    this.errorMessage,
  });

  final UsersStatus status;
  final List<UserModel> users;
  final bool hasMore;
  final Object? lastCursor;
  final String? errorMessage;

  bool get isLoading => status == UsersStatus.loading;
  bool get isLoadingMore => status == UsersStatus.loadingMore;

  UsersState copyWith({
    UsersStatus? status,
    List<UserModel>? users,
    bool? hasMore,
    Object? lastCursor,
    String? errorMessage,
    bool clearError = false,
    bool clearCursor = false,
  }) {
    return UsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      hasMore: hasMore ?? this.hasMore,
      lastCursor: clearCursor ? null : (lastCursor ?? this.lastCursor),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, users, hasMore, lastCursor, errorMessage];
}
