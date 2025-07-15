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
      title: 'QuantumList Example',
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
  int _nextItemId = 21;

  @override
  void initState() {
    super.initState();
    _controller = FilterableQuantumListController<SampleItem>(
      List.generate(
          20, (i) => SampleItem(id: i + 1, title: 'آیتم شماره ${i + 1}')),
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
        title: const Text('QuantumList Demo'),
        actions: [
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

  Widget _buildList() {
    final itemBuilder = (BuildContext context, int index, SampleItem item,
        Animation<double> animation) {
      return QuantumAnimations.scaleIn(
        context,
        AnimatedBorderCard(
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
        ),
        animation,
      );
    };

    if (_listType == QuantumListType.list) {
      return QuantumList<SampleItem>(
        key: const Key('quantum_list_list_view'),
        controller: _controller,
        type: QuantumListType.list,
        padding: const EdgeInsets.all(8),
        animationBuilder: itemBuilder,
      );
    } else {
      return QuantumList<SampleItem>(
        key: const Key('quantum_list_grid_view'),
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
                    id: _nextItemId, title: 'آیتم جدید $_nextItemId'));
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
                _controller.filter((item) => item.id % 2 == 0);
              },
              child: const Text('فیلتر (زوج)')),
          ElevatedButton(
              onPressed: () {
                _controller.filter(null);
              },
              child: const Text('حذف فیلتر')),
          ElevatedButton(
              onPressed: () {
                _controller.sort((a, b) => a.numericId.compareTo(b.numericId));
              },
              child: const Text('مرتب‌سازی (صعودی)')),
          // **[اصلاح شده]** استفاده از متد جدید و دقیق scrollToItem
          ElevatedButton(
              onPressed: () {
                _controller.scrollToItem(
                  test: (item) => item.numericId == 10,
                  estimatedItemHeight: 110.0,
                  duration: Duration.zero,
                );
              },
              child: const Text('پرش به آیتم ۱۰')),
          ElevatedButton(
              onPressed: () {
                _controller.scrollToItem(
                  test: (item) => item.numericId == 10,
                  estimatedItemHeight: 110.0,
                );
              },
              child: const Text('اسکرول نرم به ۱۰')),
          ElevatedButton(
              onPressed: () {
                _controller.scrollToItem(
                  test: (item) => item.numericId == 10,
                  estimatedItemHeight: 110.0,
                  animation: QuantumScrollAnimation.bouncy,
                  duration: const Duration(milliseconds: 1200),
                );
              },
              child: const Text('اسکرول فنری به ۱۰')),
        ],
      ),
    );
  }
}
