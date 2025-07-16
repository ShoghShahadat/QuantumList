import 'package:example/widgets/border_settings_panel.dart';
import 'package:example/widgets/control_panel.dart';
import 'package:example/widgets/sample_widget.dart';
import 'package:flutter/material.dart';
import 'package:quantum_list/quantum_list.dart';
import 'dart:math';

/// A page dedicated to showcasing the full power of the Quantum Border system.
class BorderShowcasePage extends StatefulWidget {
  const BorderShowcasePage({Key? key}) : super(key: key);
  @override
  State<BorderShowcasePage> createState() => _BorderShowcasePageState();
}

class _BorderShowcasePageState extends State<BorderShowcasePage> {
  final QuantumWidgetController _listController = QuantumWidgetController();
  final QuantumBorderController _borderController = QuantumBorderController();
  final Random _random = Random();
  int _widgetCounter = 0;
  String? _selectedBorderId;

  @override
  void initState() {
    super.initState();
    // Add some initial widgets to the list
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
    // Target a random widget in the list
    final targetId =
        _listController[_random.nextInt(_listController.length)].id;
    _borderController.addBorder(
      borderId: borderId,
      targetEntityId: targetId,
      // Start with a cool animated gradient border
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
      // Find a new target that is different from the current one
      do {
        newTargetId =
            _listController[_random.nextInt(_listController.length)].id;
      } while (newTargetId == currentTargetId);
      _borderController.moveBorder(_selectedBorderId!, newTargetId);
    }
  }

  void _removeWidget() {
    if (_listController.length > 0) {
      final idToRemove = _listController.items.last.id;
      // If the widget being removed has the selected border, remove the border first
      if (_selectedBorderId != null &&
          _borderController.getTargetId(_selectedBorderId!) == idToRemove) {
        _removeSelectedBorder();
      }
      _listController.remove(idToRemove);
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
      // The main list view where widgets are displayed
      body: QuantumList<QuantumEntity>(
        controller: _listController,
        borderController: _borderController, // Connect the border system
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        type: QuantumListType.grid,
        animationBuilder: (context, index, entity, animation) {
          // When a widget is tapped, move the selected border to it
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
      // The bottom control panel for interacting with the showcase
      bottomNavigationBar: ControlPanel(
        selectedBorderId: _selectedBorderId,
        onAddWidget: _addWidget,
        onRemoveWidget: _removeWidget,
        onAddBorder: _addBorder,
        onRemoveBorder: _removeSelectedBorder,
        onMoveBorder: _moveSelectedBorder,
        onShowSettings:
            _selectedBorderId == null ? null : () => _showSettingsPanel(),
      ),
    );
  }

  /// Shows the comprehensive settings panel for the selected border.
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
            // Update the border in real-time as settings are changed
            _borderController.updateBorder(_selectedBorderId!, newBorder);
          },
        );
      },
    );
  }
}
