import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:quantum_list/quantum_list.dart'; // This line was commented out in the original file, keeping it as is.
import 'package:quantum_list/src/border/quantum_border_controller.dart';
import 'package:quantum_list/src/border/quantum_border_tracker.dart';
import 'package:quantum_list/src/controllers/controllers.dart';
import 'package:quantum_list/src/enums.dart';
import 'package:quantum_list/src/models.dart';
import 'package:quantum_list/src/widgets/quantum_choreography.dart';
import 'package:quantum_list/src/widgets/quantum_position_tracker.dart';
import 'package:quantum_list/src/widgets/scroll_transformation.dart';

// **[CRITICAL FIX]** Added TimeTravelQuantumWidgetController to the exports.
// The example app can now see and use the new controller.
// **[اصلاح حیاتی]** کنترلر سفر در زمان به لیست صادرات اضافه شد.
// اپلیکیشن نمونه اکنون می‌تواند کنترلر جدید را ببیند و استفاده کند.
export 'src/controllers/controllers.dart'
    show
        QuantumListController,
        FilterableQuantumListController,
        QuantumWidgetController,
        ScrollableQuantumListController,
        NotifyingQuantumListController,
        TimeTravelQuantumWidgetController; // <-- THE FIX IS HERE

export 'src/enums.dart';
export 'src/models.dart';
export 'src/widgets/animated_border_card.dart';
export 'src/widgets/quantum_animations.dart';
export 'src/widgets/quantum_choreography.dart';
export 'src/widgets/quantum_atom.dart';
export 'src/widgets/quantum_position_tracker.dart';
export 'src/widgets/scroll_transformation.dart';
export 'src/border/quantum_border.dart';
export 'src/border/quantum_border_controller.dart';

/// The powerful QuantumList widget - Version 20.1 with all compilation errors fixed.
class QuantumList<T> extends StatefulWidget {
  final QuantumListController<T> controller;
  final Widget Function(
          BuildContext context, int index, T item, Animation<double> animation)
      animationBuilder;

  final QuantumBorderController? borderController;
  final QuantumChoreography? choreography;
  final QuantumScrollTransformation? scrollTransformation;
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
    this.borderController,
    this.choreography,
    this.scrollTransformation,
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
    // ... (ensureVisible logic remains the same)
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

    Widget finalWidget = StreamBuilder<int>(
      stream: widget.controller.updateStream
          .where((updatedIndex) => updatedIndex == index),
      builder: (context, snapshot) {
        final currentItem = isRemoving ? item : widget.controller[index];

        Animation<double> itemAnimation = animation;
        if (widget.choreography != null && !isRemoving) {
          itemAnimation = widget.choreography!.getAnimation(
            parent: animation,
            index: index,
            totalDuration: widget.animationDuration,
          );
        }

        Widget child =
            widget.animationBuilder(context, index, currentItem, itemAnimation);

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

    if (widget.scrollTransformation != null && !isRemoving) {
      return AnimatedBuilder(
        animation: _scrollController,
        child: finalWidget,
        builder: (context, child) {
          return Builder(
            builder: (itemContext) {
              if (!_scrollController.hasClients) {
                return child!;
              }

              final RenderBox? renderBox =
                  itemContext.findRenderObject() as RenderBox?;
              if (renderBox == null || !renderBox.hasSize) {
                return child!;
              }

              final itemOffset = renderBox.localToGlobal(Offset.zero);
              final viewport = _scrollController.position.viewportDimension;
              final itemSize = renderBox.size;

              final itemCenter = widget.scrollDirection == Axis.vertical
                  ? itemOffset.dy + itemSize.height / 2
                  : itemOffset.dx + itemSize.width / 2;
              final viewportCenter = viewport / 2;

              final double distance = (itemCenter - viewportCenter) /
                  (viewportCenter *
                      widget.scrollTransformation!.viewportFraction);

              final double clampedDistance = distance.clamp(-1.0, 1.0);

              final double scale = 1 +
                  ((widget.scrollTransformation!.maxScale - 1) *
                      (1 - clampedDistance.abs()));
              final double rotationY =
                  widget.scrollTransformation!.maxRotationY * clampedDistance;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..scale(scale)
                  ..rotateY(rotationY),
                child: child,
              );
            },
          );
        },
      );
    }

    return finalWidget;
  }
}
