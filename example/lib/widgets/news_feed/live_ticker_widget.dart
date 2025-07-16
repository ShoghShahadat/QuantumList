import 'package:flutter/material.dart';

/// A widget that simulates a live stock ticker to demonstrate atomic updates.
class LiveTickerWidget extends StatelessWidget {
  final String id;
  final double stockPrice;

  const LiveTickerWidget({
    Key? key,
    required this.id,
    required this.stockPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This print statement will ONLY fire when this specific widget rebuilds.
    // It proves that the rest of the list is not being rebuilt during an update.
    debugPrint("--- Rebuilding Live Ticker Widget ---");

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.trending_up, color: Colors.greenAccent),
          const SizedBox(width: 12),
          const Text(
            'QNTM:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Text(
            '\$${stockPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, color: Colors.greenAccent),
          ),
        ],
      ),
    );
  }
}
