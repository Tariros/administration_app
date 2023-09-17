import 'package:flutter/material.dart';
import 'package:administration_application/objectbox.store.dart';
import 'package:administration_application/objectbox.g.dart';
import 'package:administration_application/entities/Remedies/category.entity.dart';
import 'package:administration_application/entities/Remedies/item.entity.dart';

class CategoriesPage extends StatefulWidget {
  final List<Categories> selectedCategories;
  const CategoriesPage({super.key, required this.selectedCategories});

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late final Box<Categories> _categoryBox;
  List<Categories> _categories = [];

  @override
  void initState() {
    super.initState();
    _categoryBox = ObjectBoxService.objectBoxStore.box<Categories>();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    _categories = _categoryBox.getAll();
    setState(() {});


  }


  final TextEditingController _searchController = TextEditingController();
  int _visibleCategories = 20; // Default number of participants to display

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories Listing')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // Add search functionality here
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _visibleCategories,
              itemBuilder: (BuildContext context, int index) {
                if (index < _categories.length) {
                  final category = _categories[index];
                  return ListTile(
                    title: Text(category.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [


                        IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) =>DeleteCategoryPage(category: category, onDeleteComplete: () {_loadCategories();
                            }
                            )));
                            }),
                      ],
                    ),
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement add new condition functionality

          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddCategoryPage( onAdditionComplete:() { // Reload symptoms after editing
                _loadCategories(); }, ))

          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

///ADDING A NEW SYMPTOM
class AddCategoryPage extends StatefulWidget {

  final Function() onAdditionComplete;

  AddCategoryPage( {required this.onAdditionComplete});

  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context as BuildContext,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Addition'),
          content: const Text(
              'Are you sure you want to add this category'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                addCategory();
                //the above is functionality for adding the condition.
              },
              child: const Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void addCategory() {
    final categoryName = _nameController.text;

    if (categoryName.isNotEmpty) {
      final newCategory = Categories(
        id: 0, // You can set a unique ID, or ObjectBox will auto-generate one.
        name: categoryName,
        // Add other properties if needed
      );

      final categoryBox = ObjectBoxService.objectBoxStore.box<Categories>();
      categoryBox.put(newCategory);
      widget.onAdditionComplete();

      // Optionally, you can navigate back to the product list or another screen
      Navigator.pop(context as BuildContext);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Category')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),

            ElevatedButton(
              onPressed: _showConfirmationDialog,
              child: const Text('Add Category '),
            ),
          ],
        ),
      ),
    );
  }
}



///DELETE A SYMPTOM
class DeleteCategoryPage extends StatefulWidget {
  final Categories category;
  final Function() onDeleteComplete;

  DeleteCategoryPage({required this.category, required this.onDeleteComplete});

  @override
  _DeleteCategoryPageState createState() => _DeleteCategoryPageState();
}
class _DeleteCategoryPageState extends State<DeleteCategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Delete Category')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category: ${widget.category.name}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            ElevatedButton(
              onPressed: _showDeleteConfirmationDialog,
              child: Text('Delete Category'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this category?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteCategory();
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory() {
    final categoryBox = ObjectBoxService.objectBoxStore.box<Categories>();
    categoryBox.remove(widget.category.id);
    widget.onDeleteComplete();
    Navigator.pop(context);
  }
}
class ItemsPage extends StatefulWidget {
  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  late final Box<Items> _itemBox;
  late final Box<Categories> _categoryBox;
  List<Items> _items = [];
  List<Categories> _categories = [];
  Categories? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _itemBox = ObjectBoxService.objectBoxStore.box<Items>();
    _categoryBox = ObjectBoxService.objectBoxStore.box<Categories>();
    _loadItems();
    _loadCategories();
  }

  Future<void> _loadItems() async {
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

  Future<void> _loadCategories() async {
    _categories = _categoryBox.getAll();
    setState(() {});
  }



  void _updateItem(Items item) async {
    // Implement updating an existing item here
    // You can navigate to a new screen or dialog to edit the item details
    // After editing, call _loadItems() to refresh the list
  }

  void _deleteItem(Items item) async {
    // Implement deleting an item here
    _itemBox.remove(item.id);
    _loadItems();
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
                _loadItems();
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
      body:Column(
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
                _loadItems();
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _updateItem(item);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteItem(item);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AddItemPage(
                        onAdditionComplete: () {
                          _loadItems();
                        },
                      )
              )
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddItemPage extends StatefulWidget {
  final Function() onAdditionComplete;

  AddItemPage({required this.onAdditionComplete});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  late TextEditingController _nameController;
  late TextEditingController _alsoCalledController;
  late TextEditingController _usesController;
  late TextEditingController _cautionController;
  late TextEditingController _consumerInformationController;
  late TextEditingController _referencesController;
  Categories? _selectedCategory;
  List<Categories> _categories = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: '');
    _alsoCalledController = TextEditingController(text: '');
    _usesController = TextEditingController(text: '');
    _cautionController = TextEditingController(text: '');
    _consumerInformationController = TextEditingController(text: '');
    _referencesController = TextEditingController(text: '');
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _alsoCalledController.dispose();
    _usesController.dispose();
    _cautionController.dispose();
    _consumerInformationController.dispose();
    _referencesController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final categoryBox = ObjectBoxService.objectBoxStore.box<Categories>();
    _categories = categoryBox.getAll();
    setState(() {});
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Addition'),
          content: Text('Are you sure you want to add this item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _addItem();
              },
              child: Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _addItem() async {
    final itemName = _nameController.text;
    final itemAlsoCalled = _alsoCalledController.text;
    final itemUses = _usesController.text;
    final itemCaution = _cautionController.text;
    final itemConsumerInformation = _consumerInformationController.text;
    final itemReferences = _referencesController.text;

    if (itemName.isNotEmpty) {
      final newItem = Items(
        id: 0, // You can set a unique ID, or ObjectBox will auto-generate one.
        name: itemName,
        alsoCalled: itemAlsoCalled,
        uses: itemUses,
        caution: itemCaution,
        conscientiousConsumerInformation: itemConsumerInformation,
        references: itemReferences,
      );

      if (_selectedCategory != null) {
        newItem.category.target = _selectedCategory!;
      }

      final itemBox = ObjectBoxService.objectBoxStore.box<Items>();
      itemBox.put(newItem);
      widget.onAdditionComplete();

      // Optionally, you can navigate back to the items list or another screen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Add Item')),
        body: SingleChildScrollView(
          child:
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _alsoCalledController,
                  decoration: InputDecoration(labelText: 'Also Called'),
                ),
                TextField(
                  controller: _usesController,
                  decoration: InputDecoration(labelText: 'Uses'),
                ),
                TextField(
                  controller: _cautionController,
                  decoration: InputDecoration(labelText: 'Caution'),
                ),
                TextField(
                  controller: _consumerInformationController,
                  decoration: InputDecoration(labelText: 'Conscientious Consumer Information'),
                ),
                TextField(
                  controller: _referencesController,
                  decoration: InputDecoration(labelText: 'References'),
                ),
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
                    });
                  },
                  decoration: InputDecoration(labelText: 'Select Category'),
                ),
                ElevatedButton(
                  onPressed: _showConfirmationDialog,
                  child: Text('Add Item'),
                ),
              ],
            ),
          ),
        )
    );
  }
}