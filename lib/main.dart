import 'package:administration_application/homepage.dart';
import 'package:flutter/material.dart';
import 'package:administration_application/homescreen.dart';
import 'package:administration_application/objectbox.g.dart';
import 'package:administration_application/objectbox.store.dart';
import 'package:administration_application/screens/Health Issues/condition.page.dart';
import 'package:administration_application/screens/Remedies/item.page.dart';
import 'package:administration_application/screens/Remedies/category.page.dart';
import 'package:administration_application/screens/Remedy Plans/plan.page.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await ObjectBoxService.openObjectBoxStore();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var selectedConditions;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      routes: {
        '/CategoryScreen': (context) => CategoriesPage(selectedCategories: [],),
        '/ItemScreen':(context)=> ItemsPage(),
        '/ConditionScreen': (context)=> ConditionsPage(selectedConditions: [],),
        '/PlanScreen':(context)=> PlansPage(),
        //'/DeleteConditionScreen': (context)=> DeleteConditionPage(selectedConditions: selectedConditions),
      },
    );
  }
}
