import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quantum_list/src/controllers/scrollable_quantum_list_controller.dart';

/// A function type for fetching a page of data.
typedef PageFetcher<T> = Future<List<T>> Function(int page);

/// **[RE-ARCHITECTED]**
/// A smart controller that now correctly extends ScrollableQuantumListController
/// and manages its own scroll listener to handle pagination, fixing the `assignment_to_final` error.
class PaginatedQuantumListController<T>
    extends ScrollableQuantumListController<T> {
  final PageFetcher<T> _pageFetcher;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  final double scrollThreshold;

  final T? loadingIndicator;

  PaginatedQuantumListController(
    this._pageFetcher, {
    this.scrollThreshold = 200.0,
    this.loadingIndicator,
  }) : super([]) {
    _fetchNextPage();
  }

  @override
  void attachScrollController(ScrollController scrollController) {
    super.attachScrollController(scrollController);
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController == null || !scrollController!.hasClients) return;
    final position = scrollController!.position;
    if (position.pixels >= position.maxScrollExtent - scrollThreshold) {
      _fetchNextPage();
    }
  }

  Future<void> _fetchNextPage() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    if (loadingIndicator != null) {
      super.add(loadingIndicator as T);
    }

    try {
      final newItems = await _pageFetcher(_currentPage);

      if (items.isNotEmpty && items.last == loadingIndicator) {
        super.removeAt(items.length - 1);
      }

      if (newItems.isEmpty) {
        _hasMore = false;
      } else {
        for (var item in newItems) {
          super.add(item);
        }
        _currentPage++;
      }
    } catch (e) {
      debugPrint('Error fetching next page: $e');
      if (items.isNotEmpty && items.last == loadingIndicator) {
        super.removeAt(items.length - 1);
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() async {
    _currentPage = 0;
    _hasMore = true;
    _isLoading = false;
    super.clear();
    await _fetchNextPage();
  }

  @override
  void dispose() {
    scrollController?.removeListener(_scrollListener);
    super.dispose();
  }
}
