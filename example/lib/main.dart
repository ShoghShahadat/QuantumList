import 'package:flutter/material.dart';
// فرض بر این است که پکیج شما در pubspec.yaml اضافه شده است
// import 'package:quantum_list/quantum_list.dart';

// --- شبیه‌سازی فایل‌های پکیج برای اجرای این مثال ---
// در پروژه واقعی، این بخش را حذف کرده و پکیج را import کنید
import 'package_simulator/quantum_list.dart';
// --- پایان بخش شبیه‌سازی ---

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
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.purpleAccent,
        ),
      ),
      home: const QuantumHomePage(),
    );
  }
}

// مدل داده برای آیتم‌های لیست
class SampleItem {
  final int id;
  String title;
  int counter;

  SampleItem({required this.id, required this.title, this.counter = 0});
}

class QuantumHomePage extends StatefulWidget {
  const QuantumHomePage({Key? key}) : super(key: key);

  @override
  State<QuantumHomePage> createState() => _QuantumHomePageState();
}

class _QuantumHomePageState extends State<QuantumHomePage> {
  // استفاده از کامل‌ترین کنترلر که همه قابلیت‌ها را دارد
  late final NotifyingQuantumListController<SampleItem> _controller;
  QuantumListType _listType = QuantumListType.list;
  int _nextItemId = 21;

  @override
  void initState() {
    super.initState();
    _controller = NotifyingQuantumListController<SampleItem>(
      List.generate(
        20,
        (i) => SampleItem(id: i + 1, title: 'آیتم شماره ${i + 1}'),
      ),
      onAtEnd: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('به انتهای لیست رسیدید!'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      onAtStart: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('به ابتدای لیست رسیدید!'),
            duration: Duration(seconds: 1),
          ),
        );
      },
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
          // دکمه برای تغییر حالت لیست/گرید
          IconButton(
            icon: Icon(
              _listType == QuantumListType.list
                  ? Icons.grid_view
                  : Icons.view_list,
            ),
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
      body: QuantumList<SampleItem>(
        controller: _controller,
        type: _listType,
        padding: const EdgeInsets.all(8),
        // برای حالت گرید، این پارامتر الزامی است
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.5,
        ),
        // این بیلدر، قلب تپنده ظاهر لیست شماست
        animationBuilder: (context, index, item, animation) {
          // استفاده از انیمیشن‌های آماده
          return QuantumAnimations.scaleIn(
            context,
            // استفاده از ویجت بوردر متحرک
            AnimatedBorderCard(
              child: ListTile(
                title: Text(item.title),
                // این بخش با .atom مشخص شده و فقط خودش آپدیت می‌شود
                subtitle: Text(
                  'تعداد کلیک: ${item.counter}',
                ).atom(_controller, index),
                onTap: () {
                  // تست قابلیت به‌روزرسانی اتمی
                  _controller.updateProperty(index, (itemToUpdate) {
                    itemToUpdate.counter++;
                  });
                },
              ),
            ),
            animation,
          );
        },
      ),
      // پنل دکمه‌های کنترلی
      bottomNavigationBar: _buildControlPanel(),
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
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('افزودن'),
            onPressed: () {
              _controller.add(
                SampleItem(id: _nextItemId, title: 'آیتم جدید $_nextItemId'),
              );
              _nextItemId++;
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.remove),
            label: const Text('حذف اولی'),
            onPressed: () {
              if (_controller.length > 0) {
                _controller.removeAt(0);
              }
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.filter_alt),
            label: const Text('فیلتر (زوج)'),
            onPressed: () {
              // این کنترلر باید از نوع Filterable باشد
              if (_controller is FilterableQuantumListController) {
                (_controller as FilterableQuantumListController).filter(
                  (item) => item.id % 2 == 0,
                );
              }
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.filter_alt_off),
            label: const Text('حذف فیلتر'),
            onPressed: () {
              if (_controller is FilterableQuantumListController) {
                (_controller as FilterableQuantumListController).filter(null);
              }
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_downward),
            label: const Text('برو به آیتم ۱۰'),
            onPressed: () {
              _controller.scrollToIndex(10, estimatedItemHeight: 80);
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.gps_fixed),
            label: const Text('موقعیت آیتم ۲'),
            onPressed: () {
              final rect = _controller.getRectForIndex(2);
              if (rect != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'موقعیت آیتم ۲: ${rect.top.toStringAsFixed(1)}px از بالا',
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('آیتم ۲ روی صفحه نیست!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// نکته مهم: برای اینکه این مثال کار کند، باید فایل‌های پکیج را در یک پوشه
// به نام `package_simulator` در کنار `main.dart` قرار دهید.
// در پروژه واقعی، فقط کافیست پکیج را از pub.dev اضافه کنید.
