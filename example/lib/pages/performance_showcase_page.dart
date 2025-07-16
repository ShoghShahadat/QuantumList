import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quantum_list/quantum_list.dart';

/// A page to stress-test the performance of QuantumList with a large number of items.
class PerformanceShowcasePage extends StatefulWidget {
  const PerformanceShowcasePage({Key? key}) : super(key: key);

  @override
  State<PerformanceShowcasePage> createState() =>
      _PerformanceShowcasePageState();
}

class _PerformanceShowcasePageState extends State<PerformanceShowcasePage> {
  final QuantumWidgetController _controller = QuantumWidgetController();
  final TextEditingController _addCountController =
      TextEditingController(text: '1000');
  final TextEditingController _scrollToIndexController =
      TextEditingController();
  int _itemCount = 0;

  void _addItems() {
    final count = int.tryParse(_addCountController.text) ?? 0;
    if (count <= 0) return;

    final newItems = List.generate(count, (i) {
      final id = 'item_${_itemCount + i}';
      return QuantumEntity(
        id: id,
        widget: Builder(
          builder: (context) {
            // Using a simple ListTile for performance.
            // Using a colored container to make rows more visible.
            return Container(
              color: (_itemCount + i) % 2 == 0
                  ? Colors.black.withOpacity(0.1)
                  : Colors.transparent,
              child: ListTile(
                dense: true,
                title: Text('Item #${_itemCount + i}'),
                leading: Text('${_itemCount + i}'),
              ),
            );
          },
        ),
      );
    });

    // For large additions, it's more performant to add them in a batch
    // if a batch-add method were available. For now, we add one by one.
    for (var item in newItems) {
      _controller.add(item);
    }

    setState(() {
      _itemCount += count;
    });
  }

  void _clearList() {
    _controller.clear();
    setState(() {
      _itemCount = 0;
    });
  }

  void _scrollToIndex() {
    final index = int.tryParse(_scrollToIndexController.text);
    if (index != null) {
      _controller.scrollToIndex(index);
    }
  }

  @override
  void dispose() {
    _addCountController.dispose();
    _scrollToIndexController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildControlPanel(),
        const Divider(height: 1),
        Expanded(
          child: QuantumList<QuantumEntity>(
            controller: _controller,
            // Use a simple fade-in for adding/removing items.
            animationBuilder: (context, index, entity, animation) =>
                FadeTransition(opacity: animation, child: entity.widget),
          ),
        ),
      ],
    );
  }

  Widget _buildControlPanel() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _addCountController,
                  decoration: const InputDecoration(labelText: 'Items to Add'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _addItems, child: const Text('Add')),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _clearList,
                child: const Text('Clear'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _scrollToIndexController,
                  decoration:
                      const InputDecoration(labelText: 'Scroll to Index'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _scrollToIndex,
                child: const Text('Quantum Jump!'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade600),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Current Item Count: $_itemCount',
                style: Theme.of(context).textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}
