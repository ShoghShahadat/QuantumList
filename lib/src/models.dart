import 'package:flutter/widgets.dart';

/// یک کلاس کمکی برای نگهداری اطلاعات آیتم حذف شده جهت انیمیشن.
/// A helper class to hold information about a removed item for animation purposes.
class RemovedItem<T> {
  final int index;
  final T item;
  RemovedItem(this.index, this.item);
}

/// یک کلاس کمکی برای نگهداری اطلاعات آیتم جابجا شده.
/// A helper class to hold information about a moved item.
class MovedItem {
  final int oldIndex;
  final int newIndex;
  MovedItem(this.oldIndex, this.newIndex);
}

// --- [جدید] بخش انقلابی ---
/// موجودیت کوانتومی: شناسنامه هر ویجت در لیست جدید شما.
/// این کلاس هر ویجت دلخواه را به همراه یک شناسه منحصر به فرد نگهداری می‌کند.
///
/// Quantum Entity: The identity card for each widget in your new list.
/// This class holds any custom widget along with a unique identifier.
class QuantumEntity {
  /// شناسه منحصر به فرد و غیرقابل تغییر ویجت.
  /// The unique and immutable identifier for the widget.
  final String id;

  /// ویجت سفارشی شما که در لیست نمایش داده خواهد شد.
  /// Your custom widget that will be displayed in the list.
  final Widget widget;

  QuantumEntity({
    required this.id,
    required this.widget,
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
