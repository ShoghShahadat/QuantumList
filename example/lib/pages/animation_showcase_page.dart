import 'package:example/widgets/animation_control_panel.dart';
import 'package:example/widgets/sample_widget.dart';
import 'package:flutter/material.dart';
import 'package:quantum_list/quantum_list.dart';
import 'dart:math';

/// A page dedicated to showcasing the various entrance animations and scroll physics.
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
  PhysicsType _selectedPhysics = PhysicsType.Bouncing;
  ChoreographyType _selectedChoreography = ChoreographyType.simultaneous;
  // **[NEW]** State for the scroll transformation switch.
  bool _isScrollTransformEnabled = false;
  double _slideOffset = 50.0;
  bool _isReversed = false;

  @override
  void initState() {
    super.initState();
    _addWidgets(15); // Add more widgets to make scrolling more visible
  }

  void _addWidgets(int count) {
    _listController.clear();
    _widgetCounter = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < count; i++) {
        _widgetCounter++;
        final id = 'widget_$_widgetCounter';
        final color =
            Colors.primaries[_random.nextInt(Colors.primaries.length)].shade800;
        _listController.add(
            QuantumEntity(id: id, widget: SampleWidget(id: id, color: color)));
      }
    });
  }

  void _removeWidget() {
    if (_listController.length > 0) {
      final entityToRemove =
          _isReversed ? _listController.first : _listController.last;
      if (entityToRemove != null) {
        _listController.remove(entityToRemove.id);
      }
    }
  }

  void _clearList() {
    _listController.clear();
  }

  ScrollPhysics _getScrollPhysics() {
    switch (_selectedPhysics) {
      case PhysicsType.Bouncing:
        return const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics());
      case PhysicsType.Clamping:
        return const ClampingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics());
      case PhysicsType.NeverScrollable:
        return const NeverScrollableScrollPhysics();
    }
  }

  QuantumChoreography _getChoreography() {
    switch (_selectedChoreography) {
      case ChoreographyType.staggered:
        return QuantumChoreography.staggered();
      case ChoreographyType.wave:
        return QuantumChoreography.wave();
      case ChoreographyType.simultaneous:
      default:
        return const QuantumChoreography();
    }
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
        padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 12.0),
        reverse: _isReversed,
        physics: _getScrollPhysics(),
        choreography: _getChoreography(),
        // **[NEW]** Conditionally pass the transformation object.
        scrollTransformation: _isScrollTransformEnabled
            ? const QuantumScrollTransformation()
            : null,
        animationDuration: const Duration(milliseconds: 1200),
        animationBuilder: (context, index, entity, animation) {
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
        selectedPhysics: _selectedPhysics,
        selectedChoreography: _selectedChoreography,
        // **[NEW]** Pass the state and callback for the new switch.
        isScrollTransformEnabled: _isScrollTransformEnabled,
        onScrollTransformChanged: (value) =>
            setState(() => _isScrollTransformEnabled = value),
        onChoreographyChanged: (type) {
          if (type != null) {
            setState(() {
              _selectedChoreography = type;
              _addWidgets(15);
            });
          }
        },
        onPhysicsChanged: (type) {
          if (type != null) {
            setState(() => _selectedPhysics = type);
          }
        },
        onAnimationChanged: (type) {
          if (type != null) {
            setState(() => _selectedAnimation = type);
          }
        },
        onSlideOffsetChanged: (value) => setState(() => _slideOffset = value),
        onReversedChanged: (value) => setState(() => _isReversed = value),
        onAdd: () => _addWidgets(15),
        onRemove: _removeWidget,
        onClear: _clearList,
      ),
    );
  }
}
