import 'dart:async';
import 'package:flutter/foundation.dart';
import 'models.dart';

/// کنترلر اصلی که اکنون از جابجایی آیتم‌ها نیز پشتیبانی می‌کند.
/// The main controller, now supporting item moving.
class QuantumListController<T> {
  @protected
  final List<T> items;

  @protected
  final StreamController<int> updateNotifier =
      StreamController<int>.broadcast();
  @protected
  final StreamController<int> addNotifier = StreamController<int>.broadcast();
  @protected
  final StreamController<int> insertNotifier =
      StreamController<int>.broadcast();
  @protected
  final StreamController<RemovedItem<T>> removeNotifier =
      StreamController<RemovedItem<T>>.broadcast();
  @protected
  final StreamController<MovedItem> moveNotifier =
      StreamController<MovedItem>.broadcast(); // **[جدید]**

  Stream<int> get updateStream => updateNotifier.stream;
  Stream<int> get addStream => addNotifier.stream;
  Stream<int> get insertStream => insertNotifier.stream;
  Stream<RemovedItem<T>> get removeStream => removeNotifier.stream;
  Stream<MovedItem> get moveStream => moveNotifier.stream; // **[جدید]**

  QuantumListController(List<T> initialItems) : items = List.from(initialItems);

  void add(T item) {
    final newIndex = items.length;
    items.add(item);
    addNotifier.add(newIndex);
  }

  void insert(int index, T item) {
    items.insert(index, item);
    insertNotifier.add(index);
  }

  void removeAt(int index) {
    if (index >= 0 && index < items.length) {
      final T removedItem = items.removeAt(index);
      removeNotifier.add(RemovedItem(index, removedItem));
    }
  }

  /// **[جدید]** یک آیتم را از یک ایندکس به ایندکس دیگر منتقل می‌کند.
  void move(int oldIndex, int newIndex) {
    if (oldIndex >= 0 &&
        oldIndex < items.length &&
        newIndex >= 0 &&
        newIndex < items.length) {
      final T item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
      moveNotifier.add(MovedItem(oldIndex, newIndex));
    }
  }

  void updateProperty(int index, Function(T item) updateLogic) {
    if (index >= 0 && index < items.length) {
      updateLogic(items[index]);
      updateNotifier.add(index);
    }
  }

  T operator [](int index) => items[index];
  int get length => items.length;

  void dispose() {
    updateNotifier.close();
    addNotifier.close();
    insertNotifier.close();
    removeNotifier.close();
    moveNotifier.close(); // **[جدید]**
  }
}
