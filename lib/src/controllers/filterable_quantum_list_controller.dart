import 'notifying_quantum_list_controller.dart';

/// یک کنترلر تخصصی که اکنون از تمام کنترلرهای دیگر ارث‌بری کرده
/// و قابلیت‌های فیلترینگ، اسکرول و اطلاع‌رسانی را به صورت یکجا دارد.
///
/// A specialized controller that now inherits from all other controllers,
/// providing filtering, scrolling, and notification capabilities all in one.
class FilterableQuantumListController<T>
    extends NotifyingQuantumListController<T> {
  /// لیست کامل و اصلی که هرگز تغییر نمی‌کند.
  /// The complete and original master list that never changes.
  final List<T> masterList;
  bool _isFiltering = false;

  FilterableQuantumListController(
    List<T> initialItems, {
    super.onAtEnd,
    super.onAtStart,
    super.scrollThreshold,
  })  : masterList = List.from(initialItems),
        super(initialItems);

  /// فیلتر را بر روی لیست اعمال یا حذف می‌کند.
  /// Applies or removes a filter on the list.
  void filter(bool Function(T item)? test) {
    if (_isFiltering) return;
    _isFiltering = true;

    final List<T> targetList =
        test == null ? masterList : masterList.where(test).toList();

    _diffAndUpdate(targetList);

    _isFiltering = false;
  }

  void _diffAndUpdate(List<T> targetList) {
    final currentItems = List<T>.from(items);

    for (int i = currentItems.length - 1; i >= 0; i--) {
      if (!targetList.contains(currentItems[i])) {
        super.removeAt(i);
      }
    }

    for (int i = 0; i < targetList.length; i++) {
      if (i >= items.length || items[i] != targetList[i]) {
        super.insert(i, targetList[i]);
      }
    }
  }

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
    if (index >= 0 && index < items.length) {
      final itemToRemove = items[index];
      masterList.remove(itemToRemove);
      super.removeAt(index);
    }
  }
}
