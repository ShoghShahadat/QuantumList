import 'package:flutter/material.dart';
import '../quantum_list_controller.dart';

/// یک ویجت هوشمند که به سیگنال‌های آپدیت کنترلر گوش می‌دهد
/// و تنها زمانی که لازم است، فرزند خود را بازسازی می‌کند.
///
/// A smart widget that listens to the controller's update signals
/// and rebuilds its child only when necessary.
class QuantumAtom extends StatelessWidget {
  final QuantumListController controller;
  final int index;
  final WidgetBuilder builder;

  const QuantumAtom({
    Key? key,
    required this.controller,
    required this.index,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: controller.updateStream
          .where((updatedIndex) => updatedIndex == index),
      builder: (context, snapshot) {
        // این builder در اولین ساخت و همچنین هر بار که سیگنال آپدیت برای این index خاص می‌آید،
        // فراخوانی شده و ویجت فرزند را با داده‌های جدید بازسازی می‌کند.
        return builder(context);
      },
    );
  }
}
