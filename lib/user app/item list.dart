import 'package:flutter/material.dart';
import 'package:administration_application/entities/Remedies/category.entity.dart';
import 'package:administration_application/entities/Remedies/item.entity.dart';
import 'package:administration_application/entities/Remedy Plans/plan.entity.dart';
import 'package:administration_application/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:administration_application/objectbox.store.dart';
import 'package:administration_application/entities/Health Issues/condition.entity.dart';

class ItemList extends StatefulWidget {
  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  late final Box<Items> _itemBox;
  late final Box<Categories> _categoryBox;
  List<Items> _items = [];
  List<Categories> _categories = [];
  Categories? _selectedCategory;
  // Getter to retrieve associated conditions


  @override
  void initState() {
    super.initState();
    _itemBox = ObjectBoxService.objectBoxStore.box<Items>();
    _categoryBox = ObjectBoxService.objectBoxStore.box<Categories>();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_selectedCategory != null) {
      _items = [];
      for (final item in _itemBox.query().build().find()) {
        if (item.category.target?.id == _selectedCategory?.id) {
          _items.add(item);
        }
      }
    } else {
      _items = _itemBox.getAll();
    }
    setState(() {});

  }

  void _viewItem(Items item) {
    // Navigate to the ItemScreen with the selected item's data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemScreen(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items Listing'),
        actions: [
          PopupMenuButton<Categories>(
            onSelected: (selectedCategory) {
              setState(() {
                _selectedCategory = selectedCategory;
                _loadData();
              });
            },
            itemBuilder: (BuildContext context) {
              return _categories.map<PopupMenuEntry<Categories>>((Categories category) {
                return PopupMenuItem<Categories>(
                  value: category,
                  child: Text(category.name),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          DropdownButtonFormField<Categories>(
            value: _selectedCategory,
            items: _categories.map((category) {
              return DropdownMenuItem<Categories>(
                value: category,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (selectedCategory) {
              setState(() {
                _selectedCategory = selectedCategory;
                _loadData();
              });
            },
            decoration: InputDecoration(
              labelText: 'Filter by Category',
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = _items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.category.target?.name ?? 'No Category'),
                  onTap: () {
                    // Open the ItemScreen when tapped
                    _viewItem(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ItemScreen extends StatefulWidget {
  final Items item;


  const ItemScreen({Key? key, required this.item}) : super(key: key);

  @override
  _ItemScreenState createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  String selectedTab = 'Information';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 32),
                const SizedBox(width: 8),
                Text(
                  widget.item.name,
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildTabButton('Information', Icons.info_outline),
              buildTabButton('Usages', Icons.medical_information_outlined),
              buildTabButton('Precautions', Icons.warning_amber),
              buildTabButton('Reviews', Icons.comment),
              buildTabButton('Conditions', Icons.heart_broken_sharp), // Add this tab
            ],
          ),
          const Divider(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: buildSelectedTabContent(),
            ),
          ),
        ],
      ),

    );
  }

  Widget buildTabButton(String tabName, IconData iconData) {
    bool isSelected = selectedTab == tabName;
    Color? iconColor = Colors.white;

    if (isSelected) {
      switch (tabName) {
        case 'Information':
          iconColor = Colors.green[300];
          break;
        case 'Usages':
          iconColor = Colors.blue[300];
          break;
        case 'Precautions':
          iconColor = Colors.yellow[300];
          break;
        case 'Reviews':
          iconColor = Colors.pink[300];
          break;
        case 'Conditions':
          iconColor = Colors.orange[300];
          break;
        default:
          break;
      }
    }

    return InkWell(
      onTap: () {
        setState(() {
          selectedTab = isSelected ? '' : tabName;
        });
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: isSelected ? iconColor : Colors.grey,
            child: Icon(
              iconData,
              color: isSelected ? Colors.white : iconColor,
            ),
          ),
          Visibility(
            visible: isSelected,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(tabName),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSelectedTabContent() {
    switch (selectedTab) {
      case 'Information':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${widget.item.name}'),
            Text('Also Called: ${widget.item.alsoCalled}'),
            Text('Consumer Information: ${widget.item.conscientiousConsumerInformation}'),
            Text('Source: ${widget.item.references}'),
          ],
        );
      case 'Usages':
        return Text('Usages:\n${widget.item.uses}');
      case 'Precautions':
        return Text('Precautions:\n${widget.item.caution}');
      case 'Reviews':
        return const Text('Functionality not yet implemented.');
      case 'Conditions':
      // Retrieve conditions from associated plans
        final conditions = <String>[];
        for (final plan in widget.item.plan) {
          final condition = plan.Condition.target;
          if (condition != null) {
            conditions.add(condition.name);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Conditions:'),
            for (final condition in conditions)
              Text('- $condition'),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}


