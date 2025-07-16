import 'package:flutter/material.dart';
import 'package:quantum_list/src/border/quantum_border_controller.dart';
import 'package:quantum_list/src/models.dart';

/// یک ویجت ردیاب که به دور هر آیتم در لیست قرار می‌گیرد.
/// وظیفه آن پیدا کردن موقعیت و اندازه دقیق خود در صفحه و گزارش آن
/// به QuantumBorderController است.
class QuantumBorderTracker extends StatefulWidget {
  final Widget child;
  final QuantumBorderController borderController;
  final QuantumEntity entity; // ویجت باید از نوع QuantumEntity باشد

  const QuantumBorderTracker({
    Key? key,
    required this.child,
    required this.borderController,
    required this.entity,
  }) : super(key: key);

  @override
  State<QuantumBorderTracker> createState() => _QuantumBorderTrackerState();
}

class _QuantumBorderTrackerState extends State<QuantumBorderTracker> {
  final GlobalKey _widgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // پس از اولین رندر، موقعیت را ثبت کن
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportPosition());
  }

  @override
  void didUpdateWidget(covariant QuantumBorderTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // با هر به‌روزرسانی ویجت، موقعیت را دوباره گزارش کن
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportPosition());
  }

  @override
  void dispose() {
    // هنگام حذف ویجت از لیست، آن را از سیستم بوردر نیز حذف کن
    widget.borderController.unregisterWidget(widget.entity.id);
    super.dispose();
  }

  void _reportPosition() {
    if (!mounted) return;
    final context = _widgetKey.currentContext;
    final renderBox = context?.findRenderObject() as RenderBox?;

    if (context != null && renderBox != null && renderBox.hasSize) {
      // پیدا کردن موقعیت ویجت نسبت به کل صفحه
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      // ساخت یک گزارش کامل و ارسال آن به کنترلر
      final info = QuantumWidgetInfo(
        entityId: widget.entity.id,
        position: position,
        size: size,
      );
      widget.borderController.registerWidget(info);
    }
  }

  @override
  Widget build(BuildContext context) {
    // از یک کلید برای پیدا کردن RenderBox استفاده می‌کنیم
    return KeyedSubtree(
      key: _widgetKey,
      child: widget.child,
    );
  }
}
