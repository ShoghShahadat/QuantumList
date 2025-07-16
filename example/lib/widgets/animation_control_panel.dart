import 'package:flutter/material.dart';
import 'package:quantum_list/quantum_list.dart';

/// A control panel for the Animation Showcase.
class AnimationControlPanel extends StatelessWidget {
  final QuantumAnimationType selectedAnimation;
  final double slideOffset;
  final bool isReversed;
  final ValueChanged<QuantumAnimationType?> onAnimationChanged;
  final ValueChanged<double> onSlideOffsetChanged;
  final ValueChanged<bool> onReversedChanged;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onClear;

  const AnimationControlPanel({
    Key? key,
    required this.selectedAnimation,
    required this.slideOffset,
    required this.isReversed,
    required this.onAnimationChanged,
    required this.onSlideOffsetChanged,
    required this.onReversedChanged,
    required this.onAdd,
    required this.onRemove,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSlideAnimation =
        selectedAnimation == QuantumAnimationType.slideInFromBottom ||
            selectedAnimation == QuantumAnimationType.slideInFromLeft ||
            selectedAnimation == QuantumAnimationType.slideInFromRight;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add'),
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.remove),
                label: const Text('Remove'),
                onPressed: onRemove,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear'),
                onPressed: onClear,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400),
              ),
            ],
          ),
          const Divider(height: 16),
          // Animation Type Dropdown
          ListTile(
            title: const Text('Animation Type'),
            trailing: DropdownButton<QuantumAnimationType>(
              value: selectedAnimation,
              items: QuantumAnimationType.values
                  .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text((type).name.characters.first.toUpperCase() +
                          (type).name.substring(1))))
                  .toList(),
              onChanged: onAnimationChanged,
            ),
          ),
          // Slide Offset Slider (only visible for slide animations)
          if (isSlideAnimation)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(height: 1),
                ListTile(
                  title:
                      Text('Slide Offset: ${slideOffset.toStringAsFixed(0)}px'),
                ),
                Slider(
                  value: slideOffset,
                  min: 10,
                  max: 200,
                  divisions: 19,
                  label: slideOffset.toStringAsFixed(0),
                  onChanged: onSlideOffsetChanged,
                ),
              ],
            ),
          // Reverse Switch
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Reverse List'),
            value: isReversed,
            onChanged: onReversedChanged,
          ),
        ],
      ),
    );
  }
}
