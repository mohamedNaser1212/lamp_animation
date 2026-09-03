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

  Future<PaginatedResult<Map<String, dynamic>>> getWithPagination({
    required String path,
    required PaginationParams params,
  });
}
