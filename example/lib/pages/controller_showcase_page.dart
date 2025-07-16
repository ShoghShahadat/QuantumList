import 'package:example/pages/controller_demos/filterable_controller_demo.dart';
import 'package:example/pages/controller_demos/widget_controller_demo.dart';
import 'package:flutter/material.dart';

/// A page that contains a TabBar to switch between demos for the two
/// main controller types.
class ControllerShowcasePage extends StatelessWidget {
  const ControllerShowcasePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              const Tab(text: 'Widget Controller'),
              const Tab(text: 'Filterable Controller'),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                WidgetControllerDemo(),
                FilterableControllerDemo(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
