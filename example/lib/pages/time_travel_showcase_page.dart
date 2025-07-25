import 'dart:math';
import 'package:example/widgets/sample_widget.dart';
import 'package:example/widgets/time_travel_debugger.dart';
import 'package:flutter/material.dart';
import 'package:quantum_list/quantum_list.dart';

/// صفحه‌ای برای نمایش قدرت کنترلر سفر در زمان با قابلیت Undo/Redo.
class TimeTravelShowcasePage extends StatefulWidget {
  const TimeTravelShowcasePage({Key? key}) : super(key: key);

  @override
  State<TimeTravelShowcasePage> createState() => _TimeTravelShowcasePageState();
}

class _TimeTravelShowcasePageState extends State<TimeTravelShowcasePage> {
  final TimeTravelQuantumWidgetController _controller =
      TimeTravelQuantumWidgetController();
  final Random _random = Random();
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    // Add some initial items
    _addWidget();
    _addWidget();
    _addWidget();
  }

  void _addWidget() {
    _counter++;
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
      body: Stack(
        children: [
          QuantumList<QuantumEntity>(
            controller: _controller,
            padding: const EdgeInsets.fromLTRB(
                12, 12, 12, 80), // Make space for buttons
            animationBuilder: (context, index, entity, animation) =>
                QuantumAnimations.scaleIn(context, entity.widget, animation),
          ),
          // The magical debugger widget!
          TimeTravelDebugger(controller: _controller),
        ],
      ),
      // **[FIXED]** The main control panel now includes Undo/Redo buttons again.
      // **[اصلاح شد]** پنل کنترل اصلی اکنون دوباره شامل دکمه‌های Undo/Redo است.
      bottomNavigationBar: _buildControlPanel(),
    );
  }

  Widget _buildControlPanel() {
    // We listen to the history stream to rebuild the buttons and enable/disable them.
    return StreamBuilder(
        stream: _controller.historyStream,
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                // --- دکمه‌های اصلی ---
                ElevatedButton.icon(
                    onPressed: _addWidget,
                    icon: const Icon(Icons.add),
                    label: const Text('Add')),
                ElevatedButton.icon(
                    onPressed: _removeWidget,
                    icon: const Icon(Icons.remove),
                    label: const Text('Remove Last')),
                ElevatedButton.icon(
                    onPressed: _updateWidget,
                    icon: const Icon(Icons.update),
                    label: const Text('Update Last')),
                const VerticalDivider(width: 20, thickness: 1),

                // --- دکمه‌های سفر در زمان (بازگشته به جایگاه اصلی) ---
                ElevatedButton.icon(
                  onPressed: _controller.canUndo ? _controller.undo : null,
                  icon: const Icon(Icons.undo),
                  label: const Text('Undo'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700),
                ),
                ElevatedButton.icon(
                  onPressed: _controller.canRedo ? _controller.redo : null,
                  icon: const Icon(Icons.redo),
                  label: const Text('Redo'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600),
                ),
              ],
            ),
          );
        });
  }
}
