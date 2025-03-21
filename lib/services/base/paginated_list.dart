class PaginatedList<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final bool hasMore;

  PaginatedList({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  factory PaginatedList.empty() {
    return PaginatedList(
      items: [],
      page: 1,
      pageSize: 10,
      hasMore: false,
    );
  }

  factory PaginatedList.fromList(List<T> list, {int page = 1, int pageSize = 10}) {
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;
    final items = list.length > startIndex 
      ? list.sublist(startIndex, endIndex > list.length ? list.length : endIndex)
      : <T>[];
    
    return PaginatedList(
      items: items,
      page: page,
      pageSize: pageSize,
      hasMore: endIndex < list.length,
    );
  }
} 