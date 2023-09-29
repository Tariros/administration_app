import 'package:flutter/material.dart';
import 'package:administration_application/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';
import 'package:administration_application/objectbox.store.dart';
import 'package:administration_application/entities/Health Issues/condition.entity.dart';
import 'package:administration_application/entities/Remedy Plans/plan.entity.dart';
import 'package:administration_application/user app/RemedyPlansPage.dart';


class ConditionSelectPage extends StatefulWidget {
  const ConditionSelectPage({super.key});

  @override
  _ConditionSelectPageState createState() => _ConditionSelectPageState();
}

class _ConditionSelectPageState extends State<ConditionSelectPage> {
  late final Box<Conditions> _conditionBox;
  List<Conditions> _conditions = [];
  List<Conditions> _filteredConditions = [];
  List<Conditions> _selectedConditions = [];
  TextEditingController _searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _conditionBox = ObjectBoxService.objectBoxStore.box<Conditions>();
    loadConditions();
  }

  void loadConditions() async {
    _conditions = _conditionBox.getAll();
    setState(() {});

  }

  void filterConditions(String query) {
    _filteredConditions = _conditions
        .where((condition) =>
        condition.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {});
  }

  void viewRemedyPlans() {
    // Filter selected conditions
    _selectedConditions = _conditions.where((condition) => condition.isSelected).toList();

    // Navigate to the Remedy Plans page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RemedyPlansPage(selectedConditions: _selectedConditions),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Condition List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (query) => filterConditions(query),
              decoration: InputDecoration(
                labelText: 'Search Conditions',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _conditions.length,
              itemBuilder: (context, index) {
                final condition = _conditions[index];
                return ListTile(
                  leading: Checkbox(
                    value: condition.isSelected,
                    onChanged: (value) {
                      setState(() {
                        condition.isSelected = value ?? false;
                      });
                    },
                  ),
                  title: Text(condition.name),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: viewRemedyPlans,
            child: Text('View Remedy Plans'),
          ),
        ],
      ),
    );
  }
}

