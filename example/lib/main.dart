import 'package:flutter/material.dart';
import 'package:quantum_list/quantum_list.dart';

void main() {
  runApp(const QuantumExampleApp());
}

class QuantumExampleApp extends StatelessWidget {
  const QuantumExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuantumList Example V2.3',
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

  SampleItem({required this.id, required this.title, this.counter = 0});

  int get numericId => int.tryParse(title.split(' ').last) ?? 0;
}

class QuantumHomePage extends StatefulWidget {
  const QuantumHomePage({Key? key}) : super(key: key);

  @override
  State<QuantumHomePage> createState() => _QuantumHomePageState();
}

class _QuantumHomePageState extends State<QuantumHomePage> {
  late final FilterableQuantumListController<SampleItem> _controller;
  QuantumListType _listType = QuantumListType.list;
  int _nextItemId = 51;
  QuantumAnimationType _animationType =
      QuantumAnimationType.scaleIn; // **[جدید]**

  @override
  void initState() {
    super.initState();
    _controller = FilterableQuantumListController<SampleItem>(
      List.generate(
          50, (i) => SampleItem(id: i + 1, title: 'آیتم شماره ${i + 1}')),
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
        title: const Text('QuantumList V2.3 - زرادخانه انیمیشن'),
        actions: [
          _buildAnimationSelector(), // **[جدید]**
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

  // **[جدید]** ویجت انتخاب‌گر انیمیشن
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

  Widget _buildList() {
    final itemBuilder = (BuildContext context, int index, SampleItem item,
        Animation<double> animation) {
      // **[جدید]** انتخاب انیمیشن بر اساس انتخاب کاربر
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
    };

    if (_listType == QuantumListType.list) {
      return QuantumList<SampleItem>(
        key: ValueKey(
            _animationType.toString() + '_list'), // Key must change to rebuild
        controller: _controller,
        type: QuantumListType.list,
        padding: const EdgeInsets.all(8),
        animationBuilder: itemBuilder,
      );
    } else {
      return QuantumList<SampleItem>(
        key: ValueKey(
            _animationType.toString() + '_grid'), // Key must change to rebuild
        controller: _controller,
        type: QuantumListType.grid,
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.6,
        ),
        animationBuilder: itemBuilder,
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
        child: Padding(
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
                    id: _nextItemId, title: 'آیتم شماره $_nextItemId'));
                _nextItemId++;
              },
              child: const Text('افزودن')),
          ElevatedButton(
              onPressed: () {
                if (_controller.length > 0) _controller.removeAt(0);
              },
              child: const Text('حذف اولی')),
          ElevatedButton(
              onPressed: () {
                _controller.sort((a, b) => b.numericId.compareTo(a.numericId));
              },
              child: const Text('مرتب‌سازی')),
          ElevatedButton(
              onPressed: () {
                _controller.scrollToItem(
                  test: (item) => item.numericId == 10,
                  estimatedItemHeight: 110,
                );
              },
              child: const Text('برو به آیتم ۱۰')),
          ElevatedButton(
              onPressed: () {
                _controller.scrollToItem(
                  test: (item) => item.numericId == 45,
                  estimatedItemHeight: 110,
                  animation: QuantumScrollAnimation.bouncy,
                  duration: const Duration(milliseconds: 1500),
                );
              },
              child: const Text('برو به ۴۵ (فنری)')),
          ElevatedButton(
              onPressed: () {
                _controller.scrollToItem(
                  test: (item) => item.numericId == 2,
                  estimatedItemHeight: 110,
                  animation: QuantumScrollAnimation.bouncy,
                );
              },
              child: const Text('برو به ۲ (آهسته)')),
        ],
      ),
    );
  }
}
