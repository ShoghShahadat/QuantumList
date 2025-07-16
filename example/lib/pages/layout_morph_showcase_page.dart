import 'dart:math';
import 'package:example/widgets/sample_widget.dart';
import 'package:flutter/material.dart';
import 'package:quantum_list/quantum_list.dart';

/// صفحه‌ای برای نمایش قابلیت دگردیسی چیدمان (انیمیشن بین لیست و گرید).
class LayoutMorphShowcasePage extends StatefulWidget {
  const LayoutMorphShowcasePage({Key? key}) : super(key: key);

  @override
  State<LayoutMorphShowcasePage> createState() =>
      _LayoutMorphShowcasePageState();
}

class _LayoutMorphShowcasePageState extends State<LayoutMorphShowcasePage> {
  final QuantumWidgetController _controller = QuantumWidgetController();
  final Random _random = Random();
  QuantumListType _listType = QuantumListType.list;

  @override
  void initState() {
    super.initState();
    _populateList();
  }

  void _populateList() {
    for (int i = 0; i < 15; i++) {
      final id = 'item_$i';
      _controller.add(QuantumEntity(
        id: id,
        widget: SampleWidget(id: id, color: _randomColor()),
      ));
    }
  }

  Color _randomColor() =>
      Colors.primaries[_random.nextInt(Colors.primaries.length)].shade800;

  void _toggleLayout() {
    setState(() {
      _listType = _listType == QuantumListType.list
          ? QuantumListType.grid
          : QuantumListType.list;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // **[RE-ARCHITECTED]** Using AnimatedSwitcher for a smooth transition.
      // **[معماری مجدد]** استفاده از AnimatedSwitcher برای یک تبدیل نرم و زیبا.
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (Widget child, Animation<double> animation) {
          // A combination of fade and scale for a polished look.
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: animation,
              child: child,
            ),
          );
        },
        child: QuantumList<QuantumEntity>(
          // **[CRITICAL FIX]** Using a unique key forces AnimatedSwitcher
          // to treat the list and grid as different widgets, triggering the animation.
          // **[اصلاح حیاتی]** استفاده از یک کلید منحصر به فرد، AnimatedSwitcher را مجبور می‌کند
          // تا لیست و گرید را به عنوان دو ویجت متفاوت شناسایی کرده و انیمیشن را فعال کند.
          key: ValueKey(_listType),
          controller: _controller,
          type: _listType,
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          animationBuilder: (context, index, entity, animation) {
            // The item's own animation still works!
            return QuantumAnimations.scaleIn(context, entity.widget, animation);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleLayout,
        label: Text(_listType == QuantumListType.list
            ? 'Show as Grid'
            : 'Show as List'),
        icon: Icon(_listType == QuantumListType.list
            ? Icons.grid_view
            : Icons.view_list),
      ),
    );
  }
}
