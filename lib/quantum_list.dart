import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quantum_list/src/border/quantum_border_controller.dart';
import 'package:quantum_list/src/border/quantum_border_tracker.dart';
import 'package:quantum_list/src/controllers/controllers.dart';
import 'package:quantum_list/src/enums.dart';
import 'package:quantum_list/src/models.dart';
import 'package:quantum_list/src/widgets/quantum_choreography.dart';
import 'package:quantum_list/src/widgets/quantum_position_tracker.dart';
import 'package:quantum_list/src/widgets/scroll_transformation.dart';

export 'src/controllers/controllers.dart'
    show
        QuantumListController,
        FilterableQuantumListController,
        QuantumWidgetController,
        ScrollableQuantumListController,
        NotifyingQuantumListController,
        TimeTravelQuantumWidgetController,
        PaginatedQuantumListController;

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
export 'src/widgets/quantum_swipe_action.dart';

/// The powerful QuantumList widget.
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
  final ScrollController? scrollController;
  final bool isReorderable;

  const QuantumList({
    Key? key,
    required this.controller,
    required this.animationBuilder,
    this.borderController,
    this.choreography,
    this.scrollTransformation,
    this.scrollController,
    this.type = QuantumListType.list,
    this.isSliver = false,
    this.isReorderable = false,
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
  bool _isInternalScrollController = false;

  int? _draggingIndex;
  int? _dropTargetIndex;

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
    if (widget.scrollController == null) {
      _scrollController = ScrollController();
      _isInternalScrollController = true;
    } else {
      _scrollController = widget.scrollController!;
    }

    if (widget.controller is NotifyingQuantumListController) {
      (widget.controller as NotifyingQuantumListController)
          .attachScrollController(_scrollController);
    }

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
    // This logic would be implemented to scroll to a specific item.
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
      // The move is handled by Draggable, but we listen to keep state consistent if moved externally
    });
  }

  @override
  void dispose() {
    if (_isInternalScrollController) {
      _scrollController.dispose();
    }
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
        assert(widget.gridDelegate != null,
            'gridDelegate must be provided for QuantumListType.grid');
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
            totalItems: widget.controller.length,
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

    if (widget.isReorderable) {
      return _buildReorderableItem(context, index, finalWidget);
    }

    return finalWidget;
  }

  Widget _buildReorderableItem(BuildContext context, int index, Widget child) {
    return DragTarget<int>(
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<int>(
          data: index,
          feedback: Material(
            elevation: 4.0,
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9),
              child: child,
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.4, child: child),
          onDragStarted: () {
            setState(() {
              _draggingIndex = index;
            });
          },
          onDragEnd: (details) {
            setState(() {
              _draggingIndex = null;
              _dropTargetIndex = null;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: _dropTargetIndex == index
                  ? Border.all(
                      color: Theme.of(context).indicatorColor, width: 2)
                  : null,
              borderRadius: BorderRadius.circular(4),
            ),
            child: child,
          ),
        );
      },
      onWillAccept: (fromIndex) {
        return fromIndex != null && fromIndex != index;
      },
      onMove: (details) {
        setState(() {
          _dropTargetIndex = index;
        });
      },
      onLeave: (data) {
        setState(() {
          _dropTargetIndex = null;
        });
      },
      onAccept: (fromIndex) {
        widget.controller.move(fromIndex, index);
        setState(() {
          _dropTargetIndex = null;
        });
      },
    );
  }
}
