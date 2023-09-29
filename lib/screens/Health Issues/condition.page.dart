import 'package:flutter/material.dart';
import 'package:administration_application/entities/Health Issues/condition.entity.dart';
import 'package:administration_application/objectbox.store.dart';
import 'package:administration_application/objectbox.g.dart';

class ConditionsPage extends StatefulWidget {
  final List<Conditions> selectedConditions;
  const ConditionsPage({super.key, required this.selectedConditions});

  @override
  _ConditionsPageState createState() => _ConditionsPageState();
}

class _ConditionsPageState extends State<ConditionsPage> {
  late final Box<Conditions> _conditionBox;
  List<Conditions> _conditions = [];

  @override
  void initState() {
    super.initState();
    _conditionBox = ObjectBoxService.objectBoxStore.box<Conditions>();
    _loadConditions();
  }

  Future<void> _loadConditions() async {
    _conditions = _conditionBox.getAll();
    setState(() {});


  }
  final TextEditingController _searchController = TextEditingController();
 int _visibleConditions = 20; // Default number of participants to display

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conditions Listing')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search conditions...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // Add search functionality here
              },
            ),
          ),
         DropdownButton<int>(
            value: _visibleConditions,
            items: [20, 30, 50, 100].map((int value) {
              return DropdownMenuItem<int>(
               value: value,
               child: Text('$value Conditions'),
              );
            }).toList(),
            onChanged: (int? newValue) {
             setState(() {
                _visibleConditions = newValue!;
              });
            },
         ),
          Expanded(
            child: ListView.builder(
              itemCount: _visibleConditions,
              itemBuilder: (BuildContext context, int index) {
                if (index < _conditions.length) {
                  final condition = _conditions[index];
                  return ListTile(
                    title: Text(condition.name),
                    subtitle: Text(condition.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {Navigator.push(context,
                                MaterialPageRoute(builder: (context) => EditConditionPage(condition: condition, onEditComplete: () { // Reload symptoms after editing
                                  _loadConditions(); },)));
                            }

                        ),

                        IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              Navigator.push(
                                  context, MaterialPageRoute(builder: (context) =>
                                  DeleteConditionPage(
                                      condition: condition, onDeleteComplete: () {
                                    _loadConditions(); // Reload symptoms after deleting
                                  }
                                  )));
                            }
                        ),

                        IconButton(
                          icon: Icon(Icons.visibility),
                          onPressed: () {
                            // Implement view functionality
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => ViewConditionPage(condition: condition, )));

                          },
                        ),
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
              MaterialPageRoute(builder: (context) => AddConditionPage( onAdditionComplete:() { // Reload symptoms after editing
                _loadConditions(); }, ))

          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

///ADDING A NEW SYMPTOM
class AddConditionPage extends StatefulWidget {

  final Function() onAdditionComplete;

  AddConditionPage( {required this.onAdditionComplete});

  @override
  _AddConditionPageState createState() => _AddConditionPageState();
}

class _AddConditionPageState extends State<AddConditionPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _causesController;
  late TextEditingController _complicationsController;


  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: '');
    _descriptionController = TextEditingController(text: '');
    _causesController = TextEditingController(text: '');
    _complicationsController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _causesController.dispose();
    _complicationsController.dispose();
    super.dispose();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context as BuildContext,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Addition'),
          content: const Text(
              'Are you sure you want to add this condition to the database?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                addCondition();
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

  void addCondition() {
    final conditionName = _nameController.text;
    final conditionDescription = _descriptionController.text;
    final conditionCauses = _causesController.text.split('\n');
    final conditionComplications = _complicationsController.text.split('\n');

    if (conditionName.isNotEmpty && conditionDescription.isNotEmpty) {
      final newCondition = Conditions(
        id: 0, // You can set a unique ID, or ObjectBox will auto-generate one.
        name: conditionName,
        description: conditionDescription,
        causes: conditionCauses,
        complications: conditionComplications,
        // Add other properties if needed
      );

      final conditionBox = ObjectBoxService.objectBoxStore.box<Conditions>();
      conditionBox.put(newCondition);
      widget.onAdditionComplete();

      // Optionally, you can navigate back to the product list or another screen
      Navigator.pop(context as BuildContext);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Condition')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _causesController,
              decoration:
              const InputDecoration(labelText: 'Causes (one per line)'),
              maxLines: null,
            ),
            TextField(
              controller: _complicationsController,
              decoration: const InputDecoration(
                  labelText: 'Complications (one per line)'),
              maxLines: null,
            ),
            ElevatedButton(
              onPressed: _showConfirmationDialog,
              child: const Text('Add Symptom to Database'),
            ),
          ],
        ),
      ),
    );
  }
}


///EDIT A SYMPTOM
class EditConditionPage extends StatefulWidget {
  final Conditions condition;
  final Function() onEditComplete;

  EditConditionPage( {required this.condition,required this.onEditComplete});

  @override
  _EditConditionPageState createState() => _EditConditionPageState();
}

class _EditConditionPageState extends State<EditConditionPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _causesController;
  late TextEditingController _complicationsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.condition.name);
    _descriptionController = TextEditingController(text: widget.condition.description);
    _causesController = TextEditingController(text: widget.condition.causes.join('\n'));
    _complicationsController = TextEditingController(text: widget.condition.complications.join('\n'));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _causesController.dispose();
    _complicationsController.dispose();
    super.dispose();
  }

  void _showEditConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Edit'),
          content: const Text('Are you sure you want to save the changes?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _editCondition();
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

  void _editCondition() {
    final conditionName = _nameController.text;
    final conditionDescription = _descriptionController.text;
    final conditionCauses = _causesController.text.split('\n');
    final conditionComplications = _complicationsController.text.split('\n');

    if (conditionName.isNotEmpty && conditionDescription.isNotEmpty) {
      final updatedCondition = widget.condition
        ..name = conditionName
        ..description = conditionDescription
        ..causes = conditionCauses
        ..complications = conditionComplications;

      final conditionBox = ObjectBoxService.objectBoxStore.box<Conditions>();
      conditionBox.put(updatedCondition);
      widget.onEditComplete();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Condition')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _causesController,
              decoration:
              const InputDecoration(labelText: 'Causes (one per line)'),
              maxLines: null,
            ),
            TextField(
              controller: _complicationsController,
              decoration: const InputDecoration(
                  labelText: 'Complications (one per line)'),
              maxLines: null,
            ),
            ElevatedButton(
              onPressed: _showEditConfirmationDialog,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
///VIEW A CONDITION

class ViewConditionPage extends StatelessWidget {

  final Conditions condition;

  ViewConditionPage({required this.condition});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Condition Information')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Condition Name: ${condition.name}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Description: ${condition.description}'),
            SizedBox(height: 8),
            Text('Causes: ${condition.causes.join(", ")}'),
            SizedBox(height: 8),
            Text('Complications: ${condition.complications.join(", ")}'),
            SizedBox(height: 16),

          ],
        ),
      ),
    );
  }
}

///DELETE A CONDITION
class DeleteConditionPage extends StatefulWidget {
  final Conditions condition;
  final Function() onDeleteComplete;

  DeleteConditionPage({required this.condition, required this.onDeleteComplete});

  @override
  _DeleteConditionPageState createState() => _DeleteConditionPageState();
}
class _DeleteConditionPageState extends State<DeleteConditionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Delete Condition')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Condition Name: ${widget.condition.name}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Description: ${widget.condition.description}'),
            SizedBox(height: 8),
            Text('Causes: ${widget.condition.causes.join(", ")}'),
            SizedBox(height: 8),
            Text('Complications: ${widget.condition.complications.join(", ")}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showDeleteConfirmationDialog,
              child: Text('Delete Condition'),
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
          content: Text('Are you sure you want to delete this condition?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteCondition();
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

  void _deleteCondition() {
    final conditionBox = ObjectBoxService.objectBoxStore.box<Conditions>();
    conditionBox.remove(widget.condition.id);
    widget.onDeleteComplete();
    Navigator.pop(context);
  }
}
