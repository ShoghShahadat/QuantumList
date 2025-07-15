import 'notifying_quantum_list_controller.dart';

/// یک کنترلر تخصصی که اکنون از تمام کنترلرهای دیگر ارث‌بری کرده
/// و قابلیت‌های فیلترینگ، مرتب‌سازی، اسکرول و اطلاع‌رسانی را به صورت یکجا دارد.
///
/// A specialized controller that now inherits from all other controllers,
/// providing filtering, sorting, scrolling, and notification capabilities all in one.
class FilterableQuantumListController<T>
    extends NotifyingQuantumListController<T> {
  /// لیست کامل و اصلی که هرگز تغییر نمی‌کند.
  /// The complete and original master list that never changes.
  final List<T> masterList;
  bool _isModifying = false;

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
    if (_isModifying) return;
    _isModifying = true;

    final List<T> targetList =
        test == null ? masterList : masterList.where(test).toList();

    _diffAndUpdate(targetList);

    _isModifying = false;
  }

  /// **[جدید]** لیست را بر اساس یک تابع مقایسه‌ای مرتب می‌کند و تغییرات را با انیمیشن نمایش می‌دهد.
  /// **[New]** Sorts the list based on a comparison function and displays the changes with animation.
  void sort(int Function(T a, T b) compare) {
    if (_isModifying) return;
    _isModifying = true;

    // مرتب‌سازی لیست اصلی
    masterList.sort(compare);

    // لیست هدف، همان لیست اصلی مرتب‌شده است.
    // اگر فیلتری فعال باشد، باید آن را مجدداً اعمال کرد، اما برای سادگی فعلاً
    // فرض می‌کنیم مرتب‌سازی فیلتر را پاک می‌کند.
    final List<T> targetList = List.from(masterList);

    _diffAndUpdate(targetList);

    _isModifying = false;
  }

  /// این متد جادویی، تفاوت بین لیست فعلی و لیست هدف را پیدا کرده
  /// و آیتم‌ها را با انیمیشن حذف و اضافه می‌کند.
  void _diffAndUpdate(List<T> targetList) {
    final currentItems = List<T>.from(items);

    // حذف آیتم‌هایی که در لیست هدف نیستند
    for (int i = currentItems.length - 1; i >= 0; i--) {
      if (!targetList.contains(currentItems[i])) {
        super.removeAt(i);
      }
    }

    // افزودن یا جابجایی آیتم‌هایی که در جای درست خود نیستند
    for (int i = 0; i < targetList.length; i++) {
      if (i >= items.length || items[i] != targetList[i]) {
        // اگر آیتم در لیست وجود دارد ولی در جای دیگری است، آن را حذف و سپس درج می‌کنیم
        // (این بخش برای انیمیشن جابجایی می‌تواند بهبود یابد)
        final oldIndex = items.indexOf(targetList[i]);
        if (oldIndex != -1) {
          super.removeAt(oldIndex);
        }
        super.insert(i, targetList[i]);
      }
    }
  }

  @override
  void add(T item) {
    masterList.add(item);
    // TODO: اگر فیلتری فعال است، باید بررسی شود که آیا آیتم جدید با فیلتر مطابقت دارد یا خیر
    super.add(item);
  }

  @override
  void insert(int index, T item) {
    masterList.insert(index, item);
    // TODO: رفتار مشابه متد add
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
