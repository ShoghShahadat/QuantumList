import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models.dart';
import 'quantum_widget_controller.dart';

// --- بخش فرمان (Command Pattern) ---

/// یک رابط برای تمام دستوراتی که می‌توانند اجرا و خنثی شوند.
@immutable
abstract class _QuantumCommand {
  const _QuantumCommand();

  /// یک توضیح متنی از دستور برای نمایش در دیباگر.
  String get description;

  /// دستور را برای عملیات Redo اجرا می‌کند.
  void execute(TimeTravelQuantumWidgetController controller);

  /// دستور را برای عملیات Undo خنثی می‌کند.
  void undo(TimeTravelQuantumWidgetController controller);
}

/// دستور افزودن یک آیتم.
class _AddCommand extends _QuantumCommand {
  final QuantumEntity item;
  const _AddCommand(this.item);

  @override
  String get description => 'ADD: ${item.id}';

  @override
  void execute(TimeTravelQuantumWidgetController controller) {
    controller.add(item);
  }

  @override
  void undo(TimeTravelQuantumWidgetController controller) {
    controller.remove(item.id);
  }
}

/// دستور حذف یک آیتم.
class _RemoveCommand extends _QuantumCommand {
  final QuantumEntity item;
  final int index;
  const _RemoveCommand(this.item, this.index);

  @override
  String get description => 'REMOVE: ${item.id}';

  @override
  void execute(TimeTravelQuantumWidgetController controller) {
    controller.remove(item.id);
  }

  @override
  void undo(TimeTravelQuantumWidgetController controller) {
    controller.insert(index, item);
  }
}

/// دستور آپدیت کردن یک آیتم.
class _UpdateCommand extends _QuantumCommand {
  final String id;
  final Widget newWidget;
  final Widget oldWidget;

  const _UpdateCommand({
    required this.id,
    required this.newWidget,
    required this.oldWidget,
  });

  @override
  String get description => 'UPDATE: $id';

  @override
  void execute(TimeTravelQuantumWidgetController controller) {
    controller.update(id, newWidget);
  }

  @override
  void undo(TimeTravelQuantumWidgetController controller) {
    controller.update(id, oldWidget);
  }
}

// --- کنترلر سفر در زمان (نسخه مجهز به تاریخچه خوانا) ---
class TimeTravelQuantumWidgetController extends QuantumWidgetController {
  final List<_QuantumCommand> _undoStack = [];
  final List<_QuantumCommand> _redoStack = [];
  final _historyController = StreamController<void>.broadcast();

  bool _isInternalModification = false;

  Stream<void> get historyStream => _historyController.stream;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  /// **[NEW]** A public getter to expose the command history for the debugger.
  /// **[جدید]** یک گتر عمومی برای ارائه تاریخچه دستورات به دیباگر.
  List<_QuantumCommand> get commandHistory => List.unmodifiable(_undoStack);
  List<_QuantumCommand> get redoHistory => List.unmodifiable(_redoStack);

  /// آخرین دستور را خنثی می‌کند.
  void undo() {
    if (canUndo) {
      final command = _undoStack.removeLast();
      _isInternalModification = true;
      command.undo(this);
      _isInternalModification = false;
      _redoStack.add(command);
      _historyController.add(null);
    }
  }

  /// آخرین دستور خنثی شده را مجدداً اجرا می‌کند.
  void redo() {
    if (canRedo) {
      final command = _redoStack.removeLast();
      _isInternalModification = true;
      command.execute(this);
      _isInternalModification = false;
      _undoStack.add(command);
      _historyController.add(null);
    }
  }

  void _logCommand(_QuantumCommand command) {
    _undoStack.add(command);
    _redoStack.clear();
    _historyController.add(null);
  }

  @override
  void add(QuantumEntity entity) {
    super.add(entity);
    if (_isInternalModification) return;
    _logCommand(_AddCommand(entity));
  }

  @override
  void remove(String id) {
    final index = items.indexWhere((e) => e.id == id);
    if (index != -1) {
      final entity = items[index];
      super.remove(id);
      if (_isInternalModification) return;
      _logCommand(_RemoveCommand(entity, index));
    }
  }

  @override
  void insert(int index, QuantumEntity item) {
    super.insert(index, item);
    if (_isInternalModification) return;
  }

  @override
  void update(String id, Widget newWidget) {
    final oldEntity = getById(id);
    if (oldEntity != null) {
      super.update(id, newWidget);
      if (_isInternalModification) return;
      _logCommand(_UpdateCommand(
        id: id,
        newWidget: newWidget,
        oldWidget: oldEntity.widget,
      ));
    }
  }

  @override
  void dispose() {
    _historyController.close();
    super.dispose();
  }
}
