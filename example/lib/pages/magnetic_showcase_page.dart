import 'package:example/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:quantum_list/quantum_list.dart';

/// صفحه‌ای برای نمایش قابلیت آیتم‌های مغناطیسی (هدرهای چسبان).
class MagneticShowcasePage extends StatefulWidget {
  const MagneticShowcasePage({Key? key}) : super(key: key);

  @override
  State<MagneticShowcasePage> createState() => _MagneticShowcasePageState();
}

class _MagneticShowcasePageState extends State<MagneticShowcasePage> {
  final QuantumWidgetController _controller = QuantumWidgetController();
  final ScrollController _scrollController = ScrollController();

  // A map to store the layout position of each magnetic header.
  final Map<int, double> _magneticHeaderPositions = {};
  QuantumEntity? _stickyHeaderEntity;
  double _stickyHeaderVerticalOffset = 0.0;
  final double _topPadding = 10.0; // Define padding as a constant

  @override
  void initState() {
    super.initState();
    _populateList();
    _scrollController.addListener(_scrollListener);
    // Calculate initial positions after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculatePositions());
  }

  void _populateList() {
    _controller.add(QuantumEntity(
        id: 'header_a',
        widget: const SectionHeader(title: 'Section A'),
        isMagnetic: true));
    for (int i = 1; i <= 5; i++) {
      _controller.add(QuantumEntity(
          id: 'item_a$i', widget: ListTile(title: Text('Item A$i'))));
    }

    _controller.add(QuantumEntity(
        id: 'header_b',
        widget: const SectionHeader(title: 'Section B'),
        isMagnetic: true));
    for (int i = 1; i <= 8; i++) {
      _controller.add(QuantumEntity(
          id: 'item_b$i', widget: ListTile(title: Text('Item B$i'))));
    }

    _controller.add(QuantumEntity(
        id: 'header_c',
        widget: const SectionHeader(title: 'Section C'),
        isMagnetic: true));
    for (int i = 1; i <= 10; i++) {
      _controller.add(QuantumEntity(
          id: 'item_c$i', widget: ListTile(title: Text('Item C$i'))));
    }
  }

  /// **[FIXED]** Calculates and stores the y-offset of each magnetic header,
  /// now correctly accounting for the list's top padding.
  void _calculatePositions() {
    if (!mounted) return;
    _magneticHeaderPositions.clear();
    double currentOffset = _topPadding; // Start with the list's top padding.

    for (int i = 0; i < _controller.length; i++) {
      final entity = _controller[i];
      if (entity.isMagnetic) {
        _magneticHeaderPositions[i] = currentOffset;
      }
      // Use cached height for accuracy. Default to 50 for headers and 48 for ListTiles.
      currentOffset +=
          _controller.getCachedHeight(i) ?? (entity.isMagnetic ? 50.0 : 48.0);
    }
    // Trigger a manual scroll listen to update the UI on first load.
    _scrollListener();
  }

  /// The robust scroll listener logic.
  void _scrollListener() {
    if (!mounted || _magneticHeaderPositions.isEmpty) return;

    final scrollOffset = _scrollController.offset;
    QuantumEntity? newStickyHeader;
    double newVerticalOffset = 0.0;

    // Find the last magnetic header that is above the current scroll position.
    final potentialHeaders = _magneticHeaderPositions.entries.where((entry) {
      // We subtract the padding because the scroll offset starts from 0 inside the scrollable area.
      return entry.value - _topPadding <= scrollOffset;
    });

    if (potentialHeaders.isNotEmpty) {
      final currentHeaderEntry = potentialHeaders.last;
      newStickyHeader = _controller[currentHeaderEntry.key];

      // Now, find the *next* magnetic header to calculate the push-off effect.
      final nextHeaderIndex = _magneticHeaderPositions.keys
          .firstWhere((k) => k > currentHeaderEntry.key, orElse: () => -1);

      if (nextHeaderIndex != -1) {
        final nextHeaderPosition = _magneticHeaderPositions[nextHeaderIndex]!;
        final stickyHeaderHeight =
            _controller.getCachedHeight(currentHeaderEntry.key) ?? 50.0;

        // If the next header is about to push the current one, adjust the offset.
        if (scrollOffset + stickyHeaderHeight >
            nextHeaderPosition - _topPadding) {
          newVerticalOffset = (nextHeaderPosition - _topPadding) -
              (scrollOffset + stickyHeaderHeight);
        }
      }
    }

    // Update the state only if something has changed.
    if (newStickyHeader?.id != _stickyHeaderEntity?.id ||
        newVerticalOffset != _stickyHeaderVerticalOffset) {
      setState(() {
        _stickyHeaderEntity = newStickyHeader;
        _stickyHeaderVerticalOffset = newVerticalOffset;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The main list, now connected to our scroll controller.
        QuantumList<QuantumEntity>(
          controller: _controller,
          scrollController: _scrollController,
          padding: EdgeInsets.only(top: _topPadding),
          animationBuilder: (context, index, entity, animation) {
            // Use Opacity to hide the original header while preserving its space.
            final isStuck =
                entity.isMagnetic && entity.id == _stickyHeaderEntity?.id;
            return Opacity(
              opacity: isStuck ? 0.0 : 1.0,
              child:
                  QuantumAnimations.fadeIn(context, entity.widget, animation),
            );
          },
        ),
        // The floating sticky header widget.
        if (_stickyHeaderEntity != null)
          Positioned(
            top: _stickyHeaderVerticalOffset,
            left: 0,
            right: 0,
            child: _stickyHeaderEntity!.widget,
          ),
      ],
    );
  }
}
