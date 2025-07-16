import 'package:flutter/material.dart';
import 'package:quantum_list/quantum_list.dart';
import 'dart:math';

void main() {
  runApp(const QuantumExampleApp());
}

// --- ساختار اصلی برنامه ---
class QuantumExampleApp extends StatelessWidget {
  const QuantumExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuantumList Example V8.0.0 - The Revolution',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.purple.shade300, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple.shade300,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
      home: const QuantumSelectorPage(),
    );
  }
}

class QuantumSelectorPage extends StatefulWidget {
  const QuantumSelectorPage({Key? key}) : super(key: key);

  @override
  State<QuantumSelectorPage> createState() => _QuantumSelectorPageState();
}

class _QuantumSelectorPageState extends State<QuantumSelectorPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    DataModelDemoPage(),
    WidgetEntityDemoPage(), // <-- صفحه جدید و انقلابی
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.data_object),
            label: 'دموی مدل-داده',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.widgets),
            label: 'دموی ویجت-شناسه',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple.shade300,
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- دموی اول: قابلیت‌های قبلی (بدون تغییر) ---

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

class DataModelDemoPage extends StatefulWidget {
  const DataModelDemoPage({Key? key}) : super(key: key);
  @override
  State<DataModelDemoPage> createState() => _DataModelDemoPageState();
}

class _DataModelDemoPageState extends State<DataModelDemoPage> {
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
        title: const Text('دموی مدل-داده (قدیمی)'),
        actions: [
          _buildAnimationSelector(),
          IconButton(
            icon: Icon(_listType == QuantumListType.list
                ? Icons.grid_view
                : Icons.view_list),
            onPressed: () => setState(() => _listType =
                _listType == QuantumListType.list
                    ? QuantumListType.grid
                    : QuantumListType.list),
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
        onSelected: (result) => setState(() => _animationType = result),
        itemBuilder: (context) => QuantumAnimationType.values
            .map((e) => PopupMenuItem(value: e, child: Text(e.name)))
            .toList());
  }

  Widget _buildItem(BuildContext context, int index, SampleItem item,
      Animation<double> animation) {
    final card = _buildCard(index, item);
    switch (_animationType) {
      case QuantumAnimationType.fadeIn:
        return QuantumAnimations.fadeIn(context, card, animation);
      case QuantumAnimationType.slideInFromBottom:
        return QuantumAnimations.slideInFromBottom(context, card, animation);
      case QuantumAnimationType.slideInFromLeft:
        return QuantumAnimations.slideInFromLeft(context, card, animation);
      case QuantumAnimationType.slideInFromRight:
        return QuantumAnimations.slideInFromRight(context, card, animation);
      case QuantumAnimationType.flipInY:
        return QuantumAnimations.flipInY(context, card, animation);
      case QuantumAnimationType.scaleIn:
      default:
        return QuantumAnimations.scaleIn(context, card, animation);
    }
  }

  Widget _buildList() {
    return QuantumList<SampleItem>(
      key: ValueKey('${_animationType}_${_listType}'),
      controller: _controller,
      type: _listType,
      padding: const EdgeInsets.all(8),
      gridDelegate: _listType == QuantumListType.grid
          ? const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.0)
          : null,
      animationBuilder: _buildItem,
    );
  }

  Widget _buildCard(int index, SampleItem item) {
    return AnimatedBorderCard(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _controller.updateProperty(
            index, (itemToUpdate) => itemToUpdate.counter++),
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
              onPressed: () => _controller
                  .sort((a, b) => a.numericId.compareTo(b.numericId)),
              child: const Text('مرتب‌سازی')),
          ElevatedButton(
              onPressed: () => _controller.scrollToItem(
                  test: (item) => item.numericId == 999),
              child: const Text('برو به آیتم ۹۹۹')),
        ],
      ),
    );
  }
}

// --- دموی دوم: ویجت-شناسه (انقلاب جدید) ---

class WidgetEntityDemoPage extends StatefulWidget {
  const WidgetEntityDemoPage({Key? key}) : super(key: key);
  @override
  State<WidgetEntityDemoPage> createState() => _WidgetEntityDemoPageState();
}

class _WidgetEntityDemoPageState extends State<WidgetEntityDemoPage> {
  final QuantumWidgetController _controller = QuantumWidgetController();
  final TextEditingController _idController = TextEditingController();
  final Random _random = Random();
  int _widgetCounter = 0;

  // یک ویجت سفارشی برای نمایش
  Widget _buildSampleWidget(String id, Color color) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Center(
        child: Text(
          'ویجت سفارشی\nID: $id',
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  void _addWidget() {
    _widgetCounter++;
    final id = 'widget_$_widgetCounter';
    final color = Colors.primaries[_random.nextInt(Colors.primaries.length)];
    _controller
        .add(QuantumEntity(id: id, widget: _buildSampleWidget(id, color)));
  }

  void _removeWidget() {
    if (_idController.text.isNotEmpty) {
      _controller.remove(_idController.text);
      _idController.clear();
    }
  }

  void _updateWidget() {
    if (_idController.text.isNotEmpty) {
      final id = _idController.text;
      final color = Colors.accents[_random.nextInt(Colors.accents.length)];
      _controller.update(id, _buildSampleWidget(id, color));
      _idController.clear();
    }
  }

  void _scrollToWidget() {
    if (_idController.text.isNotEmpty) {
      _controller.scrollTo(_idController.text);
      _idController.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دموی ویجت-شناسه (انقلابی)'),
      ),
      body: Column(
        children: [
          Expanded(
            child: QuantumList<QuantumEntity>(
              controller: _controller,
              padding: const EdgeInsets.all(8),
              animationBuilder: (context, index, entity, animation) {
                // به سادگی ویجت را از موجودیت گرفته و با انیمیشن نمایش می‌دهیم
                return QuantumAnimations.scaleIn(
                    context, entity.widget, animation);
              },
            ),
          ),
          _buildControlPanel(),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Material(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'شناسه ویجت (مثلا: widget_1)',
                hintText: 'برای حذف/آپدیت/اسکرول وارد کنید',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  onPressed: _addWidget,
                  label: const Text('افزودن ویجت'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  onPressed: _removeWidget,
                  label: const Text('حذف'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.update),
                  onPressed: _updateWidget,
                  label: const Text('آپدیت'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade400),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_downward),
                  onPressed: _scrollToWidget,
                  label: const Text('اسکرول'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
