import 'package:flutter/material.dart';

/// The main control panel for the Border Showcase.
class ControlPanel extends StatelessWidget {
  final String? selectedBorderId;
  final VoidCallback onAddWidget;
  final VoidCallback onRemoveWidget;
  final VoidCallback onAddBorder;
  final VoidCallback onRemoveBorder;
  final VoidCallback onMoveBorder;
  final VoidCallback? onShowSettings;

  const ControlPanel({
    Key? key,
    required this.selectedBorderId,
    required this.onAddWidget,
    required this.onRemoveWidget,
    required this.onAddBorder,
    required this.onRemoveBorder,
    required this.onMoveBorder,
    required this.onShowSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          // Widget Controls
          ElevatedButton.icon(
            icon: const Icon(Icons.add_to_photos_outlined),
            onPressed: onAddWidget,
            label: const Text('Add Widget'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: onRemoveWidget,
            label: const Text('Remove Widget'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700),
          ),

          const VerticalDivider(width: 20, thickness: 1),

          // Border Controls
          ElevatedButton.icon(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: onAddBorder,
            label: const Text('Add Border'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever_outlined),
            onPressed: selectedBorderId == null ? null : onRemoveBorder,
            label: const Text('Remove Border'),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.open_with),
            onPressed: selectedBorderId == null ? null : onMoveBorder,
            label: const Text('Move Border'),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade400),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.settings_outlined),
            onPressed: onShowSettings,
            label: const Text('Settings'),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
