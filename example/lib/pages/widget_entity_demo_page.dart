import 'package:example/widgets/border_settings_panel.dart';
import 'package:example/widgets/control_panel.dart';
import 'package:example/widgets/sample_widget.dart';
import 'package:flutter/material.dart';
import 'package:quantum_list/quantum_list.dart';
import 'dart:math';

class WidgetEntityDemoPage extends StatefulWidget {
  const WidgetEntityDemoPage({Key? key}) : super(key: key);
  @override
  State<WidgetEntityDemoPage> createState() => _WidgetEntityDemoPageState();
}

class _WidgetEntityDemoPageState extends State<WidgetEntityDemoPage> {
  final QuantumWidgetController _listController = QuantumWidgetController();
  final QuantumBorderController _borderController = QuantumBorderController();
  final Random _random = Random();
  int _widgetCounter = 0;
  String? _selectedBorderId;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 5; i++) {
      _addWidget();
    }
  }

  void _addWidget() {
    _widgetCounter++;
    final id = 'widget_$_widgetCounter';
    final color =
        Colors.primaries[_random.nextInt(Colors.primaries.length)].shade800;
    _listController
        .add(QuantumEntity(id: id, widget: SampleWidget(id: id, color: color)));
  }

  void _addBorder() {
    if (_listController.length == 0) return;
    final borderId = 'border_${_random.nextInt(9999)}';
    final targetId =
        _listController[_random.nextInt(_listController.length)].id;
    _borderController.addBorder(
      borderId: borderId,
      targetEntityId: targetId,
      border: QuantumBorder.animatedGradient(),
    );
    setState(() {
      _selectedBorderId = borderId;
    });
  }

  void _removeSelectedBorder() {
    if (_selectedBorderId != null) {
      _borderController.removeBorder(_selectedBorderId!);
      setState(() {
        _selectedBorderId = null;
      });
    }
  }

  void _moveSelectedBorder() {
    if (_selectedBorderId != null && _listController.length > 1) {
      final currentTargetId = _borderController.getTargetId(_selectedBorderId!);
      String newTargetId;
      do {
        newTargetId =
            _listController[_random.nextInt(_listController.length)].id;
      } while (newTargetId == currentTargetId);
      _borderController.moveBorder(_selectedBorderId!, newTargetId);
    }
  }

  @override
  void dispose() {
    _listController.dispose();
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('انقلاب بوردرهای کوانتومی'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'تنظیمات بوردر',
            onPressed:
                _selectedBorderId == null ? null : () => _showSettingsPanel(),
          ),
        ],
      ),
      body: QuantumList<QuantumEntity>(
        controller: _listController,
        borderController: _borderController,
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        type: QuantumListType.grid,
        animationBuilder: (context, index, entity, animation) {
          // با کلیک روی هر ویجت، بوردر انتخاب شده به آن منتقل می‌شود
          return GestureDetector(
            onTap: () {
              if (_selectedBorderId != null) {
                _borderController.moveBorder(_selectedBorderId!, entity.id);
              }
            },
            child: QuantumAnimations.scaleIn(context, entity.widget, animation),
          );
        },
      ),
      bottomNavigationBar: ControlPanel(
        selectedBorderId: _selectedBorderId,
        onAddBorder: _addBorder,
        onRemoveBorder: _removeSelectedBorder,
        onMoveBorder: _moveSelectedBorder,
      ),
    );
  }

  void _showSettingsPanel() {
    final currentBorder =
        _borderController.getBorderDefinition(_selectedBorderId!);
    if (currentBorder == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BorderSettingsPanel(
          initialBorder: currentBorder,
          onBorderChanged: (newBorder) {
            _borderController.updateBorder(_selectedBorderId!, newBorder);
          },
        );
      },
    );
  }
}
