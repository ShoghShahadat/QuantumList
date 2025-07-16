import 'package:example/pages/animation_showcase_page.dart';
import 'package:example/pages/border_showcase_page.dart';
import 'package:example/pages/controller_showcase_page.dart';
import 'package:example/pages/performance_showcase_page.dart';
import 'package:example/pages/time_travel_showcase_page.dart';
// **[NEW]** Importing the new magnetic items showcase page.
// ایمپورت کردن صفحه جدید نمایش آیتم‌های مغناطیسی.
import 'package:example/pages/magnetic_showcase_page.dart';
import 'package:flutter/material.dart';

/// The main application widget that holds the tabbed navigation.
class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      // **[MODIFIED]** Increased tab count to 6.
      // تعداد تب‌ها به ۶ افزایش یافت.
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('QuantumList Showcase'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Magnetic Items', icon: Icon(Icons.push_pin_outlined)),
              Tab(text: 'Time Travel', icon: Icon(Icons.history)),
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
          physics: NeverScrollableScrollPhysics(), // To prevent swipe conflicts
          children: [
            // **[NEW]** The new Magnetic Items showcase page.
            // صفحه جدید نمایش آیتم‌های مغناطیسی.
            MagneticShowcasePage(),
            TimeTravelShowcasePage(),
            BorderShowcasePage(),
            AnimationShowcasePage(),
            ControllerShowcasePage(),
            PerformanceShowcasePage(),
          ],
        ),
      ),
    );
  }
}
