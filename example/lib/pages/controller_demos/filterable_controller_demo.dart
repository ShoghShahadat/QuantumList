import 'dart:math';
import 'package:example/models/user_card.dart';
import 'package:example/models/user_model.dart';
// import 'package:example/widgets/user_card.dart';
import 'package:flutter/material.dart';
import 'package:quantum_list/quantum_list.dart';

enum SortType { none, nameAsc, nameDesc, scoreAsc, scoreDesc }

/// Demonstrates the usage of `FilterableQuantumListController`.
class FilterableControllerDemo extends StatefulWidget {
  const FilterableControllerDemo({Key? key}) : super(key: key);

  @override
  State<FilterableControllerDemo> createState() =>
      _FilterableControllerDemoState();
}

class _FilterableControllerDemoState extends State<FilterableControllerDemo> {
  late final FilterableQuantumListController<User> _controller;
  final TextEditingController _searchController = TextEditingController();
  SortType _sortType = SortType.none;

  @override
  void initState() {
    super.initState();
    _controller =
        FilterableQuantumListController<User>(_generateInitialUsers());
    _searchController.addListener(_onSearchChanged);
  }

  List<User> _generateInitialUsers() {
    final random = Random();
    final names = [
      'Alice',
      'Bob',
      'Charlie',
      'David',
      'Eve',
      'Frank',
      'Grace',
      'Heidi',
      'Ivan',
      'Judy'
    ];
    return List.generate(
        10,
        (index) => User(
            id: index, name: names[index], score: 50 + random.nextInt(51)));
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _controller.filter(null); // Remove filter
    } else {
      _controller.filter((user) => user.name.toLowerCase().contains(query));
    }
  }

  void _onSortChanged(SortType? newSortType) {
    if (newSortType == null) return;
    setState(() {
      _sortType = newSortType;
    });

    switch (newSortType) {
      case SortType.nameAsc:
        _controller.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortType.nameDesc:
        _controller.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortType.scoreAsc:
        _controller.sort((a, b) => a.score.compareTo(b.score));
        break;
      case SortType.scoreDesc:
        _controller.sort((a, b) => b.score.compareTo(a.score));
        break;
      case SortType.none:
        // To reset sort, we have to re-filter with the original master list order
        _controller.sort((a, b) => a.id.compareTo(b.id));
        break;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Control Panel
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search by name...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<SortType>(
                value: _sortType,
                onChanged: _onSortChanged,
                items: const [
                  DropdownMenuItem(
                      value: SortType.none, child: Text('Sort By')),
                  DropdownMenuItem(
                      value: SortType.nameAsc, child: Text('Name (A-Z)')),
                  DropdownMenuItem(
                      value: SortType.nameDesc, child: Text('Name (Z-A)')),
                  DropdownMenuItem(
                      value: SortType.scoreAsc,
                      child: Text('Score (Low-High)')),
                  DropdownMenuItem(
                      value: SortType.scoreDesc,
                      child: Text('Score (High-Low)')),
                ],
              ),
            ],
          ),
        ),
        // The List
        Expanded(
          child: QuantumList<User>(
            controller: _controller,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            animationBuilder: (context, index, user, animation) =>
                QuantumAnimations.slideInFromBottom(
              context,
              UserCard(user: user),
              animation,
            ),
          ),
        ),
      ],
    );
  }
}
