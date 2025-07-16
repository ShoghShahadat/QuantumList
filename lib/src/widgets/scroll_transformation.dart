import 'package:flutter/material.dart';

/// A configuration class for defining scroll-based transformations on list items.
/// این کلاس، تنظیمات مربوط به افکت‌های تبدیل (مانند بزرگنمایی و چرخش)
/// بر اساس موقعیت اسکرول را تعریف می‌کند.
@immutable
class QuantumScrollTransformation {
  /// The maximum scale factor applied to the item when it's at the center.
  /// A value of 1.0 means no scaling.
  /// حداکثر میزان بزرگنمایی آیتم وقتی در مرکز صفحه قرار دارد.
  final double maxScale;

  /// The maximum rotation around the Y-axis in radians applied to items
  /// at the edges of the transformation viewport.
  /// حداکثر میزان چرخش سه‌بعدی حول محور Y برای آیتم‌هایی که در لبه‌های محدوده افکت قرار دارند.
  final double maxRotationY;

  /// The fraction of the viewport (vertical or horizontal) that the transformation
  /// effect should be active within. For example, 0.8 means the effect
  /// will apply over 80% of the viewport's height/width.
  /// کسری از صفحه که افکت تبدیل در آن فعال است. مثلا 0.8 یعنی افکت در 80% ارتفاع/عرض صفحه اعمال می‌شود.
  final double viewportFraction;

  const QuantumScrollTransformation({
    this.maxScale = 1.05,
    this.maxRotationY = 0.5, // about 28 degrees
    this.viewportFraction = 0.8,
  });
}
