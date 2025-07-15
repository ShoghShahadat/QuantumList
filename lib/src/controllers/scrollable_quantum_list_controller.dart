import 'package:flutter/material.dart';
import '../quantum_list_controller.dart';

/// A specialized controller that now has accurate item scrolling capabilities.
class ScrollableQuantumListController<T> extends QuantumListController<T> {
  @protected
  ScrollController? scrollController;

  Rect? Function(int index)? _getRectCallback;
  Future<void> Function(int index,
      {Duration? duration,
      Curve? curve,
      double? alignment})? _ensureVisibleCallback;

  ScrollableQuantumListController(super.initialItems);

  void attachScrollController(ScrollController scrollController) {
    this.scrollController = scrollController;
  }

  void attachRectCallback(Rect? Function(int index) callback) {
    _getRectCallback = callback;
  }

  void attachEnsureVisibleCallback(
      Future<void> Function(int index,
              {Duration? duration, Curve? curve, double? alignment})
          callback) {
    _ensureVisibleCallback = callback;
  }

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

  /// **FIX:** Re-engineered scrollToIndex with a robust two-step mechanism.
  /// 1. Jumps approximately to the item's position.
  /// 2. After the layout, performs a precise adjustment to ensure it's visible.
  Future<void> scrollToIndex(
    int index, {
    required double estimatedItemHeight,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeInOut,
    double alignment = 0.0,
  }) async {
    if (scrollController == null) return;

    // Step 1: Perform an initial, approximate jump.
    final approximateOffset = index * estimatedItemHeight;
    scrollController!.jumpTo(approximateOffset);

    // Step 2: Wait for the next frame to ensure the item is laid out, then fine-tune.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureVisibleCallback?.call(index,
          duration: duration, curve: curve, alignment: alignment);
    });
  }
}
