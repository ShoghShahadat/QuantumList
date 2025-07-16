import 'package:flutter/material.dart';
import '../enums.dart';
import '../models.dart';
import 'scrollable_quantum_list_controller.dart';

/// The Revolutionary Quantum Widget Controller - v2.1.0
/// This controller allows you to manage your list directly with widgets and their IDs.
/// No more need for complex data models. Just the widget and its ID!
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

  /// Overriding `insert` to prevent misuse.
  /// In this architecture, adding items is meant to be done via the `add` method.
  @override
  void insert(int index, QuantumEntity item) {
    debugPrint(
        "QuantumWidgetController: The insert() method is not recommended for this controller. Use add(entity) instead.");
    // To prevent potential errors, we redirect it to the add method.
    add(item);
  }

  /// An internal method to find the index of an entity by its ID.
  int _findIndexById(String id) {
    return items.indexWhere((entity) => entity.id == id);
  }
}
