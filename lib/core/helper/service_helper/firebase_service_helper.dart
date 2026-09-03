import 'package:cloud_firestore/cloud_firestore.dart';

import 'pagination.dart';
import 'service_helper.dart';

class FirebaseServiceHelper implements ServiceHelper {
  FirebaseServiceHelper({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Keeps last document cursor per collection path.
  final Map<String, DocumentSnapshot<Map<String, dynamic>>> _cursors = {};
  final Map<String, bool> _hasMore = {};

  CollectionReference<Map<String, dynamic>> _collection(String path) {
    return _firestore.collection(path);
  }

  @override
  Future<Map<String, dynamic>?> get({
    required String path,
    String? id,
  }) async {
    if (id == null) {
      throw ArgumentError('id is required for get on FirebaseServiceHelper');
    }

    final snapshot = await _collection(path).doc(id).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return {
      'id': snapshot.id,
      ...snapshot.data()!,
    };
  }

  @override
  Future<String> post({
    required String path,
    required Map<String, dynamic> data,
    String? id,
  }) async {
    final payload = {
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (id != null) {
      await _collection(path).doc(id).set(payload);
      return id;
    }

    final doc = await _collection(path).add(payload);
    return doc.id;
  }

  @override
  Future<void> put({
    required String path,
    required String id,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    final payload = {
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _collection(path).doc(id).set(
          payload,
          SetOptions(merge: merge),
        );
  }

  @override
  Future<void> delete({
    required String path,
    required String id,
  }) async {
    await _collection(path).doc(id).delete();
  }

  @override
  void resetPagination(String path) {
    _cursors.remove(path);
    _hasMore.remove(path);
  }

  @override
  Future<PaginatedResult<Map<String, dynamic>>> getWithPagination({
    required String path,
    int limit = 10,
    bool refresh = false,
    String orderBy = 'createdAt',
    bool descending = true,
  }) async {
    if (refresh) {
      resetPagination(path);
    }

    if (_hasMore[path] == false && !refresh) {
      return const PaginatedResult(items: [], hasMore: false);
    }

    Query<Map<String, dynamic>> query = _collection(path).orderBy(
      orderBy,
      descending: descending,
    );

    final cursor = _cursors[path];
    if (cursor != null) {
      query = query.startAfterDocument(cursor);
    }

    final snapshot = await query.limit(limit + 1).get();
    final docs = snapshot.docs;
    final hasMore = docs.length > limit;
    final pageDocs = hasMore ? docs.sublist(0, limit) : docs;

    if (pageDocs.isNotEmpty) {
      _cursors[path] = pageDocs.last;
    }
    _hasMore[path] = hasMore;

    final items = pageDocs.map((doc) {
      return <String, dynamic>{
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();

    return PaginatedResult<Map<String, dynamic>>(
      items: items,
      hasMore: hasMore,
    );
  }
}
