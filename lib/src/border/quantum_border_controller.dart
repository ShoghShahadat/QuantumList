import 'package:flutter/material.dart';
import 'dart:async';
import 'quantum_border.dart';

/// اطلاعات موقعیت و اندازه یک ویجت در صفحه.
class QuantumWidgetInfo {
  final String entityId;
  final Offset position;
  final Size size;

  QuantumWidgetInfo(
      {required this.entityId, required this.position, required this.size});
}

/// اطلاعات یک بوردر فعال به همراه موقعیت فعلی‌اش.
class ActiveBorderInfo {
  final String borderId;
  final QuantumBorder border;
  final QuantumWidgetInfo targetInfo;

  ActiveBorderInfo(
      {required this.borderId, required this.border, required this.targetInfo});
}

/// کنترلر فرماندهی سیستم بوردر.
class QuantumBorderController {
  final Map<String, QuantumWidgetInfo> _widgetRegistry = {};
  final Map<String, QuantumBorder> _borderDefinitions = {};
  final Map<String, String> _borderTargets = {};
  final _updateNotifier = StreamController<List<ActiveBorderInfo>>.broadcast();

  Stream<List<ActiveBorderInfo>> get activeBordersStream =>
      _updateNotifier.stream;

  void registerWidget(QuantumWidgetInfo info) {
    _widgetRegistry[info.entityId] = info;
    _notifyUpdates();
  }

  void unregisterWidget(String entityId) {
    _widgetRegistry.remove(entityId);
    _notifyUpdates();
  }

  void addBorder({
    required String borderId,
    required String targetEntityId,
    required QuantumBorder border,
  }) {
    _borderDefinitions[borderId] = border;
    _borderTargets[borderId] = targetEntityId;
    _notifyUpdates();
  }

  void removeBorder(String borderId) {
    _borderDefinitions.remove(borderId);
    _borderTargets.remove(borderId);
    _notifyUpdates();
  }

  void moveBorder(String borderId, String newTargetEntityId) {
    if (_borderTargets.containsKey(borderId)) {
      _borderTargets[borderId] = newTargetEntityId;
      _notifyUpdates();
    }
  }

  void updateBorder(String borderId, QuantumBorder newBorder) {
    if (_borderDefinitions.containsKey(borderId)) {
      _borderDefinitions[borderId] = newBorder;
      _notifyUpdates();
    }
  }

  QuantumBorder? getBorderDefinition(String borderId) {
    return _borderDefinitions[borderId];
  }

  String? getTargetId(String borderId) {
    return _borderTargets[borderId];
  }

  /// [جدید] اولین بوردر متحرک را پیدا کرده و برمی‌گرداند.
  QuantumBorder? getFirstAnimatedBorder() {
    try {
      final borderId = _borderTargets.keys.firstWhere(
          (id) => _borderDefinitions[id]?.isGradientAnimated ?? false);
      return _borderDefinitions[borderId];
    } catch (e) {
      return null;
    }
  }

  /// [جدید] مدت زمان انیمیشن را بر اساس اولین بوردر متحرک پیدا شده، برمی‌گرداند.
  Duration getAnimationDuration() {
    return getFirstAnimatedBorder()?.animationDuration ??
        const Duration(seconds: 3);
  }

  void _notifyUpdates() {
    final List<ActiveBorderInfo> activeBorders = [];
    _borderTargets.forEach((borderId, entityId) {
      if (_borderDefinitions.containsKey(borderId) &&
          _widgetRegistry.containsKey(entityId)) {
        activeBorders.add(
          ActiveBorderInfo(
            borderId: borderId,
            border: _borderDefinitions[borderId]!,
            targetInfo: _widgetRegistry[entityId]!,
          ),
        );
      }
    });
    _updateNotifier.add(activeBorders);
  }

  void dispose() {
    _updateNotifier.close();
  }
}
