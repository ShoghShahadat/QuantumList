import 'package:flutter/material.dart';

/// Control panel for the News Feed demo.
class NewsControlPanel extends StatelessWidget {
  final VoidCallback onAddBreaking;
  final VoidCallback onAddStandard;
  final VoidCallback onAddAd;
  final VoidCallback onRemoveLast;
  final VoidCallback onUpdateTicker;

  const NewsControlPanel({
    Key? key,
    required this.onAddBreaking,
    required this.onAddStandard,
    required this.onAddAd,
    required this.onRemoveLast,
    required this.onUpdateTicker,
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
          ElevatedButton(
              onPressed: onAddBreaking, child: const Text('Add Breaking')),
          ElevatedButton(
              onPressed: onAddStandard, child: const Text('Add Standard')),
          ElevatedButton(onPressed: onAddAd, child: const Text('Add Ad')),
          ElevatedButton(
            onPressed: onUpdateTicker,
            child: const Text('Update Ticker'),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade400),
          ),
          ElevatedButton(
            onPressed: onRemoveLast,
            child: const Text('Remove Last'),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
          ),
        ],
      ),
    );
  }
}
