import 'package:flutter/material.dart';
import 'package:administration_application/user app/ConditionSelectPage.dart';

class OptionsSlide extends StatelessWidget {
const OptionsSlide({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
body: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
SizedBox(height: 20), // Gap between text and buttons
Container(
padding: EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.orange,
borderRadius: BorderRadius.circular(10),
),
child: Text(
'What am I treating:',
style: TextStyle(fontSize: 20, color: Colors.white),
),
),
SizedBox(height: 60), // Gap between text and buttons
ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: Colors.green[200],
padding: EdgeInsets.symmetric(horizontal: 40, vertical: 23), // Set padding to make buttons same size
),
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(builder: (context) => const ConditionSelectPage()),
);
},
child: const Text('Condition', style: TextStyle(fontSize: 18)),
),
const SizedBox(height: 16),
ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: Colors.green[200],
padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20), // Set padding to make buttons same size
),
onPressed: () {
},
child: const Text('Symptom', style: TextStyle(fontSize: 18)),
),
],
),
),
);
}
}
