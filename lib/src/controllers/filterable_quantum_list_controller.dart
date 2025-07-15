import 'package:flutter/foundation.dart';
import 'notifying_quantum_list_controller.dart';

/// یک کنترلر تخصصی که اکنون از تمام کنترلرهای دیگر ارث‌بری کرده
/// و قابلیت‌های فیلترینگ، مرتب‌سازی، اسکرول و اطلاع‌رسانی را به صورت یکجا دارد.
///
/// A specialized controller that now inherits from all other controllers,
/// providing filtering, sorting, scrolling, and notification capabilities all in one.
class FilterableQuantumListController<T>
    extends NotifyingQuantumListController<T> {
  /// لیست کامل و اصلی که هرگز تغییر نمی‌کند.
  final List<T> masterList;
  bool _isModifying = false;

  /// **[جدید]** تابع فیلتر فعلی را نگه می‌دارد.
  bool Function(T item)? _currentFilter;

  FilterableQuantumListController(
    List<T> initialItems, {
    super.onAtEnd,
    super.onAtStart,
    super.scrollThreshold,
  })  : masterList = List.from(initialItems),
        super(initialItems);

  /// فیلتر را بر روی لیست اعمال یا حذف می‌کند.
  void filter(bool Function(T item)? test) {
    if (_isModifying) return;
    _isModifying = true;
    _currentFilter = test; // ذخیره فیلتر فعلی

    try {
      final List<T> targetList =
          test == null ? masterList : masterList.where(test).toList();
      _diffAndUpdate(targetList);
    } finally {
      // **[FIXED]** تضمین می‌کند که پرچم همیشه آزاد می‌شود.
      _isModifying = false;
    }
  }

  /// لیست را بر اساس یک تابع مقایسه‌ای مرتب می‌کند.
  void sort(int Function(T a, T b) compare) {
    if (_isModifying) return;
    _isModifying = true;

    try {
      masterList.sort(compare);
      // پس از مرتب‌سازی، فیلتر فعلی را دوباره اعمال می‌کنیم.
      final List<T> targetList = _currentFilter == null
          ? masterList
          : masterList.where(_currentFilter!).toList();
      _diffAndUpdate(targetList);
    } finally {
      // **[FIXED]** تضمین می‌کند که پرچم همیشه آزاد می‌شود.
      _isModifying = false;
    }
  }

  /// تفاوت بین لیست فعلی و لیست هدف را پیدا کرده و آیتم‌ها را با انیمیشن مدیریت می‌کند.
  void _diffAndUpdate(List<T> targetList) {
    final currentItems = List<T>.from(items);
    final currentSet = Set<T>.from(currentItems);
    final targetSet = Set<T>.from(targetList);

    // حذف آیتم‌هایی که دیگر در لیست هدف نیستند
    for (int i = currentItems.length - 1; i >= 0; i--) {
      if (!targetSet.contains(currentItems[i])) {
        super.removeAt(i);
      }
    }

    // افزودن و جابجایی آیتم‌ها
    for (int i = 0; i < targetList.length; i++) {
      final targetItem = targetList[i];
      if (i >= items.length) {
        // اگر به انتهای لیست رسیدیم، فقط اضافه کن
        super.insert(i, targetItem);
      } else if (items[i] != targetItem) {
        final oldIndex = items.indexOf(targetItem);
        if (oldIndex != -1) {
          // آیتم در لیست وجود دارد، پس آن را جابجا کن
          super.move(oldIndex, i);
        } else {
          // آیتم جدید است، آن را درج کن
          super.insert(i, targetItem);
        }
      }
    }
  }

  @override
  void add(T item) {
    masterList.add(item);
    // **[FIXED]** اگر فیلتری فعال است، آیتم جدید تنها در صورتی اضافه می‌شود که با فیلتر مطابقت داشته باشد.
    if (_currentFilter == null || _currentFilter!(item)) {
      super.add(item);
    }
  }

  @override
  void insert(int index, T item) {
    // پیدا کردن آیتم مرجع در لیست اصلی برای درج در مکان صحیح
    T? anchorItem = (index < items.length) ? items[index] : null;
    int masterIndex =
        anchorItem != null ? masterList.indexOf(anchorItem) : masterList.length;
    masterList.insert(masterIndex, item);

    // **[FIXED]** بررسی فیلتر قبل از درج در لیست قابل مشاهده
    if (_currentFilter == null || _currentFilter!(item)) {
      super.insert(index, item);
    }
  }

  @override
  void removeAt(int index) {
    if (index >= 0 && index < items.length) {
      final itemToRemove = items[index];
      masterList.remove(itemToRemove);
      super.removeAt(index);
    }
  }
}
