import 'dart:math';
import 'package:flutter/material.dart';
import 'quantum_border.dart';

/// یک نقاش سفارشی که می‌تواند انواع بوردرهای کوانتومی را رسم کند.
class QuantumBorderPainter extends CustomPainter {
  final QuantumBorder border;
  // **[اصلاح شد]** به جای کل انیمیشن، فقط مقدار عددی آن را دریافت می‌کنیم.
  final double? animationValue;

  QuantumBorderPainter({required this.border, this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..strokeWidth = border.strokeWidth;
    final Rect rect = Offset.zero & size;
    final RRect rrect = border.borderRadius.toRRect(rect);

    if (border.shadow != null) {
      final shadowPaint = Paint()
        ..color = border.shadow!.color
        ..maskFilter =
            MaskFilter.blur(BlurStyle.normal, border.shadow!.blurRadius);
      canvas.drawRRect(rrect.shift(border.shadow!.offset), shadowPaint);
    }

    if (border.type == QuantumBorderType.solid) {
      paint
        ..style = PaintingStyle.stroke
        ..color = border.color;
      canvas.drawRRect(rrect, paint);
    } else if (border.type == QuantumBorderType.gradient) {
      paint.style = PaintingStyle.stroke;
      paint.shader = SweepGradient(
        colors: border.gradientColors,
        startAngle: 0.0,
        endAngle: pi * 2,
        // **[اصلاح شد]** مستقیماً از مقدار انیمیشن استفاده می‌کنیم.
        transform: GradientRotation(
            (border.isGradientAnimated ? animationValue ?? 0.0 : 0.0) * 2 * pi),
      ).createShader(rect);
      canvas.drawRRect(rrect, paint);
    } else if (border.type == QuantumBorderType.dashed ||
        border.type == QuantumBorderType.dotted) {
      paint
        ..style = PaintingStyle.stroke
        ..color = border.color;

      final Path path = Path()..addRRect(rrect);
      final Path dashedPath = dashPath(path, border.dashPattern);
      canvas.drawPath(dashedPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant QuantumBorderPainter oldDelegate) {
    // **[اصلاح شد]** اکنون بازрисов بر اساس تغییر مقدار انیمیشن نیز انجام می‌شود.
    return oldDelegate.border != border ||
        oldDelegate.animationValue != animationValue;
  }

  Path dashPath(Path source, List<double> dashArray) {
    final Path dest = Path();
    final dashMetrics = source.computeMetrics();

    for (final metric in dashMetrics) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        if (dashArray.isEmpty) break;
        final len = dashArray[draw ? 0 : (dashArray.length > 1 ? 1 : 0)];
        if (draw) {
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
