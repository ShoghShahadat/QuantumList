import 'package:flutter/material.dart';
import 'package:quantum_list/quantum_list.dart';
import 'dart:math';

void main() {
  runApp(const QuantumExampleApp());
}

class QuantumExampleApp extends StatelessWidget {
  const QuantumExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuantumList Example V7.0.1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple.shade300,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const QuantumHomePage(),
    );
  }
}

class SampleItem {
  final int id;
  String title;
  int counter;
  double height;

  SampleItem(
      {required this.id,
      required this.title,
      this.counter = 0,
      required this.height});

  int get numericId => id;
}

class QuantumHomePage extends StatefulWidget {
  const QuantumHomePage({Key? key}) : super(key: key);

  @override
  State<QuantumHomePage> createState() => _QuantumHomePageState();
}

class _QuantumHomePageState extends State<QuantumHomePage> {
  late final FilterableQuantumListController<SampleItem> _controller;
  QuantumListType _listType = QuantumListType.list;
  int _nextItemId = 1001;
  QuantumAnimationType _animationType = QuantumAnimationType.scaleIn;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _controller = FilterableQuantumListController<SampleItem>(
      List.generate(
          1000,
          (i) => SampleItem(
              id: i + 1,
              title: 'آیتم شماره ${i + 1}',
              height: 80.0 + random.nextDouble() * 100.0)),
      onAtEnd: () => _showSnackBar('به انتهای لیست رسیدید!'),
      onAtStart: () => _showSnackBar('به ابتدای لیست رسیدید!'),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuantumList V7.0.1 - رفع خطا'),
        actions: [
          _buildAnimationSelector(),
          IconButton(
            icon: Icon(_listType == QuantumListType.list
                ? Icons.grid_view
                : Icons.view_list),
            onPressed: () {
              setState(() {
                _listType = _listType == QuantumListType.list
                    ? QuantumListType.grid
                    : QuantumListType.list;
              });
            },
          ),
        ],
      ),
      body: _buildList(),
      bottomNavigationBar: _buildControlPanel(),
    );
  }

  Widget _buildAnimationSelector() {
    return PopupMenuButton<QuantumAnimationType>(
      icon: const Icon(Icons.animation),
      onSelected: (QuantumAnimationType result) {
        setState(() {
          _animationType = result;
        });
      },
      itemBuilder: (BuildContext context) =>
          <PopupMenuEntry<QuantumAnimationType>>[
        const PopupMenuItem<QuantumAnimationType>(
          value: QuantumAnimationType.scaleIn,
          child: Text('بزرگ شدن'),
        ),
        const PopupMenuItem<QuantumAnimationType>(
          value: QuantumAnimationType.fadeIn,
          child: Text('محو شدن'),
        ),
        const PopupMenuItem<QuantumAnimationType>(
          value: QuantumAnimationType.slideInFromBottom,
          child: Text('اسلاید از پایین'),
        ),
        const PopupMenuItem<QuantumAnimationType>(
          value: QuantumAnimationType.slideInFromLeft,
          child: Text('اسلاید از چپ'),
        ),
        const PopupMenuItem<QuantumAnimationType>(
          value: QuantumAnimationType.slideInFromRight,
          child: Text('اسلاید از راست'),
        ),
        const PopupMenuItem<QuantumAnimationType>(
          value: QuantumAnimationType.flipInY,
          child: Text('چرخش سه‌بعدی'),
        ),
      ],
    );
  }

  // **[FIXED]** Converted to a method to follow best practices.
  Widget _buildItem(BuildContext context, int index, SampleItem item,
      Animation<double> animation) {
    switch (_animationType) {
      case QuantumAnimationType.fadeIn:
        return QuantumAnimations.fadeIn(
            context, _buildCard(index, item), animation);
      case QuantumAnimationType.slideInFromBottom:
        return QuantumAnimations.slideInFromBottom(
            context, _buildCard(index, item), animation);
      case QuantumAnimationType.slideInFromLeft:
        return QuantumAnimations.slideInFromLeft(
            context, _buildCard(index, item), animation);
      case QuantumAnimationType.slideInFromRight:
        return QuantumAnimations.slideInFromRight(
            context, _buildCard(index, item), animation);
      case QuantumAnimationType.flipInY:
        return QuantumAnimations.flipInY(
            context, _buildCard(index, item), animation);
      case QuantumAnimationType.scaleIn:
      default:
        return QuantumAnimations.scaleIn(
            context, _buildCard(index, item), animation);
    }
  }

  Widget _buildList() {
    if (_listType == QuantumListType.list) {
      return QuantumList<SampleItem>(
        // **[FIXED]** Used string interpolation for the key.
        key: ValueKey('${_animationType}_list'),
        controller: _controller,
        type: QuantumListType.list,
        padding: const EdgeInsets.all(8),
        animationBuilder: _buildItem,
      );
    } else {
      return QuantumList<SampleItem>(
        // **[FIXED]** Used string interpolation for the key.
        key: ValueKey('${_animationType}_grid'),
        controller: _controller,
        type: QuantumListType.grid,
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.0,
        ),
        animationBuilder: _buildItem,
      );
    }
  }

  Widget _buildCard(int index, SampleItem item) {
    return AnimatedBorderCard(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          _controller.updateProperty(index, (itemToUpdate) {
            itemToUpdate.counter++;
          });
        },
        child: Container(
          height: item.height,
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              QuantumAtom(
                controller: _controller,
                index: index,
                builder: (context) => Text('تعداد کلیک: ${item.counter}'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                _controller.add(SampleItem(
                    id: _nextItemId,
                    title: 'آیتم شماره $_nextItemId',
                    height: 100));
                _nextItemId++;
              },
              child: const Text('افزودن')),
          ElevatedButton(
              onPressed: () {
                _controller.sort((a, b) => a.numericId.compareTo(b.numericId));
              },
              child: const Text('مرتب‌سازی')),
          ElevatedButton(
              onPressed: () {
                _controller.scrollToItem(
                  test: (item) => item.numericId == 999,
                );
              },
              child: const Text('برو به آیتم ۹۹۹')),
          ElevatedButton(
              onPressed: () {
                _controller.scrollToItem(
                  test: (item) => item.numericId == 500,
                  animation: QuantumScrollAnimation.bouncy,
                  duration: const Duration(milliseconds: 2000),
                );
              },
              child: const Text('برو به ۵۰۰ (فنری)')),
          ElevatedButton(
              onPressed: () {
                _controller.scrollToItem(
                  test: (item) => item.numericId == 2,
                );
              },
              child: const Text('برو به ۲')),
        ],
      ),
    );
  }
}
