import 'package:flutter/material.dart';

class ControlPanel extends StatelessWidget {
  final String? selectedBorderId;
  final VoidCallback onAddBorder;
  final VoidCallback onRemoveBorder;
  final VoidCallback onMoveBorder;

  const ControlPanel({
    Key? key,
    required this.selectedBorderId,
    required this.onAddBorder,
    required this.onRemoveBorder,
    required this.onMoveBorder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: onAddBorder,
            label: const Text('افزودن بوردر'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever_outlined),
            onPressed: selectedBorderId == null ? null : onRemoveBorder,
            label: const Text('حذف بوردر'),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.open_with),
            onPressed: selectedBorderId == null ? null : onMoveBorder,
            label: const Text('جابجایی بوردر'),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade400),
          ),
        ],
      ),
    );
  }
}
