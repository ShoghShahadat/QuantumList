import 'package:flutter/material.dart';
import 'dart:async';
import 'quantum_border.dart';

// [DEPRECATED] This class is no longer needed as the controller no longer tracks position.
// class QuantumWidgetInfo { ... }

/// **[RE-ARCHITECTED]**
/// This class now holds the essential information about an active border,
/// linking a border's ID and its visual definition to the ID of the widget it targets.
/// It no longer needs to know about the widget's position or size.
class ActiveBorderInfo {
  final String borderId;
  final String targetEntityId;
  final QuantumBorder border;

  ActiveBorderInfo({
    required this.borderId,
    required this.targetEntityId,
    required this.border,
  });
}

/// **[RE-ARCHITECTED V2.0]**
/// The command center for the border system, now massively simplified.
/// It no longer tracks widget positions or sizes, making it more robust and efficient.
/// Its sole responsibility is to maintain the relationship between borders and their targets.
class QuantumBorderController {
  // --- STATE ---
  /// Stores the visual definition (color, width, etc.) for each border.
  /// Key: borderId, Value: QuantumBorder definition
  final Map<String, QuantumBorder> _borderDefinitions = {};

  /// Stores the current target for each border.
  /// Key: borderId, Value: entityId of the target widget
  final Map<String, String> _borderTargets = {};

  /// The stream that notifies listeners (the QuantumBorderTracker widgets)
  /// about the current state of all active borders.
  final _updateNotifier = StreamController<List<ActiveBorderInfo>>.broadcast();

  // --- PUBLIC API ---

  /// The public stream that widgets listen to for updates.
  Stream<List<ActiveBorderInfo>> get activeBordersStream =>
      _updateNotifier.stream;

  /// **[REMOVED]** `registerWidget` is no longer needed.
  /// **[REMOVED]** `unregisterWidget` is no longer needed.

  /// Creates a new border definition and assigns it to a target widget.
  void addBorder({
    required String borderId,
    required String targetEntityId,
    required QuantumBorder border,
  }) {
    _borderDefinitions[borderId] = border;
    _borderTargets[borderId] = targetEntityId;
    _notifyUpdates();
  }

  /// Removes a border completely from the system.
  void removeBorder(String borderId) {
    _borderDefinitions.remove(borderId);
    _borderTargets.remove(borderId);
    _notifyUpdates();
  }

  /// Moves an existing border to a new target widget.
  void moveBorder(String borderId, String newTargetEntityId) {
    if (_borderTargets.containsKey(borderId)) {
      _borderTargets[borderId] = newTargetEntityId;
      _notifyUpdates();
    }
  }

  /// Updates the visual definition of an existing border.
  void updateBorder(String borderId, QuantumBorder newBorder) {
    if (_borderDefinitions.containsKey(borderId)) {
      _borderDefinitions[borderId] = newBorder;
      _notifyUpdates();
    }
  }

  /// Retrieves the current visual definition for a given border ID.
  QuantumBorder? getBorderDefinition(String borderId) {
    return _borderDefinitions[borderId];
  }

  /// Retrieves the ID of the widget that a given border is currently targeting.
  String? getTargetId(String borderId) {
    return _borderTargets[borderId];
  }

  /// Finds the first border that has an active gradient animation.
  QuantumBorder? getFirstAnimatedBorder() {
    try {
      final borderId = _borderTargets.keys.firstWhere(
          (id) => _borderDefinitions[id]?.isGradientAnimated ?? false);
      return _borderDefinitions[borderId];
    } catch (e) {
      // Throws if not found
      return null;
    }
  }

  /// Gets the animation duration from the first found animated border.
  Duration getAnimationDuration() {
    return getFirstAnimatedBorder()?.animationDuration ??
        const Duration(seconds: 3);
  }

  /// This private method is the heart of the controller. It compiles the current
  /// state of all borders and pushes it out through the stream.
  void _notifyUpdates() {
    final List<ActiveBorderInfo> activeBorders = [];
    _borderTargets.forEach((borderId, entityId) {
      // Only create an ActiveBorderInfo if the border has a valid definition.
      if (_borderDefinitions.containsKey(borderId)) {
        activeBorders.add(
          ActiveBorderInfo(
            borderId: borderId,
            targetEntityId: entityId,
            border: _borderDefinitions[borderId]!,
          ),
        );
      }
    });
    // Notify all listeners of the new state.
    _updateNotifier.add(activeBorders);
  }

  /// Cleans up the stream controller when this object is disposed.
  void dispose() {
    _updateNotifier.close();
  }
}
