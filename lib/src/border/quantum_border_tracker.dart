import 'package:flutter/material.dart';
import 'package:quantum_list/src/border/quantum_border_controller.dart';
import 'package:quantum_list/src/models.dart';

/// A tracker widget that wraps each item in the list.
/// It finds its precise position and size on the screen and reports it
/// to the QuantumBorderController.
class QuantumBorderTracker extends StatefulWidget {
  final Widget child;
  final QuantumBorderController borderController;
  final QuantumEntity entity;
  // **[NEW]** Receives a listenable (the scroll controller) to know when to update its position.
  final Listenable scrollListenable;

  const QuantumBorderTracker({
    Key? key,
    required this.child,
    required this.borderController,
    required this.entity,
    required this.scrollListenable,
  }) : super(key: key);

  @override
  State<QuantumBorderTracker> createState() => _QuantumBorderTrackerState();
}

class _QuantumBorderTrackerState extends State<QuantumBorderTracker> {
  final GlobalKey _widgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Report position after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportPosition());
    // **[FIXED]** Listen for scroll events to report position changes.
    widget.scrollListenable.addListener(_reportPosition);
  }

  @override
  void didUpdateWidget(covariant QuantumBorderTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the scroll controller instance changes, update the listener.
    if (oldWidget.scrollListenable != widget.scrollListenable) {
      oldWidget.scrollListenable.removeListener(_reportPosition);
      widget.scrollListenable.addListener(_reportPosition);
    }
    // Report position on widget update as well.
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportPosition());
  }

  @override
  void dispose() {
    // Clean up the listener and unregister the widget from the border system.
    widget.scrollListenable.removeListener(_reportPosition);
    widget.borderController.unregisterWidget(widget.entity.id);
    super.dispose();
  }

  /// Reports the current global position and size of this widget to the controller.
  void _reportPosition() {
    if (!mounted) return;
    final context = _widgetKey.currentContext;
    final renderBox = context?.findRenderObject() as RenderBox?;

    if (context != null && renderBox != null && renderBox.hasSize) {
      // Find the widget's position relative to the entire screen.
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      // Create a complete report and send it to the controller.
      final info = QuantumWidgetInfo(
        entityId: widget.entity.id,
        position: position,
        size: size,
      );
      widget.borderController.registerWidget(info);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a KeyedSubtree to reliably find the RenderBox.
    return KeyedSubtree(
      key: _widgetKey,
      child: widget.child,
    );
  }
}
