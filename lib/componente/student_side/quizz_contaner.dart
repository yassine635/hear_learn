import 'package:flutter/material.dart';
import 'package:hear_learn1/data/cheker.dart';

class QuizzContaner extends StatelessWidget {
  final String text;

  const QuizzContaner({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 100,
        decoration: BoxDecoration(
          color: Cheker.second_color, 
          borderRadius: BorderRadius.circular(400),
          border: Border.all( 
            color: Cheker.second_color,
            width: 3,
          ),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
