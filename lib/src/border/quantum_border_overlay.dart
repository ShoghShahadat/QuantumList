import 'package:flutter/material.dart';
import 'quantum_border.dart';
import 'quantum_border_controller.dart';
import 'quantum_border_painter.dart';

/// The main widget for displaying borders over the list.
class QuantumBorderOverlay extends StatefulWidget {
  final Widget child;
  final QuantumBorderController controller;
  // **[NEW]** Receives the scroll controller to know when the list is moving.
  final ScrollController scrollController;

  const QuantumBorderOverlay({
    Key? key,
    required this.child,
    required this.controller,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<QuantumBorderOverlay> createState() => _QuantumBorderOverlayState();
}

class _QuantumBorderOverlayState extends State<QuantumBorderOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.controller.getAnimationDuration(),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // **[FIXED]** The overlay now rebuilds on every scroll event thanks to this AnimatedBuilder.
    // This ensures the `listOffset` is always up-to-date.
    return AnimatedBuilder(
      animation: widget.scrollController,
      builder: (context, child) {
        return StreamBuilder<List<ActiveBorderInfo>>(
          stream: widget.controller.activeBordersStream,
          initialData: const [],
          builder: (context, snapshot) {
            final activeBorders = snapshot.data ?? [];
            // This now correctly finds the RenderObject of the QuantumList itself.
            final listRenderBox = context.findRenderObject() as RenderBox?;
            final listOffset =
                listRenderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

            final newDuration = widget.controller.getAnimationDuration();
            if (_animationController.duration != newDuration) {
              _animationController.duration = newDuration;
              if (_animationController.isAnimating) {
                _animationController.repeat();
              }
            }

            return Stack(
              children: [
                // The list itself
                widget.child,

                // The borders, now correctly positioned
                ...activeBorders.map((borderInfo) {
                  // The calculation is the same, but now both `listOffset` and
                  // `borderInfo.targetInfo.position` are updated on every scroll frame.
                  final position = borderInfo.targetInfo.position - listOffset;

                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: position.dx,
                    top: position.dy,
                    width: borderInfo.targetInfo.size.width,
                    height: borderInfo.targetInfo.size.height,
                    child: CustomPaint(
                      painter: QuantumBorderPainter(
                        border: borderInfo.border,
                        animationValue: borderInfo.border.isGradientAnimated
                            ? _animationController.value
                            : null,
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }
}
