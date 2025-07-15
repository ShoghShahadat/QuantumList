import 'package:flutter/material.dart';
import 'dart:async';
import '../quantum_list_controller.dart';
import '../enums.dart';

/// A specialized controller that now has accurate item scrolling capabilities.
class ScrollableQuantumListController<T> extends QuantumListController<T> {
  @protected
  ScrollController? scrollController;

  Future<void> Function(int index,
      {required Duration duration,
      required Curve curve,
      required double estimatedItemHeight,
      double alignment})? _ensureVisibleCallback;

  ScrollableQuantumListController(super.initialItems);

  void attachScrollController(ScrollController scrollController) {
    this.scrollController = scrollController;
  }

  void attachEnsureVisibleCallback(
      Future<void> Function(int index,
              {required Duration duration,
              required Curve curve,
              required double estimatedItemHeight,
              double alignment})
          callback) {
    _ensureVisibleCallback = callback;
  }

  /// Scrolls to an item using a robust two-step process.
  Future<void> scrollToItem({
    required bool Function(T item) test,
    required double estimatedItemHeight,
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

    // **[FIXED & EXPANDED]** Mapping the enum to the correct Curve.
    final Curve curve;
    switch (animation) {
      case QuantumScrollAnimation.accelerated:
        curve = Curves.easeIn;
        break;
      case QuantumScrollAnimation.bouncy:
        curve = Curves.elasticOut; // This is the real bouncy curve
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

    await _ensureVisibleCallback?.call(
      index,
      duration: duration,
      curve: curve,
      alignment: alignment,
      estimatedItemHeight: estimatedItemHeight,
    );
  }
}
