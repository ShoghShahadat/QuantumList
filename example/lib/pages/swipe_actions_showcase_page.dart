import 'package:flutter/material.dart';
import 'package:quantum_list/quantum_list.dart';

/// صفحه‌ای برای نمایش قابلیت کنش‌های سوایپ.
class SwipeActionsShowcasePage extends StatefulWidget {
  const SwipeActionsShowcasePage({Key? key}) : super(key: key);

  @override
  State<SwipeActionsShowcasePage> createState() =>
      _SwipeActionsShowcasePageState();
}

class _SwipeActionsShowcasePageState extends State<SwipeActionsShowcasePage> {
  // Use a simple list of strings for the data model in this example.
  final List<String> _items =
      List.generate(10, (index) => 'email_${index + 1}');

  void _deleteItem(String id) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item $id deleted!'),
        backgroundColor: Colors.red.shade700,
      ),
    );
    setState(() {
      _items.remove(id);
    });
  }

  void _archiveItem(String id) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item $id archived!'),
        backgroundColor: Colors.green.shade700,
      ),
    );
    setState(() {
      _items.remove(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swipe Actions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // **[CRITICAL FIX]**
      // Instead of using QuantumList with a controller, we use a standard ListView.builder.
      // The QuantumSwipeAction widget is independent and can wrap any widget.
      // This also resolves the `dependOnInheritedWidgetOfExactType` error by building
      // the ListTiles directly in the build method, which has a valid context.
      // **[اصلاح حیاتی]**
      // به جای QuantumList، از یک ListView.builder استاندارد استفاده می‌کنیم.
      // ویجت QuantumSwipeAction مستقل است و می‌تواند هر ویجتی را در بر بگیرد.
      // این کار همچنین خطای `dependOnInheritedWidgetOfExactType` را با ساختن ListTileها
      // مستقیماً در متد build که context معتبر دارد، حل می‌کند.
      body: ListView.builder(
        itemCount: _items.length,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: QuantumSwipeAction(
                rightActions: [
                  Material(
                    color: Colors.red,
                    child: InkWell(
                      onTap: () => _deleteItem(item),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete, color: Colors.white),
                            Text('Delete',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                leftActions: [
                  Material(
                    color: Colors.green,
                    child: InkWell(
                      onTap: () => _archiveItem(item),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.archive, color: Colors.white),
                            Text('Archive',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
                child: ListTile(
                  tileColor: Theme.of(context).cardColor,
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text('Email Subject #${index + 1}'),
                  subtitle: const Text('Swipe left or right for actions...'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
