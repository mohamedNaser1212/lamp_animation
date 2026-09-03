class PaginationParams {
  const PaginationParams({
    this.limit = 10,
    this.startAfter,
    this.orderBy = 'createdAt',
    this.descending = true,
  });

  final int limit;
  final Object? startAfter;
  final String orderBy;
  final bool descending;
}

class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.hasMore,
    this.lastCursor,
  });

  final List<T> items;
  final bool hasMore;
  final Object? lastCursor;

  PaginatedResult<R> map<R>(R Function(T item) transform) {
    return PaginatedResult<R>(
      items: items.map(transform).toList(),
      hasMore: hasMore,
      lastCursor: lastCursor,
    );
  }
}
