import 'package:flutter/material.dart';
import 'dart:math';

/// یک ویجت کارت که یک بوردر گرادیانت متحرک و زیبا دور فرزند خود نمایش می‌دهد.
/// A card widget that displays a beautiful, animated gradient border around its child.
class AnimatedBorderCard extends StatefulWidget {
  final Widget child;
  final List<Color> gradientColors;
  final Duration animationDuration;
  final double borderWidth;
  final BorderRadius borderRadius;

  const AnimatedBorderCard({
    Key? key,
    required this.child,
    this.gradientColors = const [Colors.blue, Colors.purple, Colors.red],
    this.animationDuration = const Duration(seconds: 3),
    this.borderWidth = 3.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  }) : super(key: key);

  @override
  State<AnimatedBorderCard> createState() => _AnimatedBorderCardState();
}

class _AnimatedBorderCardState extends State<AnimatedBorderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GradientBorderPainter(
            animation: _controller,
            colors: widget.gradientColors,
            strokeWidth: widget.borderWidth,
            borderRadius: widget.borderRadius,
          ),
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
        ),
        child: ClipRRect(
          borderRadius: widget.borderRadius,
          child: widget.child,
        ),
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Color> colors;
  final double strokeWidth;
  final BorderRadius borderRadius;

  _GradientBorderPainter({
    required this.animation,
    required this.colors,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);

    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..shader = SweepGradient(
        colors: colors,
        startAngle: 0.0,
        endAngle: pi * 2,
        transform: GradientRotation(animation.value * 2 * pi),
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
