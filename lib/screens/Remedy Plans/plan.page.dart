import 'package:flutter/material.dart';
import 'package:administration_application/objectbox.store.dart';
import 'package:administration_application/objectbox.g.dart';
import 'package:administration_application/entities/Remedies/item.entity.dart';
import 'package:administration_application/entities/Remedy Plans/plan.entity.dart';
import 'package:administration_application/entities/Health Issues/condition.entity.dart';

class PlansPage extends StatefulWidget {
  @override
  _PlansPageState createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  late final Box<Plans> _planBox;
  late final Box<Items> _itemBox;
  late final Box<Conditions> _conditionBox;
  List<Plans> _plans = [];
  List<Items> _items = [];
  List<Conditions> _conditions = [];
  Items? _selectedItem;
  Conditions? _selectedCondition;

  @override
  void initState() {
    super.initState();
    _itemBox = ObjectBoxService.objectBoxStore.box<Items>();
    _planBox = ObjectBoxService.objectBoxStore.box<Plans>();
    _conditionBox = ObjectBoxService.objectBoxStore.box<Conditions>();
    _loadItems();
    _loadConditions();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    if (_selectedItem != null) {
      _plans = [];
      for (final plan in _planBox.query().build().find()) {
        if (plan.Item.target?.id == _selectedItem?.id) {
          _plans.add(plan);
        }
      }
    }else if (_selectedCondition != null) {
      _plans = [];
      for (final plan in _planBox.query().build().find()) {
        if (plan.Condition.target?.id == _selectedCondition?.id) {
          _plans.add(plan);
        }
      }
    }
    else {
      _plans = _planBox.getAll();
    }
    setState(() {});
  }

  Future<void> _loadItems() async {
    _items = _itemBox.getAll();
    setState(() {});
  }

  Future<void> _loadConditions() async {
    _conditions = _conditionBox.getAll();
    setState(() {});
  }



  void _updatePlan(Plans plan) async {
    // Implement updating an existing item here
    // You can navigate to a new screen or dialog to edit the item details
    // After editing, call _loadItems() to refresh the list
  }

  void _deletePlans(Plans plan) async {
    // Implement deleting an item here
    _planBox.remove(plan.id);
    _loadPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remedy Plans'),
        actions: [
          PopupMenuButton<Conditions>(
            onSelected: (selectedCondition) {
              setState(() {
                _selectedCondition = selectedCondition;
                _loadPlans();
              });
            },
            itemBuilder: (BuildContext context) {
              return _conditions.map<PopupMenuEntry<Conditions>>((Conditions condition) {
                return PopupMenuItem<Conditions>(
                  value: condition,
                  child: Text(condition.name),
                );
              }).toList();
            },
          ),
        ],
      ),
      body:Column(
        children: [
          DropdownButtonFormField<Conditions>(
            value: _selectedCondition,
            items: _conditions.map((condition) {
              return DropdownMenuItem<Conditions>(
                value: condition,
                child: Text(condition.name),
              );
            }).toList(),
            onChanged: (selectedCondition) {
              setState(() {
                _selectedCondition = selectedCondition;
                _loadPlans();
              });
            },
            decoration: InputDecoration(
              labelText: 'Filter by Condition',
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _plans.length,
              itemBuilder: (BuildContext context, int index) {
                final plan = _plans[index];
                return ListTile(
                  title: Text(plan.name),
                  subtitle: Text(plan.Condition.target?.name ?? 'No Condition'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _updatePlan(plan);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {

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
                      AddPlanPage(
                        onAdditionComplete: () {
                          _loadPlans();
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

class AddPlanPage extends StatefulWidget {
  final Function() onAdditionComplete;

  AddPlanPage({required this.onAdditionComplete});

  @override
  _AddPlanPageState createState() => _AddPlanPageState();
}

class _AddPlanPageState extends State<AddPlanPage> {
  late TextEditingController _nameController;
  late TextEditingController _instructionsController;
  late TextEditingController _dosageController;
  late TextEditingController _precautionsController;
  late TextEditingController _referencesController;
  Conditions? _selectedCondition;
  List<Conditions> _conditions = [];
  Items? _selectedItem;
  List<Items> _items = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: '');
    _instructionsController = TextEditingController(text: '');
    _dosageController = TextEditingController(text: '');
    _precautionsController = TextEditingController(text: '');
    _referencesController= TextEditingController(text: '');

    _loadConditions();
    _loadItems();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    _dosageController.dispose();
    _precautionsController.dispose();
    _referencesController.dispose();
    super.dispose();
  }

  Future<void> _loadConditions() async {
    final conditionBox = ObjectBoxService.objectBoxStore.box<Conditions>();
    _conditions = conditionBox.getAll();
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
                _addPlan();
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

  void _addPlan() async {
    final planName = _nameController.text;
    final planInstructions = _instructionsController.text;
    final planDosage = _dosageController.text;
    final planPrecautions = _precautionsController.text;
    final planReferences = _referencesController.text;

    if (planName.isNotEmpty) {
      final newPlan = Plans(
        id: 0, // You can set a unique ID, or ObjectBox will auto-generate one.
        name: planName,
        instructions: planInstructions,
        dosage: planDosage,
        precautions: planPrecautions,
        references: planReferences,
      );

      if (_selectedCondition != null && _selectedItem !=null) {
        newPlan.Condition.target = _selectedCondition!;
        newPlan.Item.target = _selectedItem!;
      }

      final planBox = ObjectBoxService.objectBoxStore.box<Plans>();
      planBox.put(newPlan);
      widget.onAdditionComplete();

      // Optionally, you can navigate back to the items list or another screen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Add Plan')),
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
                  controller: _instructionsController,
                  decoration: InputDecoration(labelText: 'Instructions'),
                ),
                TextField(
                  controller: _dosageController,
                  decoration: InputDecoration(labelText: 'Dosage'),
                ),
                TextField(
                  controller: _precautionsController,
                  decoration: InputDecoration(labelText: 'Precaution'),
                ),

                TextField(
                  controller: _referencesController,
                  decoration: InputDecoration(labelText: 'References'),
                ),
                DropdownButtonFormField<Conditions>(
                  value: _selectedCondition,
                  items: _conditions.map((condition) {
                    return DropdownMenuItem<Conditions>(
                      value: condition,
                      child: Text(condition.name),
                    );
                  }).toList(),
                  onChanged: (selectedCondition) {
                    setState(() {
                      _selectedCondition = selectedCondition;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Select Condition'),
                ), DropdownButtonFormField<Items>(
                  value: _selectedItem,
                  items: _items.map((item) {
                    return DropdownMenuItem<Items>(
                      value: item,
                      child: Text(item.name),
                    );
                  }).toList(),
                  onChanged: (selectedItem) {
                    setState(() {
                      _selectedItem = selectedItem;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Select Item'),
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