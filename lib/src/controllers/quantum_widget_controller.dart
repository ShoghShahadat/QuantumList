import 'package:flutter/material.dart';
import '../enums.dart';
import '../models.dart';
import 'scrollable_quantum_list_controller.dart';

/// The Revolutionary Quantum Widget Controller - v2.2.0
/// This controller allows you to manage your list directly with widgets and their IDs.
class QuantumWidgetController
    extends ScrollableQuantumListController<QuantumEntity> {
  /// Initializes the controller with an optional list of initial quantum entities.
  QuantumWidgetController({List<QuantumEntity> initialItems = const []})
      : super(initialItems);

  /// Adds a new widget with its specific ID to the end of the list.
  /// If an ID already exists, a warning is printed and the operation is aborted.
  @override
  void add(QuantumEntity entity) {
    if (_findIndexById(entity.id) != -1) {
      debugPrint(
          "QuantumWidgetController: An entity with ID '${entity.id}' already exists. Use update() to modify it.");
      return;
    }
    super.add(entity);
  }

  /// Removes a widget from the list based on its ID.
  void remove(String id) {
    final index = _findIndexById(id);
    if (index != -1) {
      super.removeAt(index);
    } else {
      debugPrint(
          "QuantumWidgetController: Entity with ID '$id' not found for removal.");
    }
  }

  /// Updates the widget of an existing entity based on its ID.
  /// This performs an efficient rebuild of only that specific widget in the list.
  void update(String id, Widget newWidget) {
    final index = _findIndexById(id);
    if (index != -1) {
      // Create a new entity with the new widget and replace the old one.
      final newEntity = QuantumEntity(id: id, widget: newWidget);
      items[index] = newEntity;
      // Use the update stream to rebuild only that one item.
      updateNotifier.add(index);
    } else {
      debugPrint(
          "QuantumWidgetController: Entity with ID '$id' not found for update.");
    }
  }

  /// [NEW] Retrieves a QuantumEntity from the list by its unique ID.
  /// Returns null if no entity with the given ID is found.
  QuantumEntity? getById(String id) {
    final index = _findIndexById(id);
    return (index != -1) ? items[index] : null;
  }

  /// Scrolls to a specific widget in the list based on its ID.
  Future<void> scrollTo(
    String id, {
    Duration duration = const Duration(milliseconds: 800),
    QuantumScrollAnimation animation = QuantumScrollAnimation.smooth,
    double alignment = 0.0,
  }) async {
    await super.scrollToItem(
      test: (entity) => entity.id == id,
      duration: duration,
      animation: animation,
      alignment: alignment,
    );
  }

  /// **[CRITICAL FIX]**
  /// The insert method now performs a real insert instead of redirecting to `add`.
  /// This was the root cause of the RangeError during undo operations.
  /// **[اصلاح حیاتی]**
  /// متد insert اکنون یک درج واقعی انجام می‌دهد و دیگر به add تغییر مسیر نمی‌دهد.
  /// این مشکل، ریشه اصلی خطای RangeError در حین عملیات undo بود.
  @override
  void insert(int index, QuantumEntity item) {
    debugPrint(
        "QuantumWidgetController: The insert() method is not recommended for this controller. Use add(entity) for better ID management.");
    if (_findIndexById(item.id) != -1) {
      debugPrint(
          "QuantumWidgetController: An entity with ID '${item.id}' already exists. Insert is aborted to prevent duplicate IDs.");
      return;
    }
    super.insert(index, item);
  }

  /// An internal method to find the index of an entity by its ID.
  int _findIndexById(String id) {
    return items.indexWhere((entity) => entity.id == id);
  }
}
