typedef PageFetcher<T> = Future<List<T>> Function(int page, int pageSize);

class Paginator<T> {
  Paginator({required this.fetchPage, this.pageSize = 20});

  final PageFetcher<T> fetchPage;
  final int pageSize;

  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoading = false;

  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;

  Future<List<T>> loadNext() async {
    if (_isLoading || !_hasMore) return <T>[];
    _isLoading = true;
    final next = _currentPage + 1;
    try {
      final items = await fetchPage(next, pageSize);
      if (items.length < pageSize) _hasMore = false;
      _currentPage = next;
      return items;
    } finally {
      _isLoading = false;
    }
  }

  Future<List<T>> refresh() async {
    _currentPage = 0;
    _hasMore = true;
    return loadNext();
  }
}
