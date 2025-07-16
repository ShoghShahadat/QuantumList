import 'package:flutter/material.dart';
import 'package:quantum_list/quantum_list.dart';
import 'dart:async';

// --- [FINALIZED EXPORTS] ---
export 'src/controllers/controllers.dart'
    show
        QuantumListController,
        FilterableQuantumListController,
        QuantumWidgetController,
        ScrollableQuantumListController,
        NotifyingQuantumListController;
export 'src/enums.dart';
export 'src/models.dart';
export 'src/widgets/animated_border_card.dart';
export 'src/widgets/quantum_animations.dart';
export 'src/widgets/quantum_atom.dart';
export 'src/border/quantum_border.dart';
export 'src/border/quantum_border_controller.dart';

// --- [INTERNAL IMPORTS] ---
import 'src/controllers/controllers.dart';
import 'src/models.dart';
import 'src/border/quantum_border_controller.dart';
import 'src/border/quantum_border_tracker.dart';

/// The powerful QuantumList widget - Version 17.0 with configurable Scroll Physics.
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
  // **[NEW]** Allows customizing the scroll physics (e.g., Bouncing, Clamping).
  final ScrollPhysics? physics;
  final bool reverse;
  final EdgeInsetsGeometry? padding;

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
    this.physics, // Added to constructor
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

    if (widget.type == QuantumListType.list) {
      _listKey = GlobalKey<AnimatedListState>();
    } else {
      _listKey = GlobalKey<AnimatedGridState>();
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
      required double alignment}) async {
    if (!mounted || !_scrollController.hasClients) return;

    final averageHeight = widget.controller.getAverageItemHeight();
    double estimatedOffset = index * averageHeight;
    _scrollController.jumpTo(estimatedOffset.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent));

    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    double preciseOffset = 0;
    for (int i = 0; i < index; i++) {
      preciseOffset += widget.controller.getCachedHeight(i) ?? averageHeight;
    }

    final viewportDimension = _scrollController.position.viewportDimension;
    final targetItemHeight =
        widget.controller.getCachedHeight(index) ?? averageHeight;

    preciseOffset -= (viewportDimension - targetItemHeight) * alignment;

    preciseOffset = preciseOffset.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );

    if (duration == Duration.zero) {
      _scrollController.jumpTo(preciseOffset);
    } else {
      await _scrollController.animateTo(
        preciseOffset,
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
        (context, animation) =>
            _itemBuilder(context, removed.index, animation, isRemoving: true),
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
    return _buildList();
  }

  Widget _buildList() {
    final itemCount = widget.controller.length;
    switch (widget.type) {
      case QuantumListType.list:
        return AnimatedList(
          key: _listKey,
          controller: _scrollController,
          initialItemCount: itemCount,
          padding: widget.padding,
          // **[NEW]** Pass the physics property to the underlying list.
          physics: widget.physics,
          reverse: widget.reverse,
          scrollDirection: widget.scrollDirection,
          itemBuilder: (context, index, animation) =>
              _itemBuilder(context, index, animation),
        );
      case QuantumListType.grid:
        return AnimatedGrid(
          key: _listKey,
          controller: _scrollController,
          initialItemCount: itemCount,
          padding: widget.padding,
          // **[NEW]** Pass the physics property to the underlying grid.
          physics: widget.physics,
          reverse: widget.reverse,
          scrollDirection: widget.scrollDirection,
          gridDelegate: widget.gridDelegate!,
          itemBuilder: (context, index, animation) =>
              _itemBuilder(context, index, animation),
        );
    }
  }

  Widget _itemBuilder(
      BuildContext context, int index, Animation<double> animation,
      {bool isRemoving = false}) {
    T item;
    if (isRemoving) {
      final removedItem = widget.controller.lastRemovedItem;
      if (removedItem == null) return const SizedBox.shrink();
      item = removedItem;
    } else {
      if (index >= widget.controller.length) {
        return const SizedBox.shrink();
      }
      item = widget.controller[index];
    }

    return StreamBuilder<int>(
      stream: widget.controller.updateStream
          .where((updatedIndex) => updatedIndex == index),
      builder: (context, snapshot) {
        final currentItem = isRemoving ? item : widget.controller[index];
        Widget child =
            widget.animationBuilder(context, index, currentItem, animation);

        if (widget.borderController != null && currentItem is QuantumEntity) {
          child = QuantumBorderTracker(
            borderController: widget.borderController!,
            entity: currentItem,
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
    WidgetsBinding.instance.addPostFrameCallback(_measure);
  }

  @override
  void didUpdateWidget(covariant QuantumPositionTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback(_measure);
  }

  void _measure(_) {
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
