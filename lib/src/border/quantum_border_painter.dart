import 'dart:math';
import 'package:flutter/material.dart';
import 'quantum_border.dart';

/// یک نقاش سفارشی که می‌تواند انواع بوردرهای کوانتومی را رسم کند.
/// A custom painter capable of drawing all types of Quantum Borders.
class QuantumBorderPainter extends CustomPainter {
  final QuantumBorder border;
  // **[FIXED]** Instead of the whole Animation object, we now only receive
  // the nullable double value. This decouples the painter from the controller.
  final double? animationValue;

  QuantumBorderPainter({required this.border, this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..strokeWidth = border.strokeWidth;
    final Rect rect = Offset.zero & size;
    // Create a rounded rectangle path based on the border definition.
    final RRect rrect = border.borderRadius.toRRect(rect);

    // Draw the shadow first, so it's underneath the border.
    if (border.shadow != null) {
      final shadowPaint = Paint()
        ..color = border.shadow!.color
        ..maskFilter =
            MaskFilter.blur(BlurStyle.normal, border.shadow!.blurRadius);
      // The shadow is drawn on a slightly shifted RRect to create the offset effect.
      canvas.drawRRect(rrect.shift(border.shadow!.offset), shadowPaint);
    }

    // --- Border Painting Logic ---

    if (border.type == QuantumBorderType.solid) {
      paint
        ..style = PaintingStyle.stroke
        ..color = border.color;
      canvas.drawRRect(rrect, paint);
    } else if (border.type == QuantumBorderType.gradient) {
      paint.style = PaintingStyle.stroke;
      // Create a SweepGradient shader for the animated effect.
      paint.shader = SweepGradient(
        colors: border.gradientColors,
        startAngle: 0.0,
        endAngle: pi * 2,
        // **[FIXED]** We now directly use the animationValue to drive the rotation.
        // If the border is not animated, the value is 0.
        transform: GradientRotation(
            (border.isGradientAnimated ? animationValue ?? 0.0 : 0.0) * 2 * pi),
      ).createShader(rect);
      canvas.drawRRect(rrect, paint);
    } else if (border.type == QuantumBorderType.dashed ||
        border.type == QuantumBorderType.dotted) {
      paint
        ..style = PaintingStyle.stroke
        ..color = border.color;

      // Create a dashed path from the RRect path.
      final Path path = Path()..addRRect(rrect);
      final Path dashedPath = _createDashedPath(path, border.dashPattern);
      canvas.drawPath(dashedPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant QuantumBorderPainter oldDelegate) {
    // **[FIXED]** The painter should now repaint if the border definition changes
    // OR if the animation value for a gradient has changed.
    return oldDelegate.border != border ||
        oldDelegate.animationValue != animationValue;
  }

  /// A helper function to convert a continuous path into a dashed path.
  Path _createDashedPath(Path source, List<double> dashArray) {
    final Path dest = Path();
    // PathMetrics allows us to traverse the path and extract segments.
    final dashMetrics = source.computeMetrics();

    for (final metric in dashMetrics) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        if (dashArray.isEmpty) break;
        // Alternate between drawing a dash and skipping a gap.
        final len = dashArray[draw ? 0 : (dashArray.length > 1 ? 1 : 0)];
        if (draw) {
          // Extract a segment of the path and add it to the destination path.
          dest.addPath(
              metric.extractPath(distance, distance + len), Offset.zero);
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }
}
