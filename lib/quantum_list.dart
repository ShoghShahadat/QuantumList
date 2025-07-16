import 'package:flutter/material.dart';
import 'dart:async';

// Exporting the public parts of the package
export 'src/quantum_list_controller.dart';
export 'src/controllers/filterable_quantum_list_controller.dart';
export 'src/controllers/scrollable_quantum_list_controller.dart';
export 'src/controllers/notifying_quantum_list_controller.dart';
export 'src/controllers/quantum_widget_controller.dart';
export 'src/enums.dart';
export 'src/models.dart';
export 'src/widgets/animated_border_card.dart';
export 'src/widgets/quantum_animations.dart';
export 'src/widgets/quantum_atom.dart';
// Exporting the entire border system
export 'src/border/quantum_border.dart';
export 'src/border/quantum_border_controller.dart';

// Importing internal implementation
import 'src/quantum_list_controller.dart';
import 'src/controllers/scrollable_quantum_list_controller.dart';
import 'src/enums.dart';
import 'src/models.dart';
// Importing internal border system files
import 'src/border/quantum_border_controller.dart';
import 'src/border/quantum_border_overlay.dart';
import 'src/border/quantum_border_tracker.dart';

/// The powerful QuantumList widget - Version 9.0.0 with Quantum Border System
class QuantumList<T> extends StatefulWidget {
  final QuantumListController<T> controller;
  final Widget Function(
          BuildContext context, int index, T item, Animation<double> animation)
      animationBuilder;

  // The border system controller
  final QuantumBorderController? borderController;

  final QuantumListType type;
  final bool isSliver;
  final SliverGridDelegate? gridDelegate;
  final Axis scrollDirection;
  final Duration animationDuration;
  final ScrollPhysics? physics;
  final bool reverse;
  final EdgeInsetsGeometry? padding;
  final int offScreenPreRenderBatchSize;

  const QuantumList({
    Key? key,
    required this.controller,
    required this.animationBuilder,
    this.borderController,
    this.type = QuantumListType.list,
    this.isSliver = false,
    this.gridDelegate,
    this.scrollDirection = Axis.vertical,
    this.animationDuration = const Duration(milliseconds: 400),
    this.physics,
    this.reverse = false,
    this.offScreenPreRenderBatchSize = 50,
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

  Future<void> _ensureVisible(int index,
      {required Duration duration,
      required Curve curve,
      double? alignment}) async {
    if (!mounted) return;

    bool isPathKnown = true;
    for (int i = 0; i < index; i++) {
      if (widget.controller.getCachedHeight(i) == null) {
        isPathKnown = false;
        break;
      }
    }

    if (!isPathKnown) {
      await _measurePathTo(index);
    }

    if (!mounted) return;

    await _performHybridScroll(index, duration, curve, alignment);
  }

  Future<void> _measurePathTo(int targetIndex) async {
    while (true) {
      if (!mounted) return;

      bool isPathKnown = true;
      List<int> unknownIndices = [];
      for (int i = 0; i < targetIndex; i++) {
        if (widget.controller.getCachedHeight(i) == null) {
          isPathKnown = false;
          unknownIndices.add(i);
        }
      }

      if (isPathKnown) {
        break;
      }

      final batch =
          unknownIndices.take(widget.offScreenPreRenderBatchSize).toList();
      await _measureBatchOffScreen(batch);
      await Future.delayed(const Duration(milliseconds: 1));
    }
  }

  Future<void> _measureBatchOffScreen(List<int> indicesToMeasure) async {
    if (indicesToMeasure.isEmpty || !mounted) return;

    final itemsToMeasure = <int, GlobalKey>{};
    for (final index in indicesToMeasure) {
      itemsToMeasure[index] = GlobalKey();
    }

    final completer = Completer<void>();
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          itemsToMeasure.forEach((index, key) {
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

        return Stack(
          children: [
            Positioned(
              left: -10000,
              top: 0,
              child: Material(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: itemsToMeasure.entries.map((entry) {
                    final index = entry.key;
                    final key = entry.value;
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
    Overlay.of(context).insert(overlayEntry);
    return completer.future;
  }

  Future<void> _performHybridScroll(
      int index, Duration duration, Curve curve, double? alignment) async {
    if (!_scrollController.hasClients) return;

    double finalTargetOffset = 0;
    for (int i = 0; i < index; i++) {
      finalTargetOffset += widget.controller.getCachedHeight(i) ??
          widget.controller.getAverageItemHeight();
    }

    final alignmentValue = alignment ?? 0.0;
    final viewportDimension = _scrollController.position.viewportDimension;
    final targetItemHeight = widget.controller.getCachedHeight(index) ??
        widget.controller.getAverageItemHeight();

    finalTargetOffset -=
        (viewportDimension - targetItemHeight) * alignmentValue;

    finalTargetOffset = finalTargetOffset.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );

    final jumpPadding = viewportDimension * 2;
    final direction = finalTargetOffset > _scrollController.offset ? 1.0 : -1.0;
    double jumpTargetOffset = finalTargetOffset - (jumpPadding * direction);

    jumpTargetOffset = jumpTargetOffset.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.jumpTo(jumpTargetOffset);

    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    if (duration == Duration.zero) {
      _scrollController.jumpTo(finalTargetOffset);
    } else {
      await _scrollController.animateTo(
        finalTargetOffset,
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
    Widget listWidget;

    if (widget.isSliver) {
      listWidget = _buildSliver(itemCount);
    } else {
      listWidget = _buildRegular(itemCount);
    }

    if (widget.borderController != null) {
      return QuantumBorderOverlay(
        controller: widget.borderController!,
        child: listWidget,
      );
    }

    return listWidget;
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
          padding: widget.padding,
          itemBuilder: (context, index, animation) =>
              _itemBuilder(context, index, animation),
        );
      case QuantumListType.grid:
        return AnimatedGrid(
          key: _listKey,
          controller: _scrollController,
          initialItemCount: itemCount,
          padding: widget.padding,
          gridDelegate: widget.gridDelegate!,
          itemBuilder: (context, index, animation) =>
              _itemBuilder(context, index, animation),
        );
    }
  }

  /// **[FIXED]** The core of the atomic update fix.
  /// This builder now wraps each item in a StreamBuilder to listen for
  /// targeted update events from the controller.
  Widget _itemBuilder(
      BuildContext context, int index, Animation<double> animation) {
    if (index >= widget.controller.length) {
      return const SizedBox.shrink();
    }

    // This StreamBuilder is the key to atomic updates.
    return StreamBuilder<int>(
      // Listen to the controller's update stream, but only for this specific index.
      stream: widget.controller.updateStream
          .where((updatedIndex) => updatedIndex == index),
      builder: (context, snapshot) {
        // This builder re-runs whenever an update for this index is fired.
        // It fetches the NEWEST version of the item from the controller.
        final item = widget.controller[index];
        Widget child = widget.animationBuilder(context, index, item, animation);

        // The BorderTracker and PositionTracker are applied to the newly built child.
        if (widget.borderController != null && item is QuantumEntity) {
          child = QuantumBorderTracker(
            borderController: widget.borderController!,
            entity: item,
            child: child,
          );
        }

        return QuantumPositionTracker(
          index: index,
          controller: widget.controller,
          child: child,
        );
      },
    );
  }
}

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
