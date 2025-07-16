import 'package:example/pages/animation_showcase_page.dart';
import 'package:example/pages/border_showcase_page.dart';
import 'package:flutter/material.dart';

/// The main application widget that holds the tabbed navigation.
class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // The number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('QuantumList Showcase'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(
                  text: 'Quantum Borders',
                  icon: Icon(Icons.view_quilt_outlined)),
              Tab(text: 'Animations', icon: Icon(Icons.animation)),
              Tab(text: 'Controllers', icon: Icon(Icons.gamepad_outlined)),
              Tab(text: 'Performance', icon: Icon(Icons.speed_outlined)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Tab 1: The fully functional Border Showcase
            BorderShowcasePage(),

            // Tab 2: The new, interactive Animation Showcase
            AnimationShowcasePage(),

            // Placeholder for other showcases
            Center(child: Text('Controller Showcase Coming Soon!')),
            Center(child: Text('Performance Test Coming Soon!')),
          ],
        ),
      ),
    );
  }
}
