import 'package:flutter/material.dart';
import '../quantum_list_controller.dart';

/// یک کنترلر تخصصی که اکنون قابلیت دریافت موقعیت آیتم‌ها را نیز دارد.
/// A specialized controller that now also has the ability to get item positions.
class ScrollableQuantumListController<T> extends QuantumListController<T> {
  @protected
  ScrollController? scrollController;

  /// یک callback خصوصی برای درخواست مختصات از ویجت.
  /// A private callback to request the rect from the widget.
  Rect? Function(int index)? _getRectCallback;

  ScrollableQuantumListController(super.initialItems);

  /// متدی داخلی برای اتصال ScrollController ویجت به این کنترلر.
  /// Internal method to attach the widget's ScrollController to this controller.
  void attachScrollController(ScrollController scrollController) {
    this.scrollController = scrollController;
  }

  /// متدی داخلی برای اتصال تابع محاسبه موقعیت از ویجت به این کنترلر.
  /// Internal method to attach the position calculation function from the widget.
  void attachRectCallback(Rect? Function(int index) callback) {
    _getRectCallback = callback;
  }

  /// مختصات (موقعیت و اندازه) یک آیتم را بر اساس اندیس آن برمی‌گرداند.
  /// اگر ویجت روی صفحه نباشد، نال برمی‌گرداند.
  ///
  /// Returns the rectangle (position and size) of an item by its index.
  /// Returns null if the widget is not on screen.
  Rect? getRectForIndex(int index) {
    return _getRectCallback?.call(index);
  }

  void jumpTo(double offset) {
    scrollController?.jumpTo(offset);
  }

  Future<void> animateTo(
    double offset, {
    required Duration duration,
    required Curve curve,
  }) async {
    await scrollController?.animateTo(offset, duration: duration, curve: curve);
  }

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
    super.dispose();
  }
}
