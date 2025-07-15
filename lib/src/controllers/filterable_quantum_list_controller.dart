import '../quantum_list_controller.dart';

/// یک کنترلر تخصصی که قابلیت فیلتر کردن لیست را به صورت بهینه و با انیمیشن فراهم می‌کند.
/// A specialized controller that provides list filtering capabilities efficiently and with animations.
class FilterableQuantumListController<T> extends QuantumListController<T> {
  
  /// لیست کامل و اصلی که هرگز تغییر نمی‌کند.
  /// The complete and original master list that never changes.
  final List<T> masterList;
  bool _isFiltering = false;

  FilterableQuantumListController(List<T> initialItems)
      : masterList = List.from(initialItems),
        super(initialItems);

  /// فیلتر را بر روی لیست اعمال یا حذف می‌کند.
  /// Applies or removes a filter on the list.
  /// 
  /// [test]: منطق فیلتر. اگر نال باشد، فیلتر حذف می‌شود.
  /// [test]: The filter logic. If null, the filter is removed.
  void filter(bool Function(T item)? test) {
    if (_isFiltering) return; // جلوگیری از اجرای همزمان چند فیلتر
    _isFiltering = true;

    final List<T> targetList = test == null ? masterList : masterList.where(test).toList();
    
    // الگوریتم هوشمند برای پیدا کردن تفاوت‌ها و اعمال انیمیشن
    _diffAndUpdate(targetList);

    _isFiltering = false;
  }

  void _diffAndUpdate(List<T> targetList) {
    final currentItems = List<T>.from(items); // آیتم‌های قابل مشاهده فعلی
    
    // 1. حذف آیتم‌هایی که در لیست جدید نیستند
    for (int i = currentItems.length - 1; i >= 0; i--) {
      if (!targetList.contains(currentItems[i])) {
        // از متد اصلی برای حذف و اطلاع‌رسانی استفاده می‌کنیم
        super.removeAt(i);
      }
    }

    // 2. افزودن آیتم‌هایی که در لیست فعلی نیستند، در جای درست خود
    for (int i = 0; i < targetList.length; i++) {
      if (i >= items.length || items[i] != targetList[i]) {
         // از متد اصلی برای درج و اطلاع‌رسانی استفاده می‌کنیم
        super.insert(i, targetList[i]);
      }
    }
  }

  // Override متدهای اصلی برای اطمینان از هماهنگی masterList
  @override
  void add(T item) {
    masterList.add(item);
    super.add(item);
  }

  @override
  void insert(int index, T item) {
    masterList.insert(index, item);
    super.insert(index, item);
  }

  @override
  void removeAt(int index) {
    // پیدا کردن آیتم در masterList و حذف آن
    final itemToRemove = items[index];
    masterList.remove(itemToRemove);
    super.removeAt(index);
  }
}
