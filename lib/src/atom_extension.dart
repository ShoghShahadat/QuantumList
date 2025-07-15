import 'package:flutter/material.dart';
import 'quantum_list_controller.dart';

/// این اکستنشن جادویی به هر ویجتی اجازه می‌دهد تا با استفاده از متد `.atom()`
/// فقط زمانی که داده‌های مربوط به خودش تغییر می‌کند، بازسازی شود.
///
/// This magical extension allows any widget, using the `.atom()` method,
/// to be rebuilt only when its corresponding data changes.
extension QuantumAtomExtension on Widget {
  Widget atom(QuantumListController controller, int index) {
    return StreamBuilder<int>(
      stream: controller.updateStream.where((updatedIndex) => updatedIndex == index),
      builder: (context, snapshot) {
        return this;
      },
    );
  }
}
