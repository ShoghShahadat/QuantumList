import 'package:flutter/material.dart';

/// A widget that provides swipe-to-reveal actions for any child widget.
/// ویجتی که کنش‌های قابل نمایش با سوایپ را برای هر ویجت فرزندی فراهم می‌کند.
class QuantumSwipeAction extends StatefulWidget {
  final Widget child;
  final List<Widget> leftActions;
  final List<Widget> rightActions;
  final double actionExtent;
  final VoidCallback? onSwipeCompleted;

  const QuantumSwipeAction({
    Key? key,
    required this.child,
    this.leftActions = const [],
    this.rightActions = const [],
    this.actionExtent = 80.0,
    this.onSwipeCompleted,
  }) : super(key: key);

  @override
  State<QuantumSwipeAction> createState() => _QuantumSwipeActionState();
}

class _QuantumSwipeActionState extends State<QuantumSwipeAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  double _dragExtent = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final newExtent = _dragExtent + details.primaryDelta!;
    final totalLeftWidth = widget.leftActions.length * widget.actionExtent;
    final totalRightWidth = widget.rightActions.length * widget.actionExtent;

    // Clamp the drag extent
    setState(() {
      _dragExtent = newExtent.clamp(-totalRightWidth, totalLeftWidth);
    });
  }

  /// **[RE-ARCHITECTED]** The animation logic is now correctly implemented.
  /// **[معماری مجدد]** منطق انیمیشن اکنون به درستی پیاده‌سازی شده است.
  void _onHorizontalDragEnd(DragEndDetails details) {
    double target = 0;
    final totalLeftWidth = widget.leftActions.length * widget.actionExtent;
    final totalRightWidth = widget.rightActions.length * widget.actionExtent;

    // Determine if we should snap open or closed
    if (_dragExtent.abs() > (widget.actionExtent * 0.5)) {
      if (_dragExtent > 0) {
        target = totalLeftWidth;
      } else {
        target = -totalRightWidth;
      }
    }

    // Create a Tween to animate from the current drag position to the target.
    _animation = Tween<Offset>(
      begin: Offset(_dragExtent, 0),
      end: Offset(target, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Listen to the animation to update the state
    _animation.addListener(() {
      setState(() {
        _dragExtent = _animation.value.dx;
      });
    });

    // Reset the controller and start the animation.
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Actions
          if (_dragExtent > 0 && widget.leftActions.isNotEmpty)
            _buildActions(widget.leftActions, Alignment.centerLeft),
          if (_dragExtent < 0 && widget.rightActions.isNotEmpty)
            _buildActions(widget.rightActions, Alignment.centerRight),

          // Foreground Child
          Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget _buildActions(List<Widget> actions, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: actions.map((action) {
          return SizedBox(
            width: widget.actionExtent,
            child: action,
          );
        }).toList(),
      ),
    );
  }
}
