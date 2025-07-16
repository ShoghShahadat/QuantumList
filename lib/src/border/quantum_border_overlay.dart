import 'package:flutter/material.dart';
import 'quantum_border.dart';
import 'quantum_border_controller.dart';
import 'quantum_border_painter.dart';

/// ویجت اصلی برای نمایش بوردرها بر روی لیست.
class QuantumBorderOverlay extends StatefulWidget {
  final Widget child;
  final QuantumBorderController controller;

  const QuantumBorderOverlay({
    Key? key,
    required this.child,
    required this.controller,
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
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return StreamBuilder<List<ActiveBorderInfo>>(
          stream: widget.controller.activeBordersStream,
          initialData: const [],
          builder: (context, snapshot) {
            final activeBorders = snapshot.data ?? [];
            final listRenderBox = context.findRenderObject() as RenderBox?;
            final listOffset =
                listRenderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

            // مدت زمان انیمیشن را یک بار در هر بیلد بررسی و بروزرسانی می‌کنیم
            final newDuration = widget.controller.getAnimationDuration();
            if (_animationController.duration != newDuration) {
              _animationController.duration = newDuration;
              if (_animationController.isAnimating) {
                _animationController.repeat();
              }
            }

            return Stack(
              children: [
                // لایه اول: خود لیست
                widget.child,

                // لایه‌های بعدی: هر بوردر فعال
                ...activeBorders.map((borderInfo) {
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
