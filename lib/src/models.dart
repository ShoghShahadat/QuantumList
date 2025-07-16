import 'package:flutter/widgets.dart';

/// یک کلاس کمکی برای نگهداری اطلاعات آیتم حذف شده جهت انیمیشن.
class RemovedItem<T> {
  final int index;
  final T item;
  RemovedItem(this.index, this.item);
}

/// یک کلاس کمکی برای نگهداری اطلاعات آیتم جابجا شده.
class MovedItem {
  final int oldIndex;
  final int newIndex;
  MovedItem(this.oldIndex, this.newIndex);
}

/// موجودیت کوانتومی: شناسنامه هر ویجت در لیست شما.
class QuantumEntity {
  /// شناسه منحصر به فرد و غیرقابل تغییر ویجت.
  final String id;

  /// ویجت سفارشی شما که در لیست نمایش داده خواهد شد.
  final Widget widget;

  /// **[NEW]** مشخص می‌کند که آیا این آیتم یک هدر چسبان (مغناطیسی) است یا خیر.
  /// **[جدید]** Determines if this entity is a sticky (magnetic) header.
  final bool isMagnetic;

  QuantumEntity({
    required this.id,
    required this.widget,
    this.isMagnetic = false, // Default to false
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuantumEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
