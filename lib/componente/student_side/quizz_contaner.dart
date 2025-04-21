import 'package:flutter/material.dart';

class QuizzContaner extends StatelessWidget {
  final String text;

  const QuizzContaner({required this.text}); // ✅ Fix: Only one named parameter

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.lightGreen[600],
        ),
        
        width: MediaQuery.of(context).size.width * 0.9,
        height: 80,
        
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
