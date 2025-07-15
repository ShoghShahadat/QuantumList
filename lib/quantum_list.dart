import 'package:flutter/material.dart';
import 'dart:async';

// Exporting the public parts of the package
export 'src/quantum_list_controller.dart';
export 'src/controllers/filterable_quantum_list_controller.dart';
export 'src/controllers/scrollable_quantum_list_controller.dart'; // Export جدید
export 'src/atom_extension.dart';
export 'src/enums.dart';
export 'src/widgets/animated_border_card.dart';

// Importing internal implementation
import 'src/quantum_list_controller.dart';
import 'src/controllers/scrollable_quantum_list_controller.dart';
import 'src/models.dart';
import 'src/enums.dart';

/// ویجت قدرتمند کوانتوم لیست - نسخه 0.9 با قابلیت مدیریت اسکرول
/// The powerful QuantumList widget - Version 0.9 with scroll management
class QuantumList<T> extends StatefulWidget {
  final QuantumListController<T> controller;
  final Widget Function(BuildContext context, int index, T item, Animation<double> animation) animationBuilder;
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

  dynamic get _animatedState {
    if (_listKey.currentState is AnimatedListState) return _listKey.currentState as AnimatedListState;
    if (_listKey.currentState is SliverAnimatedListState) return _listKey.currentState as SliverAnimatedListState;
    if (_listKey.currentState is AnimatedGridState) return _listKey.currentState as AnimatedGridState;
    if (_listKey.currentState is SliverAnimatedGridState) return _listKey.currentState as SliverAnimatedGridState;
    return null;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _listKey = widget.isSliver
        ? GlobalKey(debugLabel: 'SliverQuantumList')
        : (widget.type == QuantumListType.list
            ? GlobalKey<AnimatedListState>(debugLabel: 'QuantumList')
            : GlobalKey<AnimatedGridState>(debugLabel: 'QuantumGrid'));
    
    // اگر کنترلر از نوع اسکرول‌پذیر بود، ScrollController را به آن متصل کن
    if (widget.controller is ScrollableQuantumListController) {
      (widget.controller as ScrollableQuantumListController).attachScrollController(_scrollController);
    }
    
    _subscribeToEvents();
  }

  void _subscribeToEvents() {
    _addSubscription = widget.controller.addStream.listen((index) {
      _animatedState?.insertItem(index, duration: widget.animationDuration);
    });
    _insertSubscription = widget.controller.insertStream.listen((index) {
      _animatedState?.insertItem(index, duration: widget.animationDuration);
    });
    _removeSubscription = widget.controller.removeStream.listen((removed) {
      if (_animatedState == null) return;
      _animatedState.removeItem(
        removed.index,
        (context, animation) => widget.animationBuilder(context, removed.index, removed.item, animation),
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
    // Sliverها ScrollController را از CustomScrollView والد خود می‌گیرند.
    // Slivers get their ScrollController from the parent CustomScrollView.
    // بنابراین ما در اینجا کنترلر داخلی را به آن‌ها نمی‌دهیم.
    // So we don't assign our internal controller here.
    // ...
    return Text("Sliver scroll control needs parent CustomScrollView");
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
          itemBuilder: (context, index, animation) => _itemBuilder(context, index, animation),
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
          itemBuilder: (context, index, animation) => _itemBuilder(context, index, animation),
        );
    }
  }

  Widget _itemBuilder(BuildContext context, int index, Animation<double> animation) {
    if (index >= widget.controller.length) return const SizedBox.shrink();
    return widget.animationBuilder(context, index, widget.controller[index], animation);
  }
}
