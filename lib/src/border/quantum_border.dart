import 'package:flutter/material.dart';

/// انواع مختلف بوردرهایی که می‌توان ایجاد کرد را مشخص می‌کند.
enum QuantumBorderType {
  solid,
  gradient,
  dashed,
  dotted,
}

/// کلاس اصلی برای تعریف ظاهر و حس یک بوردر کوانتومی.
@immutable
class QuantumBorder {
  final QuantumBorderType type;
  final double strokeWidth;
  final Color color;
  final List<Color> gradientColors;
  final List<double> dashPattern;
  final BorderRadius borderRadius;
  final BoxShadow? shadow;
  final bool isGradientAnimated;
  final Duration animationDuration;

  const QuantumBorder({
    this.type = QuantumBorderType.solid,
    this.strokeWidth = 2.0,
    this.color = Colors.white,
    this.gradientColors = const [Colors.blue, Colors.purple],
    this.dashPattern = const [5, 5],
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.shadow,
    this.isGradientAnimated = false,
    this.animationDuration = const Duration(seconds: 3),
  });

  factory QuantumBorder.animatedGradient({
    List<Color>? colors,
    double strokeWidth = 3.0,
    BorderRadius? borderRadius,
    BoxShadow? shadow,
  }) {
    return QuantumBorder(
      type: QuantumBorderType.gradient,
      gradientColors: colors ?? [Colors.cyan, Colors.pink, Colors.yellow],
      strokeWidth: strokeWidth,
      borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(14)),
      isGradientAnimated: true,
      shadow: shadow,
    );
  }

  factory QuantumBorder.dashed({
    Color color = Colors.white,
    double strokeWidth = 2.0,
    List<double> pattern = const [8, 4],
    BorderRadius? borderRadius,
    BoxShadow? shadow,
  }) {
    return QuantumBorder(
      type: QuantumBorderType.dashed,
      color: color,
      strokeWidth: strokeWidth,
      dashPattern: pattern,
      borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(14)),
      shadow: shadow,
    );
  }

  factory QuantumBorder.dotted({
    Color color = Colors.white,
    double strokeWidth = 2.0,
    BorderRadius? borderRadius,
    BoxShadow? shadow,
  }) {
    return QuantumBorder(
      type: QuantumBorderType.dotted,
      color: color,
      strokeWidth: strokeWidth,
      dashPattern: [1, 3],
      borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(14)),
      shadow: shadow,
    );
  }

  /// [جدید] یک کپی از این بوردر با مقادیر تغییر یافته ایجاد می‌کند.
  QuantumBorder copyWith({
    QuantumBorderType? type,
    double? strokeWidth,
    Color? color,
    List<Color>? gradientColors,
    List<double>? dashPattern,
    BorderRadius? borderRadius,
    BoxShadow? shadow,
    bool? isGradientAnimated,
    Duration? animationDuration,
  }) {
    return QuantumBorder(
      type: type ?? this.type,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      color: color ?? this.color,
      gradientColors: gradientColors ?? this.gradientColors,
      dashPattern: dashPattern ?? this.dashPattern,
      borderRadius: borderRadius ?? this.borderRadius,
      shadow: shadow ?? this.shadow,
      isGradientAnimated: isGradientAnimated ?? this.isGradientAnimated,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}
