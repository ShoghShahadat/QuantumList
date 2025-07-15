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

/// ویجت قدرتمند کوانتوم لیست - نسخه 1.4.1 با اصلاحات حیاتی
/// The powerful QuantumList widget - Version 1.4.1 with critical fixes
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
    this.animationDuration = const Duration(milliseconds: 300),
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
      scrollableController.attachRectCallback(_getRectForIndex);
    }

    _subscribeToEvents();
  }

  Rect? _getRectForIndex(int index) {
    if (!_contextMap.containsKey(index)) {
      return null;
    }
    final context = _contextMap[index]!;
    // **FIX:** Added a guard to check if the context is still mounted (active) in the tree.
    if (!context.mounted) {
      _contextMap.remove(index); // Clean up defunct context
      return null;
    }
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return null;
    }
    final position = renderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
        position.dx, position.dy, renderBox.size.width, renderBox.size.height);
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
      if (_animatedState == null) {
        return;
      }
      _contextMap.remove(removed.index);
      _animatedState.removeItem(
        removed.index,
        (context, animation) => widget.animationBuilder(
            context, removed.index, removed.item, animation),
        duration: widget.animationDuration,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _addSubscription?.cancel();
    _insertSubscription?.cancel();
    _removeSubscription?.cancel();
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
          key: _listKey as GlobalKey<SliverAnimatedListState>,
          initialItemCount: itemCount,
          itemBuilder: (context, index, animation) =>
              _itemBuilder(context, index, animation),
        );
      case QuantumListType.grid:
        return SliverAnimatedGrid(
          key: _listKey as GlobalKey<SliverAnimatedGridState>,
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
          key: _listKey as GlobalKey<AnimatedListState>,
          controller: _scrollController,
          initialItemCount: itemCount,
          scrollDirection: widget.scrollDirection,
          physics: widget.physics,
          reverse: widget.reverse,
          padding: widget.padding,
          itemBuilder: (context, index, animation) =>
              _itemBuilder(context, index, animation),
        );
      case QuantumListType.grid:
        return AnimatedGrid(
          key: _listKey as GlobalKey<AnimatedGridState>,
          controller: _scrollController,
          initialItemCount: itemCount,
          gridDelegate: widget.gridDelegate!,
          physics: widget.physics,
          reverse: widget.reverse,
          padding: widget.padding,
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
        return widget.animationBuilder(
            context, index, widget.controller[index], animation);
      },
    );
  }
}
