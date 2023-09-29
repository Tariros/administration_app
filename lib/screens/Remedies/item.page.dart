
import 'package:flutter/material.dart';
import 'package:administration_application/objectbox.store.dart';
import 'package:administration_application/objectbox.g.dart';
import 'package:administration_application/entities/Remedies/category.entity.dart';
import 'package:administration_application/entities/Remedies/item.entity.dart';
import 'package:administration_application/entities/Remedies/interaction.entity.dart';

class ItemPage extends StatefulWidget {
  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
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
              labelText: ' Category',
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
                    IconButton(
                    icon: Icon(Icons.visibility),
                   onPressed: () {
                      //Navigator.push(
                     //context,
                    // MaterialPageRoute(
                     //  builder: (context) => ViewItemPage(item: item),
                    // ),
                 //  );

                },
                ),
                ],
                  )
                );
                }
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
  List<InteractionEntry> _interactions = []; // List to store interactions
  List<Items> _items = []; // Define _items list


  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: '');
    _alsoCalledController = TextEditingController(text: '');
    _usesController = TextEditingController(text: '');
    _cautionController = TextEditingController(text: '');
    _consumerInformationController = TextEditingController(text: '');
    _referencesController = TextEditingController(text: '');
    _loadItems();
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

  Future<void> _loadItems() async {
    final itemBox = ObjectBoxService.objectBoxStore.box<Items>();
    _items = itemBox.getAll();
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
        id: 0,
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

      // Add interactions to the new item
      for (final entry in _interactions) {
        if (entry.selectedItem != null &&
            entry.descriptionController.text.isNotEmpty) {
          final interaction = Interactions(
            id: 0,
            // You can set a unique ID or ObjectBox will auto-generate one
            description: entry.descriptionController.text,
          );
          interaction.items.add(
              newItem); // Link the interaction to the new item
          interaction.items.add(
              entry.selectedItem!); // Link the interaction to the selected item
          final interactionBox = ObjectBoxService.objectBoxStore.box<
              Interactions>();
          interactionBox.put(interaction);
        }
      }

      widget.onAdditionComplete();
      Navigator.pop(context);
    }
  }

  List<Widget> _interactionWidgets = []; // List to store interaction widgets


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Item')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ... (other text fields and dropdowns)
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
              ElevatedButton(
                onPressed: _addInteraction,
                child: Text('Add Interaction'),
              ),
              Column(
                children: _interactionWidgets,
              ),

              TextField(
                controller: _consumerInformationController,
                decoration: InputDecoration(
                    labelText: 'Conscientious Consumer Information'),
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
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

// ... (other methods)

// Function to add an interaction entry
  void _addInteraction() {
    final entry = InteractionEntry(
      selectedItem: null,
      descriptionController: TextEditingController(text: ''),
    );

    setState(() {
      _interactionWidgets.add(
        Row(
          children: [
            // Dropdown to select an existing item for interaction
            DropdownButton<Items>(
              value: entry.selectedItem,
              onChanged: (item) {
                setState(() {
                  entry.selectedItem = item;
                });
              },
              items: _items.map((item) {
                return DropdownMenuItem<Items>(
                  value: item,
                  child: Text(item.name),
                );
              }).toList(),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: entry.descriptionController,
                decoration: InputDecoration(
                  labelText: 'Interaction Description',
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
class InteractionEntry {
  Items? selectedItem;
  TextEditingController descriptionController;

  InteractionEntry({
    this.selectedItem,
    required this.descriptionController,
  });

}