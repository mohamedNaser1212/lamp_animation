import 'package:cloud_firestore/cloud_firestore.dart';

import 'pagination.dart';
import 'service_helper.dart';

class FirebaseServiceHelper implements ServiceHelper {
  FirebaseServiceHelper({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

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
  Future<PaginatedResult<Map<String, dynamic>>> getWithPagination({
    required String path,
    required PaginationParams params,
  }) async {
    Query<Map<String, dynamic>> query = _collection(path).orderBy(
      params.orderBy,
      descending: params.descending,
    );

    final cursor = params.startAfter;
    if (cursor is DocumentSnapshot) {
      query = query.startAfterDocument(cursor);
    }

    // Fetch one extra item to know if there is another page.
    final snapshot = await query.limit(params.limit + 1).get();
    final docs = snapshot.docs;
    final hasMore = docs.length > params.limit;
    final pageDocs = hasMore ? docs.sublist(0, params.limit) : docs;

    final items = pageDocs.map((doc) {
      return <String, dynamic>{
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();

    return PaginatedResult<Map<String, dynamic>>(
      items: items,
      hasMore: hasMore,
      lastCursor: pageDocs.isEmpty ? null : pageDocs.last,
    );
  }
}
