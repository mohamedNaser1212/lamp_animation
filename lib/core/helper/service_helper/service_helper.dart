import 'pagination.dart';

/// Abstraction for CRUD + paginated reads against a remote backend.
abstract interface class ServiceHelper {
  Future<Map<String, dynamic>?> get({
    required String path,
    String? id,
  });

  Future<String> post({
    required String path,
    required Map<String, dynamic> data,
    String? id,
  });

  Future<void> put({
    required String path,
    required String id,
    required Map<String, dynamic> data,
    bool merge = true,
  });

  Future<void> delete({
    required String path,
    required String id,
  });

  /// Pagination cursor is stored inside the service implementation.
  Future<PaginatedResult<Map<String, dynamic>>> getWithPagination({
    required String path,
    int limit = 10,
    bool refresh = false,
    String orderBy = 'createdAt',
    bool descending = true,
  });

  void resetPagination(String path);
}
