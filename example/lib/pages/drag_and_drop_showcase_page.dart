import 'dart:math';
import 'package:example/widgets/sample_widget.dart';
import 'package:flutter/material.dart';
import 'package:quantum_list/quantum_list.dart';

/// صفحه‌ای برای نمایش قابلیت مرتب‌سازی با کشیدن و رها کردن.
/// A page to showcase the drag & drop reordering functionality.
class DragAndDropShowcasePage extends StatefulWidget {
  const DragAndDropShowcasePage({Key? key}) : super(key: key);

  @override
  State<DragAndDropShowcasePage> createState() =>
      _DragAndDropShowcasePageState();
}

class _DragAndDropShowcasePageState extends State<DragAndDropShowcasePage> {
  final QuantumWidgetController _controller = QuantumWidgetController();
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _populateList();
  }

  void _populateList() {
    for (int i = 0; i < 8; i++) {
      final id = 'Item $i';
      _controller.add(QuantumEntity(
        id: id,
        widget: SizedBox(
          height: 70,
          child: SampleWidget(id: id, color: _randomColor()),
        ),
      ));
    }
  }

  Color _randomColor() =>
      Colors.primaries[_random.nextInt(Colors.primaries.length)].shade800;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drag & Drop Reordering'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: QuantumList<QuantumEntity>(
        controller: _controller,
        padding: const EdgeInsets.all(12),
        // Enable the new reorderable feature!
        isReorderable: true,
        animationBuilder: (context, index, entity, animation) {
          return QuantumAnimations.scaleIn(context, entity.widget, animation);
        },
      ),
    );
  }
}
