import 'dart:math';
import 'package:example/widgets/sample_widget.dart';
import 'package:flutter/material.dart';
import 'package:quantum_list/quantum_list.dart';

/// Demonstrates the usage of `QuantumWidgetController`.
class WidgetControllerDemo extends StatefulWidget {
  const WidgetControllerDemo({Key? key}) : super(key: key);

  @override
  State<WidgetControllerDemo> createState() => _WidgetControllerDemoState();
}

class _WidgetControllerDemoState extends State<WidgetControllerDemo> {
  final QuantumWidgetController _controller = QuantumWidgetController();
  final Random _random = Random();
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _addWidget();
    _addWidget();
  }

  void _addWidget() {
    setState(() => _counter++);
    final id = 'widget_$_counter';
    _controller.add(QuantumEntity(
      id: id,
      widget: SampleWidget(id: id, color: _randomColor()),
    ));
  }

  void _removeWidget() {
    if (_controller.length > 0) {
      _controller.remove(_controller.last!.id);
    }
  }

  void _updateWidget() {
    if (_controller.length > 0) {
      final targetId = _controller.last!.id;
      _controller.update(
        targetId,
        SampleWidget(id: targetId, color: _randomColor()),
      );
    }
  }

  void _scrollToFirst() {
    if (_controller.length > 0) {
      _controller.scrollTo(_controller.first!.id);
    }
  }

  Color _randomColor() =>
      Colors.primaries[_random.nextInt(Colors.primaries.length)].shade800;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: QuantumList<QuantumEntity>(
            controller: _controller,
            padding: const EdgeInsets.all(12),
            animationBuilder: (context, index, entity, animation) =>
                QuantumAnimations.scaleIn(context, entity.widget, animation),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                  onPressed: _addWidget,
                  icon: const Icon(Icons.add),
                  label: const Text('Add')),
              ElevatedButton.icon(
                  onPressed: _removeWidget,
                  icon: const Icon(Icons.remove),
                  label: const Text('Remove')),
              ElevatedButton.icon(
                  onPressed: _updateWidget,
                  icon: const Icon(Icons.update),
                  label: const Text('Update Last')),
              ElevatedButton.icon(
                  onPressed: _scrollToFirst,
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text('Scroll First')),
            ],
          ),
        )
      ],
    );
  }
}
