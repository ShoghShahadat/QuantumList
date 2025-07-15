import 'package:flutter/material.dart';
import 'scrollable_quantum_list_controller.dart';

/// یک کنترلر تخصصی که سیستم اطلاع‌رسانی رویدادهای اسکرول را به کوانتوم لیست اضافه می‌کند.
/// A specialized controller that adds a scroll event notification system to QuantumList.
class NotifyingQuantumListController<T>
    extends ScrollableQuantumListController<T> {
  /// زمانی فراخوانی می‌شود که اسکرول به انتهای لیست می‌رسد.
  /// Called when the scroll reaches the end of the list.
  final VoidCallback? onAtEnd;

  /// زمانی فراخوانی می‌شود که اسکرول به ابتدای لیست می‌رسد.
  /// Called when the scroll reaches the start of the list.
  final VoidCallback? onAtStart;

  /// فاصله‌ای از انتها/ابتدا (بر حسب پیکسل) که رویداد باید فعال شود.
  /// The offset from the end/start (in pixels) at which the event should be triggered.
  final double scrollThreshold;

  bool _isAtEndNotified = false;
  bool _isAtStartNotified = true; // در ابتدا، در ابتدای لیست هستیم

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

    // بررسی رسیدن به انتهای لیست
    if (onAtEnd != null) {
      if (position.pixels >= position.maxScrollExtent - scrollThreshold) {
        if (!_isAtEndNotified) {
          _isAtEndNotified = true;
          onAtEnd!();
        }
      } else if (position.pixels < position.maxScrollExtent - scrollThreshold) {
        // ریست کردن وضعیت برای فراخوانی مجدد در آینده
        _isAtEndNotified = false;
      }
    }

    // بررسی رسیدن به ابتدای لیست
    if (onAtStart != null) {
      if (position.pixels <= position.minScrollExtent + scrollThreshold) {
        if (!_isAtStartNotified) {
          _isAtStartNotified = true;
          onAtStart!();
        }
      } else if (position.pixels > position.minScrollExtent + scrollThreshold) {
        // ریست کردن وضعیت برای فراخوانی مجدد در آینده
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
