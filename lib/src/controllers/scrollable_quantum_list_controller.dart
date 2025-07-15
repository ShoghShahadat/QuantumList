import 'package:flutter/material.dart';
import '../quantum_list_controller.dart';

/// یک کنترلر تخصصی که قابلیت‌های پیشرفته مدیریت اسکرول را به کوانتوم لیست اضافه می‌کند.
/// A specialized controller that adds advanced scroll management capabilities to QuantumList.
class ScrollableQuantumListController<T> extends QuantumListController<T> {
  ScrollController? _scrollController;

  ScrollableQuantumListController(List<T> initialItems) : super(initialItems);

  /// متدی داخلی برای اتصال ScrollController ویجت به این کنترلر.
  /// Internal method to attach the widget's ScrollController to this controller.
  void attachScrollController(ScrollController scrollController) {
    _scrollController = scrollController;
  }

  /// پرش به یک موقعیت پیکسلی خاص در لیست.
  /// Jumps to a specific pixel offset in the list.
  void jumpTo(double offset) {
    _scrollController?.jumpTo(offset);
  }

  /// اسکرول به یک موقعیت پیکسلی خاص با انیمیشن.
  /// Animates the scroll to a specific pixel offset.
  Future<void> animateTo(
    double offset, {
    required Duration duration,
    required Curve curve,
  }) async {
    await _scrollController?.animateTo(offset, duration: duration, curve: curve);
  }

  /// اسکرول به یک آیتم با اندیس مشخص.
  /// **نکته:** این متد برای لیست‌هایی با ارتفاع آیتم ثابت، بهترین عملکرد را دارد.
  /// 
  /// Scrolls to an item at a specific index.
  /// **Note:** This method works best for lists with fixed item heights.
  Future<void> scrollToIndex(
    int index, {
    required double estimatedItemHeight,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) async {
    final offset = index * estimatedItemHeight;
    await animateTo(offset, duration: duration, curve: curve);
  }

  @override
  void dispose() {
    // The ScrollController is managed by the widget, so we don't dispose it here.
    super.dispose();
  }
}
