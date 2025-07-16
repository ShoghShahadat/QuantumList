import 'dart:async';
import 'package:flutter/foundation.dart';
import 'models.dart';

/// The main controller, now with a built-in height cache for hyper-accurate scrolling.
class QuantumListController<T> {
  @protected
  final List<T> items;

  @protected
  final Map<int, double> heightCache = {};

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
      StreamController<MovedItem>.broadcast();

  Stream<int> get updateStream => updateNotifier.stream;
  Stream<int> get addStream => addNotifier.stream;
  Stream<int> get insertStream => insertNotifier.stream;
  Stream<RemovedItem<T>> get removeStream => removeNotifier.stream;
  Stream<MovedItem> get moveStream => moveNotifier.stream;

  QuantumListController(List<T> initialItems) : items = List.from(initialItems);

  void registerItemHeight(int index, double height) {
    if (heightCache[index] != height) {
      heightCache[index] = height;
    }
  }

  /// A public and safe method to access the height cache.
  double? getCachedHeight(int index) => heightCache[index];

  double getAverageItemHeight() {
    if (heightCache.isEmpty) {
      return 100.0;
    }
    double totalHeight = 0;
    heightCache.forEach((key, value) {
      totalHeight += value;
    });
    return totalHeight / heightCache.length;
  }

  void add(T item) {
    final newIndex = items.length;
    items.add(item);
    addNotifier.add(newIndex);
  }

  void insert(int index, T item) {
    items.insert(index, item);
    _shiftCacheKeys(startingFrom: index, by: 1);
    insertNotifier.add(index);
  }

  void removeAt(int index) {
    if (index >= 0 && index < items.length) {
      final T removedItem = items.removeAt(index);
      _shiftCacheKeys(startingFrom: index, by: -1);
      removeNotifier.add(RemovedItem(index, removedItem));
    }
  }

  /// [NEW] Removes all items from the list with animation.
  void clear() {
    for (int i = items.length - 1; i >= 0; i--) {
      removeAt(i);
    }
  }

  void move(int oldIndex, int newIndex) {
    if (oldIndex >= 0 &&
        oldIndex < items.length &&
        newIndex >= 0 &&
        newIndex < items.length) {
      final T item = items.removeAt(oldIndex);
      items.insert(newIndex, item);

      final oldHeight = heightCache.remove(oldIndex);
      if (oldHeight != null) {
        heightCache[newIndex] = oldHeight;
      }

      moveNotifier.add(MovedItem(oldIndex, newIndex));
    }
  }

  void _shiftCacheKeys({required int startingFrom, required int by}) {
    final newCache = <int, double>{};
    heightCache.forEach((key, value) {
      if (key < startingFrom) {
        newCache[key] = value;
      } else {
        newCache[key + by] = value;
      }
    });
    heightCache.clear();
    heightCache.addAll(newCache);
  }

  void updateProperty(int index, Function(T item) updateLogic) {
    if (index >= 0 && index < items.length) {
      updateLogic(items[index]);
      updateNotifier.add(index);
    }
  }

  T operator [](int index) => items[index];
  int get length => items.length;

  /// [NEW] Safely gets the first item, or null if the list is empty.
  T? get first {
    return items.isNotEmpty ? items.first : null;
  }

  /// [NEW] Safely gets the last item, or null if the list is empty.
  T? get last {
    return items.isNotEmpty ? items.last : null;
  }

  void dispose() {
    updateNotifier.close();
    addNotifier.close();
    insertNotifier.close();
    removeNotifier.close();
    moveNotifier.close();
  }
}
