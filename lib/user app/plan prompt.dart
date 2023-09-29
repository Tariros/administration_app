import 'package:flutter/material.dart';
import 'package:administration_application/user app/mehSlide.dart';
import 'package:administration_application/user app/selectSlide.dart';


class PlanPrompt extends StatefulWidget {
  @override
  _PlanPromptState createState() => _PlanPromptState();
}

class _PlanPromptState extends State<PlanPrompt> {
  int _currentPageIndex = 0;

  final List<Widget> slides = [
    MehSlide(
      question: "Are you feeling meh?",

    ),
    OptionsSlide(),
  ];

  void nextPage() {
    setState(() {
      if (_currentPageIndex < slides.length - 1) {
        _currentPageIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Slide Show App"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView(
              controller: PageController(
                initialPage: _currentPageIndex,
              ),
              children: slides,
            ),
          ),

        ],
      ),
    );
  }
}






