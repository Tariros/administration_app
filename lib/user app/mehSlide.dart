import 'package:flutter/material.dart';

class MehSlide extends StatelessWidget {
  final String question;


  MehSlide({
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            question,
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}