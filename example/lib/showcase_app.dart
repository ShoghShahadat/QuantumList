import 'package:example/pages/animation_showcase_page.dart';
import 'package:example/pages/border_showcase_page.dart';
import 'package:example/pages/controller_showcase_page.dart';
import 'package:example/pages/drag_and_drop_showcase_page.dart';
import 'package:example/pages/layout_morph_showcase_page.dart';
import 'package:example/pages/magnetic_showcase_page.dart';
import 'package:example/pages/pagination_showcase_page.dart';
import 'package:example/pages/performance_showcase_page.dart';
import 'package:example/pages/swipe_actions_showcase_page.dart';
import 'package:example/pages/time_travel_showcase_page.dart';
import 'package:flutter/material.dart';

/// The main application widget that holds the tabbed navigation.
class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      // **[MODIFIED]** Increased tab count to 10.
      // تعداد تب‌ها به ۱۰ افزایش یافت.
      length: 10,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('QuantumList Showcase'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              // **[NEW]** The new tab for the Smart Pagination showcase.
              // تب جدید برای نمایش صفحه‌بندی هوشمند.
              Tab(text: 'Pagination', icon: Icon(Icons.pages_outlined)),
              Tab(text: 'Swipe Actions', icon: Icon(Icons.swipe)),
              Tab(text: 'Drag & Drop', icon: Icon(Icons.reorder)),
              Tab(
                  text: 'Layout Morphing',
                  icon: Icon(Icons.transform_outlined)),
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
            // **[NEW]** The new Smart Pagination showcase page.
            // صفحه جدید نمایش صفحه‌بندی هوشمند.
            PaginationShowcasePage(),
            SwipeActionsShowcasePage(),
            DragAndDropShowcasePage(),
            LayoutMorphShowcasePage(),
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
