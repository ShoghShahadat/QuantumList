import 'package:example/widgets/animation_control_panel.dart';
import 'package:example/widgets/sample_widget.dart';
import 'package:flutter/material.dart';
import 'package:quantum_list/quantum_list.dart';
import 'dart:math';

/// A page dedicated to showcasing the various entrance animations.
class AnimationShowcasePage extends StatefulWidget {
  const AnimationShowcasePage({Key? key}) : super(key: key);

  @override
  State<AnimationShowcasePage> createState() => _AnimationShowcasePageState();
}

class _AnimationShowcasePageState extends State<AnimationShowcasePage> {
  final QuantumWidgetController _listController = QuantumWidgetController();
  final Random _random = Random();
  int _widgetCounter = 0;

  // State for the control panel
  QuantumAnimationType _selectedAnimation = QuantumAnimationType.scaleIn;
  double _slideOffset = 50.0;
  bool _isReversed = false;

  @override
  void initState() {
    super.initState();
    _addWidgets(5);
  }

  void _addWidgets(int count) {
    for (int i = 0; i < count; i++) {
      _widgetCounter++;
      final id = 'widget_$_widgetCounter';
      final color =
          Colors.primaries[_random.nextInt(Colors.primaries.length)].shade800;
      _listController.add(
          QuantumEntity(id: id, widget: SampleWidget(id: id, color: color)));
    }
  }

  void _removeWidget() {
    if (_listController.length > 0) {
      // Use the new, safe getters on the controller
      final entityToRemove =
          _isReversed ? _listController.first : _listController.last;
      if (entityToRemove != null) {
        _listController.remove(entityToRemove.id);
      }
    }
  }

  void _clearList() {
    // Use the new, correct clear() method
    _listController.clear();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QuantumList<QuantumEntity>(
        controller: _listController,
        padding: const EdgeInsets.all(12),
        reverse: _isReversed,
        // The animationBuilder is the ONLY builder needed.
        animationBuilder: (context, index, entity, animation) {
          // The magic happens here! We apply the selected animation.
          switch (_selectedAnimation) {
            case QuantumAnimationType.fadeIn:
              return QuantumAnimations.fadeIn(
                  context, entity.widget, animation);
            case QuantumAnimationType.scaleIn:
              return QuantumAnimations.scaleIn(
                  context, entity.widget, animation);
            case QuantumAnimationType.slideInFromBottom:
              return QuantumAnimations.slideInFromBottom(
                  context, entity.widget, animation,
                  slideOffset: _slideOffset);
            case QuantumAnimationType.slideInFromLeft:
              return QuantumAnimations.slideInFromLeft(
                  context, entity.widget, animation,
                  slideOffset: _slideOffset);
            case QuantumAnimationType.slideInFromRight:
              return QuantumAnimations.slideInFromRight(
                  context, entity.widget, animation,
                  slideOffset: _slideOffset);
            case QuantumAnimationType.flipInY:
              return QuantumAnimations.flipInY(
                  context, entity.widget, animation);
            case QuantumAnimationType.none:
            default:
              return entity.widget;
          }
        },
      ),
      bottomNavigationBar: AnimationControlPanel(
        selectedAnimation: _selectedAnimation,
        slideOffset: _slideOffset,
        isReversed: _isReversed,
        onAnimationChanged: (type) {
          if (type != null) {
            setState(() => _selectedAnimation = type);
          }
        },
        onSlideOffsetChanged: (value) => setState(() => _slideOffset = value),
        onReversedChanged: (value) => setState(() => _isReversed = value),
        onAdd: () => _addWidgets(1),
        onRemove: _removeWidget,
        onClear: _clearList,
      ),
    );
  }
}
