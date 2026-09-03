class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.hasMore,
  });

  final List<T> items;
  final bool hasMore;

  PaginatedResult<R> map<R>(R Function(T item) transform) {
    return PaginatedResult<R>(
      items: items.map(transform).toList(),
      hasMore: hasMore,
    );
  }
}
