import 'package:flutter/material.dart';
import 'dart:async';

// Exporting the public parts of the package
export 'src/quantum_list_controller.dart';
export 'src/controllers/filterable_quantum_list_controller.dart';
export 'src/controllers/scrollable_quantum_list_controller.dart';
export 'src/controllers/notifying_quantum_list_controller.dart';
export 'src/enums.dart';
export 'src/widgets/animated_border_card.dart';
export 'src/widgets/quantum_animations.dart';
export 'src/widgets/quantum_atom.dart';

// Importing internal implementation
import 'src/quantum_list_controller.dart';
import 'src/controllers/scrollable_quantum_list_controller.dart';
import 'src/enums.dart';
import 'src/models.dart';

/// The powerful QuantumList widget - Version 6.0.0 with Off-Screen Pre-rendering Engine
class QuantumList<T> extends StatefulWidget {
  final QuantumListController<T> controller;
  final Widget Function(
          BuildContext context, int index, T item, Animation<double> animation)
      animationBuilder;
  final QuantumListType type;
  final bool isSliver;
  final SliverGridDelegate? gridDelegate;
  final Axis scrollDirection;
  final Duration animationDuration;
  final ScrollPhysics? physics;
  final bool reverse;
  final EdgeInsetsGeometry? padding;

  const QuantumList({
    Key? key,
    required this.controller,
    required this.animationBuilder,
    this.type = QuantumListType.list,
    this.isSliver = false,
    this.gridDelegate,
    this.scrollDirection = Axis.vertical,
    this.animationDuration = const Duration(milliseconds: 400),
    this.physics,
    this.reverse = false,
    this.padding,
  }) : super(key: key);

  @override
  State<QuantumList<T>> createState() => _QuantumListState<T>();
}

class _QuantumListState<T> extends State<QuantumList<T>> {
  late final GlobalKey _listKey;
  late final ScrollController _scrollController;
  StreamSubscription? _addSubscription;
  StreamSubscription? _insertSubscription;
  StreamSubscription? _removeSubscription;
  StreamSubscription? _moveSubscription;

  dynamic get _animatedState {
    if (_listKey.currentState is AnimatedListState) {
      return _listKey.currentState as AnimatedListState;
    }
    if (_listKey.currentState is SliverAnimatedListState) {
      return _listKey.currentState as SliverAnimatedListState;
    }
    if (_listKey.currentState is AnimatedGridState) {
      return _listKey.currentState as AnimatedGridState;
    }
    if (_listKey.currentState is SliverAnimatedGridState) {
      return _listKey.currentState as SliverAnimatedGridState;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    if (widget.isSliver) {
      if (widget.type == QuantumListType.list) {
        _listKey = GlobalKey<SliverAnimatedListState>();
      } else {
        _listKey = GlobalKey<SliverAnimatedGridState>();
      }
    } else {
      if (widget.type == QuantumListType.list) {
        _listKey = GlobalKey<AnimatedListState>();
      } else {
        _listKey = GlobalKey<AnimatedGridState>();
      }
    }

    if (widget.controller is ScrollableQuantumListController) {
      final scrollableController =
          widget.controller as ScrollableQuantumListController;
      scrollableController.attachScrollController(_scrollController);
      scrollableController.attachEnsureVisibleCallback(_ensureVisible);
    }

    _subscribeToEvents();
  }

  /// **[نهایی]** پیاده‌سازی معماری "پیش-رندر فرا-صفحه‌ای"
  /// **[Final]** Implements the "Off-screen Pre-rendering" architecture.
  Future<void> _ensureVisible(int index,
      {required Duration duration,
      required Curve curve,
      double? alignment}) async {
    if (!mounted) return;

    // Check if the path is already known.
    bool isPathKnown = true;
    for (int i = 0; i < index; i++) {
      if (widget.controller.heightCache[i] == null) {
        isPathKnown = false;
        break;
      }
    }

    // If the path is not fully known, we must measure it off-screen.
    if (!isPathKnown) {
      await _measurePathTo(index);
    }

    // Now that the path is guaranteed to be known, perform the final scroll.
    await _performPreciseScroll(index, duration, curve, alignment);
  }

  /// Measures all unknown item heights up to the target index off-screen.
  Future<void> _measurePathTo(int targetIndex) async {
    final unknownItems = <int, GlobalKey>{};
    for (int i = 0; i < targetIndex; i++) {
      if (widget.controller.heightCache[i] == null) {
        unknownItems[i] = GlobalKey();
      }
    }

    if (unknownItems.isEmpty) return;

    final completer = Completer<void>();
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        // This callback runs after the off-screen widgets have been laid out.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unknownItems.forEach((index, key) {
            final renderBox =
                key.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox != null && renderBox.hasSize) {
              widget.controller
                  .registerItemHeight(index, renderBox.size.height);
            }
          });
          overlayEntry?.remove();
          if (!completer.isCompleted) completer.complete();
        });

        // Build the widgets in an off-screen stack.
        return Stack(
          children: [
            Positioned(
              left: -10000, // Position far off-screen
              top: 0,
              child: Material(
                // Wrap in Material to provide text styles etc.
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: unknownItems.entries.map((entry) {
                    final index = entry.key;
                    final key = entry.value;
                    // We don't need the animation part for measurement.
                    return KeyedSubtree(
                      key: key,
                      child: widget.animationBuilder(
                        context,
                        index,
                        widget.controller[index],
                        const AlwaysStoppedAnimation(1.0),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context)?.insert(overlayEntry);
    return completer.future;
  }

  /// Helper method to perform the final, precise scroll calculation and animation.
  Future<void> _performPreciseScroll(
      int index, Duration duration, Curve curve, double? alignment) async {
    if (!_scrollController.hasClients) return;

    double calculatedOffset = 0;
    for (int i = 0; i < index; i++) {
      calculatedOffset += widget.controller.heightCache[i] ??
          widget.controller.getAverageItemHeight();
    }

    final alignmentValue = alignment ?? 0.0;
    final viewportDimension = _scrollController.position.viewportDimension;
    final targetItemHeight = widget.controller.heightCache[index] ??
        widget.controller.getAverageItemHeight();

    calculatedOffset -= (viewportDimension - targetItemHeight) * alignmentValue;

    final targetOffset = calculatedOffset.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );

    if (duration == Duration.zero) {
      _scrollController.jumpTo(targetOffset);
    } else {
      await _scrollController.animateTo(
        targetOffset,
        duration: duration,
        curve: curve,
      );
    }
  }

  void _subscribeToEvents() {
    _addSubscription = widget.controller.addStream.listen((index) {
      _animatedState?.insertItem(index, duration: widget.animationDuration);
    });
    _insertSubscription = widget.controller.insertStream.listen((index) {
      _animatedState?.insertItem(index, duration: widget.animationDuration);
    });
    _removeSubscription =
        widget.controller.removeStream.listen((RemovedItem<T> removed) {
      if (_animatedState == null) return;
      _animatedState.removeItem(
        removed.index,
        (context, animation) => widget.animationBuilder(
            context, removed.index, removed.item, animation),
        duration: widget.animationDuration,
      );
    });
    _moveSubscription = widget.controller.moveStream.listen((MovedItem moved) {
      if (_animatedState == null) return;
      _animatedState.removeItem(
        moved.oldIndex,
        (context, animation) => const SizedBox.shrink(),
        duration: const Duration(milliseconds: 1),
      );
      _animatedState.insertItem(moved.newIndex,
          duration: widget.animationDuration);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _addSubscription?.cancel();
    _insertSubscription?.cancel();
    _removeSubscription?.cancel();
    _moveSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.controller.length;
    if (widget.isSliver) {
      return _buildSliver(itemCount);
    } else {
      return _buildRegular(itemCount);
    }
  }

  Widget _buildSliver(int itemCount) {
    return const SliverToBoxAdapter(
        child: Text("Sliver not yet fully supported"));
  }

  Widget _buildRegular(int itemCount) {
    switch (widget.type) {
      case QuantumListType.list:
        return AnimatedList(
          key: _listKey,
          controller: _scrollController,
          initialItemCount: itemCount,
          itemBuilder: (context, index, animation) =>
              _itemBuilder(context, index, animation),
        );
      case QuantumListType.grid:
        return AnimatedGrid(
          key: _listKey,
          controller: _scrollController,
          initialItemCount: itemCount,
          gridDelegate: widget.gridDelegate!,
          itemBuilder: (context, index, animation) =>
              _itemBuilder(context, index, animation),
        );
    }
  }

  Widget _itemBuilder(
      BuildContext context, int index, Animation<double> animation) {
    if (index >= widget.controller.length) {
      return const SizedBox.shrink();
    }
    return QuantumPositionTracker(
      index: index,
      controller: widget.controller,
      child: widget.animationBuilder(
          context, index, widget.controller[index], animation),
    );
  }
}

/// This invisible widget measures its child's height and registers it in the controller.
class QuantumPositionTracker extends StatefulWidget {
  final Widget child;
  final int index;
  final QuantumListController controller;

  const QuantumPositionTracker({
    Key? key,
    required this.child,
    required this.index,
    required this.controller,
  }) : super(key: key);

  @override
  State<QuantumPositionTracker> createState() => _QuantumPositionTrackerState();
}

class _QuantumPositionTrackerState extends State<QuantumPositionTracker> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_measureHeight);
  }

  @override
  void didUpdateWidget(covariant QuantumPositionTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback(_measureHeight);
  }

  void _measureHeight(_) {
    if (!mounted) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      widget.controller.registerItemHeight(widget.index, renderBox.size.height);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
