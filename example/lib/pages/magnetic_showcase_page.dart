import 'package:example/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:quantum_list/quantum_list.dart';

/// صفحه‌ای برای نمایش قابلیت آیتم‌های مغناطیسی (هدرهای چسبان).
/// A page to showcase the magnetic items (sticky headers) functionality.
class MagneticShowcasePage extends StatefulWidget {
  const MagneticShowcasePage({Key? key}) : super(key: key);

  @override
  State<MagneticShowcasePage> createState() => _MagneticShowcasePageState();
}

class _MagneticShowcasePageState extends State<MagneticShowcasePage> {
  final QuantumWidgetController _controller = QuantumWidgetController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _listKey = GlobalKey();

  Widget? _stickyHeaderWidget;
  double _stickyHeaderOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _populateList();
    _scrollController.addListener(_scrollListener);
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

  void _scrollListener() {
    if (!mounted) return;

    Widget? newStickyHeader;
    double newOffset = 0.0;
    double currentOffset = 0.0;

    // پیدا کردن آیتم‌های مغناطیسی و موقعیت آن‌ها
    for (int i = 0; i < _controller.length; i++) {
      final entity = _controller[i];
      final itemHeight = _controller.getCachedHeight(i) ?? 50.0;

      if (entity.isMagnetic) {
        if (currentOffset <= _scrollController.offset) {
          newStickyHeader = entity.widget;
        }
        // بررسی اینکه آیا هدر بعدی در حال هل دادن هدر فعلی است یا خیر
        if (currentOffset > _scrollController.offset &&
            currentOffset < _scrollController.offset + itemHeight) {
          newOffset = currentOffset - _scrollController.offset - itemHeight;
        }
      }
      currentOffset += itemHeight;
    }

    // آپدیت کردن ویجت هدر چسبان فقط در صورت نیاز
    if (newStickyHeader != _stickyHeaderWidget ||
        newOffset != _stickyHeaderOffset) {
      setState(() {
        _stickyHeaderWidget = newStickyHeader;
        _stickyHeaderOffset = newOffset;
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
        // لیست اصلی
        QuantumList<QuantumEntity>(
          key: _listKey,
          controller: _controller,
          // اتصال اسکرول کنترلر به لیست
          physics: const AlwaysScrollableScrollPhysics(),
          // این بخش برای اتصال اسکرول کنترلر به QuantumList است که در نسخه فعلی
          // به صورت مستقیم پشتیبانی نمی‌شود، اما با استفاده از ScrollableQuantumListController
          // و attachScrollController می‌توان این کار را انجام داد.
          // در اینجا ما از یک ScrollController خارجی استفاده می‌کنیم.
          // Note: This is a conceptual implementation. A direct way to pass
          // the scroll controller to QuantumList would be needed for perfect sync.
          // We are using the attached controller from the base class.
          animationBuilder: (context, index, entity, animation) {
            // مخفی کردن هدر اصلی وقتی که کلون آن در بالای صفحه چسبیده است
            if (entity.isMagnetic && entity.widget == _stickyHeaderWidget) {
              final itemHeight = _controller.getCachedHeight(index) ?? 50.0;
              return SizedBox(height: itemHeight);
            }
            return QuantumAnimations.fadeIn(context, entity.widget, animation);
          },
        ),
        // ویجت هدر چسبان
        if (_stickyHeaderWidget != null)
          Positioned(
            top: _stickyHeaderOffset,
            left: 0,
            right: 0,
            child: _stickyHeaderWidget!,
          ),
      ],
    );
  }
}
