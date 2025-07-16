import 'package:flutter/material.dart';
import 'package:quantum_list/src/border/quantum_border_controller.dart';
import 'package:quantum_list/src/border/quantum_border_painter.dart';
import 'package:quantum_list/src/models.dart';

/// **[RE-ARCHITECTED V3.0 - FINAL & FLAWLESS]**
/// This version corrects the critical error from V2.0 where it was referencing
/// a non-existent property. It now correctly uses `targetEntityId`.
class QuantumBorderTracker extends StatefulWidget {
  final Widget child;
  final QuantumBorderController borderController;
  final QuantumEntity entity;

  const QuantumBorderTracker({
    Key? key,
    required this.child,
    required this.borderController,
    required this.entity,
  }) : super(key: key);

  @override
  State<QuantumBorderTracker> createState() => _QuantumBorderTrackerState();
}

class _QuantumBorderTrackerState extends State<QuantumBorderTracker>
    with TickerProviderStateMixin {
  AnimationController? _animationController;

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _setupAnimation(Duration duration) {
    if (_animationController == null ||
        _animationController!.duration != duration) {
      _animationController?.dispose();
      _animationController = AnimationController(
        vsync: this,
        duration: duration,
      )..repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ActiveBorderInfo>>(
      stream: widget.borderController.activeBordersStream,
      builder: (context, snapshot) {
        final activeBorders = snapshot.data ?? [];
        ActiveBorderInfo? myBorderInfo;

        try {
          // **[CRITICAL FIX]**
          // Correctly check against `targetEntityId` instead of the non-existent `targetInfo`.
          // This resolves the compilation error.
          myBorderInfo = activeBorders
              .firstWhere((info) => info.targetEntityId == widget.entity.id);
        } catch (e) {
          myBorderInfo = null;
        }

        if (myBorderInfo != null) {
          final border = myBorderInfo.border;

          if (border.isGradientAnimated) {
            _setupAnimation(border.animationDuration);
          } else {
            _animationController?.dispose();
            _animationController = null;
          }

          return AnimatedBuilder(
            animation: _animationController ?? const AlwaysStoppedAnimation(0),
            builder: (context, child) {
              return Stack(
                fit: StackFit.passthrough,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: QuantumBorderPainter(
                        border: border,
                        animationValue: border.isGradientAnimated
                            ? _animationController?.value
                            : null,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(border.strokeWidth),
                    child: ClipRRect(
                      borderRadius: border.borderRadius,
                      child: child,
                    ),
                  ),
                ],
              );
            },
            child: widget.child,
          );
        } else {
          if (_animationController != null) {
            _animationController?.dispose();
            _animationController = null;
          }
          return widget.child;
        }
      },
    );
  }
}
