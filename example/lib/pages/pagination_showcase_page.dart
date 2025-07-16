import 'package:flutter/material.dart';
import 'package:quantum_list/quantum_list.dart';

/// A data model for our paginated items.
class Product {
  final int id;
  final String name;
  final Color color;
  Product({required this.id, required this.name, required this.color});
}

/// A page to showcase the smart pagination controller.
class PaginationShowcasePage extends StatefulWidget {
  const PaginationShowcasePage({Key? key}) : super(key: key);

  @override
  State<PaginationShowcasePage> createState() => _PaginationShowcasePageState();
}

class _PaginationShowcasePageState extends State<PaginationShowcasePage> {
  late final PaginatedQuantumListController<dynamic> _controller;

  @override
  void initState() {
    super.initState();
    _controller = PaginatedQuantumListController<dynamic>(
      _fetchProducts,
      // A special widget to show while loading the next page.
      loadingIndicator: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  /// Simulates fetching a page of products from an API.
  Future<List<Product>> _fetchProducts(int page) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate end of data
    if (page > 3) {
      return [];
    }

    // Generate a list of 10 products for the current page.
    return List.generate(10, (index) {
      final id = (page * 10) + index;
      return Product(
        id: id,
        name: 'Product $id',
        color: Colors.primaries[id % Colors.primaries.length].shade300,
      );
    });
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
        title: const Text('Smart Pagination'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _controller.refresh,
        child: QuantumList<dynamic>(
          controller: _controller,
          padding: const EdgeInsets.all(8),
          animationBuilder: (context, index, item, animation) {
            // Check if the item is a Product or the loading indicator.
            if (item is Product) {
              return Card(
                color: item.color,
                child: ListTile(
                  title: Text(item.name,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('Product ID: ${item.id}',
                      style: const TextStyle(color: Colors.white70)),
                ),
              );
            }
            // If it's not a product, it must be our loading indicator widget.
            return item;
          },
        ),
      ),
    );
  }
}
