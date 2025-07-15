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

/// The powerful QuantumList widget - Version 2.2.0 with the final scrolling engine
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

  final Map<int, BuildContext> _contextMap = {};

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

  /// **[RE-ARCHITECTED]** Implements the "Jump & Conquer" strategy.
  Future<void> _ensureVisible(int index,
      {required Duration duration,
      required Curve curve,
      required double estimatedItemHeight,
      double? alignment}) async {
    // Step 0: Check if item is already visible. If so, just scroll.
    if (_contextMap.containsKey(index) && _contextMap[index]!.mounted) {
      await _performPreciseScroll(index, duration, curve, alignment);
      return;
    }

    // Step 1: "Jump" - Move to the estimated position to force the item to be built.
    if (!_scrollController.hasClients) return;
    final approximateOffset = (index * estimatedItemHeight).clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.jumpTo(approximateOffset);

    // Wait for the end of the frame to allow the list to build the new items.
    await WidgetsBinding.instance.endOfFrame;

    // Step 2: "Conquer" - After the jump, the item should be built. Now perform the final scroll.
    if (_contextMap.containsKey(index) && _contextMap[index]!.mounted) {
      await _performPreciseScroll(index, duration, curve, alignment);
    } else {
      debugPrint(
          "QuantumList: Failed to bring item at index $index into view after jump. "
          "Consider providing a more accurate 'estimatedItemHeight'.");
    }
  }

  /// Helper method to perform the final, precise scroll calculation and animation.
  Future<void> _performPreciseScroll(
      int index, Duration duration, Curve curve, double? alignment) async {
    if (!mounted ||
        !_contextMap.containsKey(index) ||
        !_contextMap[index]!.mounted ||
        !_scrollController.hasClients) {
      return;
    }

    final listContext = _listKey.currentContext;
    if (listContext == null) return;
    final listRenderBox = listContext.findRenderObject() as RenderBox;

    final itemContext = _contextMap[index]!;
    final itemRenderBox = itemContext.findRenderObject() as RenderBox;

    final position =
        itemRenderBox.localToGlobal(Offset.zero, ancestor: listRenderBox);

    double targetOffset;
    final double itemDimension;
    final double viewportDimension;

    if (widget.scrollDirection == Axis.vertical) {
      itemDimension = itemRenderBox.size.height;
      viewportDimension = _scrollController.position.viewportDimension;
      targetOffset = _scrollController.offset + position.dy;
    } else {
      itemDimension = itemRenderBox.size.width;
      viewportDimension = _scrollController.position.viewportDimension;
      targetOffset = _scrollController.offset + position.dx;
    }

    final alignmentValue = alignment ?? 0.0;
    targetOffset -= (viewportDimension - itemDimension) * alignmentValue;

    targetOffset = targetOffset.clamp(
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
      _contextMap.remove(removed.index);
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
    switch (widget.type) {
      case QuantumListType.list:
        return SliverAnimatedList(
          key: _listKey,
          initialItemCount: itemCount,
          itemBuilder: (context, index, animation) =>
              _itemBuilder(context, index, animation),
        );
      case QuantumListType.grid:
        return SliverAnimatedGrid(
          key: _listKey,
          initialItemCount: itemCount,
          gridDelegate: widget.gridDelegate!,
          itemBuilder: (context, index, animation) =>
              _itemBuilder(context, index, animation),
        );
    }
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
    return Builder(
      builder: (itemContext) {
        _contextMap[index] = itemContext;
        if (index < widget.controller.length) {
          return widget.animationBuilder(
              context, index, widget.controller[index], animation);
        }
        return const SizedBox.shrink();
      },
    );
  }
}
