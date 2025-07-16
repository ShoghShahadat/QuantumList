import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'notifying_quantum_list_controller.dart';

/// A specialized controller that now inherits from all other controllers,
/// providing filtering, sorting, scrolling, and notification capabilities all in one.
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
    _currentFilter = test; // Store the current filter

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
      // After sorting, re-apply the current filter to the sorted master list.
      final List<T> targetList = _currentFilter == null
          ? masterList
          : masterList.where(_currentFilter!).toList();
      _diffAndUpdate(targetList);
    } finally {
      _isModifying = false;
    }
  }

  /// Finds the difference between the current list and a target list and manages items with animation.
  void _diffAndUpdate(List<T> targetList) {
    // A more robust diffing algorithm for smoother animations.
    final currentItems = List<T>.from(items);
    final currentSet = HashSet<T>.from(currentItems);
    final targetSet = HashSet<T>.from(targetList);

    // Remove items that are no longer in the target list
    for (int i = currentItems.length - 1; i >= 0; i--) {
      if (!targetSet.contains(currentItems[i])) {
        super.removeAt(i);
      }
    }

    // Add and move items to match the target list order
    for (int i = 0; i < targetList.length; i++) {
      final targetItem = targetList[i];
      if (i >= items.length) {
        // If we are past the end of the current list, just insert
        super.insert(i, targetItem);
      } else if (items[i] != targetItem) {
        // The item at this position is incorrect.
        final oldIndex = items.indexOf(targetItem);
        if (oldIndex != -1) {
          // The item exists elsewhere in the list, so move it to the correct spot.
          super.move(oldIndex, i);
        } else {
          // The item is new to the list, so insert it here.
          super.insert(i, targetItem);
        }
      }
    }
  }

  @override
  void add(T item) {
    masterList.add(item);
    // If a filter is active, the new item is only added to the visible list if it passes the filter.
    if (_currentFilter == null || _currentFilter!(item)) {
      super.add(item);
    }
  }

  @override
  void insert(int index, T item) {
    // Find the reference item in the master list to insert at the correct position
    T? anchorItem = (index < items.length) ? items[index] : null;
    int masterIndex =
        anchorItem != null ? masterList.indexOf(anchorItem) : masterList.length;
    masterList.insert(masterIndex, item);

    // Check the filter before inserting into the visible list
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

  /// [NEW] Clears both the visible list and the master list.
  @override
  void clear() {
    masterList.clear();
    super.clear();
  }
}
