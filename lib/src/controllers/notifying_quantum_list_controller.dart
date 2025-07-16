import 'package:flutter/material.dart';
// **[FIXED]** Imports from the new barrel file for consistency.
import 'controllers.dart';

/// A specialized controller that adds a scroll event notification system to QuantumList.
class NotifyingQuantumListController<T>
    extends ScrollableQuantumListController<T> {
  /// Called when the scroll reaches the end of the list.
  final VoidCallback? onAtEnd;

  /// Called when the scroll reaches the start of the list.
  final VoidCallback? onAtStart;

  /// The offset from the end/start (in pixels) at which the event should be triggered.
  final double scrollThreshold;

  bool _isAtEndNotified = false;
  bool _isAtStartNotified = true; // Initially, we are at the start.

  NotifyingQuantumListController(
    super.initialItems, {
    this.onAtEnd,
    this.onAtStart,
    this.scrollThreshold = 100.0,
  });

  @override
  void attachScrollController(ScrollController scrollController) {
    super.attachScrollController(scrollController);
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController == null || !scrollController!.hasClients) return;

    final position = scrollController!.position;

    // Check for reaching the end
    if (onAtEnd != null) {
      if (position.pixels >= position.maxScrollExtent - scrollThreshold) {
        if (!_isAtEndNotified) {
          _isAtEndNotified = true;
          onAtEnd!();
        }
      } else if (position.pixels < position.maxScrollExtent - scrollThreshold) {
        _isAtEndNotified = false;
      }
    }

    // Check for reaching the start
    if (onAtStart != null) {
      if (position.pixels <= position.minScrollExtent + scrollThreshold) {
        if (!_isAtStartNotified) {
          _isAtStartNotified = true;
          onAtStart!();
        }
      } else if (position.pixels > position.minScrollExtent + scrollThreshold) {
        _isAtStartNotified = false;
      }
    }
  }

  @override
  void dispose() {
    scrollController?.removeListener(_scrollListener);
    super.dispose();
  }
}
