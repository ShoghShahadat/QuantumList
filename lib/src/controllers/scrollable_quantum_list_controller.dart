import 'package:flutter/material.dart';
import 'package:quantum_list/quantum_list.dart';
import 'dart:async';
// **[FIXED]** Imports from the new barrel file for consistency.
import 'controllers.dart';
// import '../../enums.dart';

/// A specialized controller that now has accurate item scrolling capabilities.
class ScrollableQuantumListController<T> extends QuantumListController<T> {
  @protected
  ScrollController? scrollController;

  /// The internal callback to the widget to perform the scroll.
  Future<void> Function(int index,
      {required Duration duration,
      required Curve curve,
      required double alignment})? _ensureVisibleCallback;

  ScrollableQuantumListController(super.initialItems);

  void attachScrollController(ScrollController scrollController) {
    this.scrollController = scrollController;
  }

  void attachEnsureVisibleCallback(
      Future<void> Function(int index,
              {required Duration duration,
              required Curve curve,
              required double alignment})
          callback) {
    _ensureVisibleCallback = callback;
  }

  /// Scrolls to an item that matches the provided test condition.
  Future<void> scrollToItem({
    required bool Function(T item) test,
    Duration duration = const Duration(milliseconds: 800),
    QuantumScrollAnimation animation = QuantumScrollAnimation.smooth,
    double alignment = 0.0,
  }) async {
    final int index = items.indexWhere(test);
    if (index == -1) {
      debugPrint("QuantumList: Item to scroll to was not found.");
      return;
    }
    await scrollToIndex(
      index,
      duration: duration,
      animation: animation,
      alignment: alignment,
    );
  }

  /// Scrolls directly to a specific index in the list.
  Future<void> scrollToIndex(
    int index, {
    Duration duration = const Duration(milliseconds: 800),
    QuantumScrollAnimation animation = QuantumScrollAnimation.smooth,
    double alignment = 0.0,
  }) async {
    if (scrollController == null || !scrollController!.hasClients) {
      debugPrint(
          "QuantumList: Scroll controller not attached or has no clients.");
      return;
    }
    if (index < 0 || index >= length) {
      debugPrint(
          "QuantumList: Scroll index $index is out of bounds (0-$length).");
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

    await _ensureVisibleCallback?.call(
      index,
      duration: duration,
      curve: curve,
      alignment: alignment,
    );
  }
}
