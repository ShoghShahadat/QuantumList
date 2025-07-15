import 'package:flutter/material.dart';
import 'dart:async';
import '../quantum_list_controller.dart';
import '../enums.dart';

/// A specialized controller that now has accurate item scrolling capabilities.
class ScrollableQuantumListController<T> extends QuantumListController<T> {
  @protected
  ScrollController? scrollController;

  /// The internal callback to the widget to perform the scroll.
  Future<void> Function(int index,
      {required Duration duration,
      required Curve curve,
      double alignment})? _ensureVisibleCallback;

  ScrollableQuantumListController(super.initialItems);

  void attachScrollController(ScrollController scrollController) {
    this.scrollController = scrollController;
  }

  void attachEnsureVisibleCallback(
      Future<void> Function(int index,
              {required Duration duration,
              required Curve curve,
              double alignment})
          callback) {
    _ensureVisibleCallback = callback;
  }

  /// **[نهایی]** با استفاده از موتور کاوش و محاسبه، به سمت آیتم مورد نظر حرکت می‌کند.
  /// **[Final]** Scrolls to an item using the new Explore & Calculate engine.
  Future<void> scrollToItem({
    required bool Function(T item) test,
    Duration duration = const Duration(milliseconds: 800),
    QuantumScrollAnimation animation = QuantumScrollAnimation.smooth,
    double alignment = 0.0,
  }) async {
    if (scrollController == null || !scrollController!.hasClients) return;

    final int index = items.indexWhere(test);
    if (index == -1) {
      debugPrint("QuantumList: Item to scroll to was not found.");
      return;
    }

    final Curve curve;
    switch (animation) {
      case QuantumScrollAnimation.accelerated:
        curve = Curves.easeIn;
        break;
      case QuantumScrollAnimation.bouncy:
        curve = Curves.elasticOut;
        break;
      case QuantumScrollAnimation.decelerated:
        curve = Curves.easeOut;
        break;
      case QuantumScrollAnimation.linear:
        curve = Curves.linear;
        break;
      case QuantumScrollAnimation.smooth:
      default:
        curve = Curves.easeInOut;
        break;
    }

    // Trigger the new, intelligent search and scroll mechanism.
    await _ensureVisibleCallback?.call(
      index,
      duration: duration,
      curve: curve,
      alignment: alignment,
    );
  }
}
