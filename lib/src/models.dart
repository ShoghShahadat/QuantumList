/// یک کلاس کمکی برای نگهداری اطلاعات آیتم حذف شده جهت انیمیشن.
/// A helper class to hold information about a removed item for animation purposes.
class RemovedItem<T> {
  final int index;
  final T item;
  RemovedItem(this.index, this.item);
}

/// **[جدید]** یک کلاس کمکی برای نگهداری اطلاعات آیتم جابجا شده.
/// **[New]** A helper class to hold information about a moved item.
class MovedItem {
  final int oldIndex;
  final int newIndex;
  MovedItem(this.oldIndex, this.newIndex);
}
