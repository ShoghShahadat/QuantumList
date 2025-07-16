import 'package:flutter/material.dart';
import 'package:quantum_list/src/controllers/controllers.dart';

/// A helper widget that measures its child's height after it has been rendered
/// and registers it with the controller for the "Quantum Jump" scroll feature.
/// این ویجت کمکی، ارتفاع فرزند خود را پس از رندر شدن اندازه‌گیری کرده و
/// برای قابلیت اسکرول دقیق "پرش کوانتومی"، آن را در کنترلر ثبت می‌کند.
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
    // Schedule the measurement to happen after the first frame is built.
    WidgetsBinding.instance.addPostFrameCallback(_measure);
  }

  @override
  void didUpdateWidget(covariant QuantumPositionTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Also measure if the widget is updated.
    WidgetsBinding.instance.addPostFrameCallback(_measure);
  }

  void _measure(_) {
    // Ensure the widget is still mounted before trying to access its context.
    if (!mounted) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      // Register the measured height with the controller.
      widget.controller.registerItemHeight(widget.index, renderBox.size.height);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
