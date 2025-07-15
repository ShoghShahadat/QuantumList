import 'package:flutter/material.dart';
import 'dart:async';
import '../quantum_list_controller.dart';
import '../enums.dart';

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

  /// **[جدید و انقلابی]** آیتمی را که با شرط `test` مطابقت دارد پیدا کرده و با دقت به سمت آن اسکرول می‌کند.
  /// **[New & Revolutionary]** Finds an item that matches the `test` condition and scrolls to it with precision.
  Future<void> scrollToItem({
    required bool Function(T item) test,
    required double estimatedItemHeight,
    Duration duration = const Duration(milliseconds: 800),
    QuantumScrollAnimation animation = QuantumScrollAnimation.smooth,
    double alignment = 0.0,
  }) async {
    final int index = items.indexWhere(test);
    if (index != -1) {
      await _scrollOrJumpToIndex(
        index,
        estimatedItemHeight: estimatedItemHeight,
        duration: duration,
        animation: animation,
        alignment: alignment,
      );
    } else {
      // آیتم مورد نظر یافت نشد. می‌توانید در اینجا یک لاگ یا خطا نمایش دهید.
      debugPrint("QuantumList: Item to scroll to was not found.");
    }
  }

  /// **[بازمهندسی شده]** با دقت بالا و انیمیشن قابل تنظیم به ایندکس مورد نظر اسکرول یا پرش می‌کند.
  /// این متد اکنون خصوصی است و توسط `scrollToItem` استفاده می‌شود.
  Future<void> _scrollOrJumpToIndex(
    int index, {
    required double estimatedItemHeight,
    Duration duration = const Duration(milliseconds: 800),
    QuantumScrollAnimation animation = QuantumScrollAnimation.smooth,
    double alignment = 0.0,
  }) async {
    if (scrollController == null || !scrollController!.hasClients) return;

    // Step 1: Instantly jump to the estimated position.
    final approximateOffset = index * estimatedItemHeight;
    final maxScroll = scrollController!.position.maxScrollExtent;
    final targetOffset = approximateOffset.clamp(0.0, maxScroll);

    scrollController!.jumpTo(targetOffset);

    // Step 2: Wait for the next frame for the item to be laid out,
    // then perform the final, precise scroll animation.
    return Completer<void>().future
      ..then((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final Curve curve;
          switch (animation) {
            case QuantumScrollAnimation.accelerated:
              curve = Curves.easeIn;
              break;
            case QuantumScrollAnimation.bouncy:
              curve = Curves.elasticOut;
              break;
            case QuantumScrollAnimation.smooth:
            default:
              curve = Curves.easeInOut;
              break;
          }

          _ensureVisibleCallback?.call(
            index,
            duration: duration,
            curve: curve,
            alignment: alignment,
          );
        });
      });
  }
}
