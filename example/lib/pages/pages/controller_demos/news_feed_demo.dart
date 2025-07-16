import 'dart:math';
import 'package:example/widgets/news_feed/ad_card.dart';
import 'package:example/widgets/news_feed/breaking_news_card.dart';
import 'package:example/widgets/news_feed/live_ticker_widget.dart';
import 'package:example/widgets/news_feed/news_control_panel.dart';
import 'package:example/widgets/news_feed/standard_news_card.dart';
import 'package:flutter/material.dart';
import 'package:quantum_list/quantum_list.dart';

/// A masterpiece demo simulating a dynamic, responsive news feed
/// to showcase the full power of `QuantumWidgetController`.
class NewsFeedDemo extends StatefulWidget {
  const NewsFeedDemo({Key? key}) : super(key: key);

  @override
  State<NewsFeedDemo> createState() => _NewsFeedDemoState();
}

class _NewsFeedDemoState extends State<NewsFeedDemo> {
  final QuantumWidgetController _controller = QuantumWidgetController();
  final Random _random = Random();
  int _counter = 0;
  final String _liveTickerId = 'live_ticker_1';

  // Sample data
  final List<String> _headlines = [
    'Quantum Leap in Flutter Performance',
    'New Horizons: AI Discovers a New Galaxy',
    'The Silent Revolution of Atomic State Management',
    'Market Hits Record High After Tech Rally',
    'Global Summit on Climate Change Begins',
    'The Future of UI: Is it Quantum?'
  ];
  final List<String> _summaries = [
    'Developers are stunned by the performance gains of the new QuantumList package...',
    'An advanced AI algorithm has identified a previously unknown galaxy in the Andromeda cluster...',
    'A new paradigm in state management is quietly taking over the app development world...',
    'Tech stocks surged today, pushing the market to unprecedented new heights...',
    'Leaders from around the world gather to discuss urgent actions against climate change...',
    'Experts debate whether the new widget-driven architecture is the final frontier of UI design...'
  ];

  @override
  void initState() {
    super.initState();
    _addInitialFeedItems();
  }

  void _addInitialFeedItems() {
    // 1. Add a live ticker
    _controller.add(QuantumEntity(
        id: _liveTickerId,
        widget: LiveTickerWidget(id: _liveTickerId, stockPrice: 123.45)));

    // 2. Add a breaking news
    _addBreakingNews();

    // 3. Add a standard news
    _addStandardNews();

    // 4. Add an Ad
    _addAd();
  }

  String _getUniqueId() {
    _counter++;
    return 'item_$_counter';
  }

  void _addBreakingNews() {
    final id = _getUniqueId();
    _controller.add(QuantumEntity(
        id: id,
        widget: BreakingNewsCard(
            headline: _headlines[_random.nextInt(_headlines.length)])));
  }

  void _addStandardNews() {
    final id = _getUniqueId();
    final index = _random.nextInt(_headlines.length);
    _controller.add(QuantumEntity(
        id: id,
        widget: StandardNewsCard(
            headline: _headlines[index], summary: _summaries[index])));
  }

  void _addAd() {
    final id = _getUniqueId();
    _controller.add(QuantumEntity(id: id, widget: const AdCard()));
  }

  void _removeLast() {
    if (_controller.length > 1) {
      // Keep the ticker
      _controller.remove(_controller.last!.id);
    }
  }

  void _updateTicker() {
    // This demonstrates the ATOMIC UPDATE. Only the LiveTickerWidget will rebuild.
    final newPrice = 100 + _random.nextDouble() * 100;
    _controller.update(_liveTickerId,
        LiveTickerWidget(id: _liveTickerId, stockPrice: newPrice));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Make the layout responsive
        final crossAxisCount = (constraints.maxWidth > 800) ? 2 : 1;

        return Column(
          children: [
            Expanded(
              child: QuantumList<QuantumEntity>(
                type: crossAxisCount > 1
                    ? QuantumListType.grid
                    : QuantumListType.list,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: (constraints.maxWidth / crossAxisCount) /
                      250, // Adjust aspect ratio
                ),
                controller: _controller,
                padding: const EdgeInsets.all(12),
                animationBuilder: (context, index, entity, animation) =>
                    QuantumAnimations.slideInFromBottom(
                        context, entity.widget, animation,
                        slideOffset: 50),
              ),
            ),
            NewsControlPanel(
              onAddBreaking: _addBreakingNews,
              onAddStandard: _addStandardNews,
              onAddAd: _addAd,
              onRemoveLast: _removeLast,
              onUpdateTicker: _updateTicker,
            ),
          ],
        );
      },
    );
  }
}
