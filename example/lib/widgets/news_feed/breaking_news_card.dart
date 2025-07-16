import 'package:flutter/material.dart';

/// A prominent card for breaking news.
class BreakingNewsCard extends StatelessWidget {
  final String headline;
  const BreakingNewsCard({Key? key, required this.headline}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade900.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.red.shade400, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BREAKING NEWS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontSize: 14,
              ),
            ),
            const Divider(color: Colors.red, thickness: 1, height: 24),
            Text(
              headline,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
