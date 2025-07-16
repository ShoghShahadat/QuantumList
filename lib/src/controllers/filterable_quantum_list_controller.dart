import 'dart:collection';
// **[FIXED]** Unused import removed.
import 'controllers.dart';

/// A specialized controller that correctly inherits from NotifyingQuantumListController,
/// providing filtering and sorting capabilities.
class FilterableQuantumListController<T>
    extends NotifyingQuantumListController<T> {
  /// The complete, original list that is manipulated by sort/filter operations.
  final List<T> masterList;
  bool _isModifying = false;

  /// Holds the current filter function.
  bool Function(T item)? _currentFilter;

  FilterableQuantumListController(
    List<T> initialItems, {
    super.onAtEnd,
    super.onAtStart,
    super.scrollThreshold,
  })  : masterList = List.from(initialItems),
        super(initialItems);

  /// Applies or removes a filter on the list.
  void filter(bool Function(T item)? test) {
    if (_isModifying) return;
    _isModifying = true;
    _currentFilter = test;

    try {
      final List<T> targetList =
          test == null ? masterList : masterList.where(test).toList();
      _diffAndUpdate(targetList);
    } finally {
      _isModifying = false;
    }
  }

  /// Sorts the master list and then reapplies the current filter.
  void sort(int Function(T a, T b) compare) {
    if (_isModifying) return;
    _isModifying = true;

    try {
      masterList.sort(compare);
      final List<T> targetList = _currentFilter == null
          ? masterList
          : masterList.where(_currentFilter!).toList();
      _diffAndUpdate(targetList);
    } finally {
      _isModifying = false;
    }
  }

  void _diffAndUpdate(List<T> targetList) {
    // **[FIXED]** Unnecessary 'this.' qualifier removed.
    final currentItems = List<T>.from(items);
    final targetSet = HashSet<T>.from(targetList);

    for (int i = currentItems.length - 1; i >= 0; i--) {
      if (!targetSet.contains(currentItems[i])) {
        super.removeAt(i);
      }
    }

    for (int i = 0; i < targetList.length; i++) {
      final targetItem = targetList[i];
      if (i >= items.length) {
        super.insert(i, targetItem);
      } else if (items[i] != targetItem) {
        final oldIndex = items.indexOf(targetItem);
        if (oldIndex != -1) {
          super.move(oldIndex, i);
        } else {
          super.insert(i, targetItem);
        }
      }
    }
  }

  @override
  void add(T item) {
    masterList.add(item);
    if (_currentFilter == null || _currentFilter!(item)) {
      super.add(item);
    }
  }

  @override
  void insert(int index, T item) {
    T? anchorItem = (index < items.length) ? items[index] : null;
    int masterIndex =
        anchorItem != null ? masterList.indexOf(anchorItem) : masterList.length;
    masterList.insert(masterIndex, item);

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

  @override
  void clear() {
    masterList.clear();
    super.clear();
  }
}
