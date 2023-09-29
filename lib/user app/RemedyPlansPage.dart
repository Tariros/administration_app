import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import 'package:administration_application/objectbox.g.dart';
import 'package:administration_application/objectbox.store.dart';
import 'package:administration_application/entities/Health Issues/condition.entity.dart';
import 'package:administration_application/entities/Remedy Plans/plan.entity.dart';
import 'package:administration_application/entities/Remedies/item.entity.dart';


class RemedyPlansPage extends StatefulWidget {
  final List<Conditions> selectedConditions;

  RemedyPlansPage({required this.selectedConditions});

  @override
  _RemedyPlansPageState createState() => _RemedyPlansPageState();
}

class _RemedyPlansPageState extends State<RemedyPlansPage> {
  late final Box<Plans> _plansBox;
  List<Plans> _remedyPlans = [];

  @override
  void initState() {
    super.initState();
    _plansBox = ObjectBoxService.objectBoxStore.box<Plans>();
    loadRemedyPlans();
  }

  void loadRemedyPlans() {
    // Retrieve remedy plans associated with selected conditions
    _remedyPlans = [];
    for (var condition in widget.selectedConditions) {
      final plans = _plansBox.query(Plans_.Condition.equals(condition.id)).build().find();
      _remedyPlans.addAll(plans);
    }
    setState(() {});
  }

  void _viewPlan(Plans plan) {
    // Navigate to the ItemScreen with the selected item's data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanScreen(plan: plan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remedy Plans'),
      ),
      body: ListView.builder(
        itemCount: _remedyPlans.length,
        itemBuilder: (context, index) {
          final plan = _remedyPlans[index];
          return ListTile(
            title: Text(plan.name),
            // Add any other information you want to display about the remedy plan

            onTap: () {
              // Open the ItemScreen when tapped
              _viewPlan(plan);
            },
          );
        },
      ),
    );
  }
}
class PlanScreen extends StatefulWidget {
  final Plans plan;

  PlanScreen({required this.plan});

  @override
  _PlanScreenState createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  int _selectedIndex = 0; // Index of the selected tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plan Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(decoration: BoxDecoration(
            color: Colors.green, // Green container for name, instructions, and dosage
            borderRadius: BorderRadius.circular(16.0), // Rounded corners
          ),
            margin: EdgeInsets.all(16.0),
            padding: EdgeInsets.all(16.0),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.plan.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Instructions: ${widget.plan.instructions}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Dosage: ${widget.plan.dosage}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabButton(0, 'Precautions'),
                _buildTabButton(1, 'References'),
                _buildTabButton(2, 'Reviews'),
              ],
            ),
          ),
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      style: ElevatedButton.styleFrom(
        primary: _selectedIndex == index ? Colors.green : Colors.grey, // Green for selected, grey for others
      ),
      child: Text(label),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildPrecautionsTab();
      case 1:
        return _buildReferencesTab();
      case 2:
        return _buildReviewsTab();
      default:
        return Container(); // Placeholder for unknown tab
    }
  }

  Widget _buildPrecautionsTab() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Precautions: ${widget.plan.precautions}',
        style: TextStyle(
          fontSize: 18.0,
        ),
      ),
    );
  }

  Widget _buildReferencesTab() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'References: ${widget.plan.references}',
        style: TextStyle(
          fontSize: 18.0,
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    // Replace with your implementation for displaying reviews
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Reviews go here',
        style: TextStyle(
          fontSize: 18.0,
        ),
      ),
    );
  }
}