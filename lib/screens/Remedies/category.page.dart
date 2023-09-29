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