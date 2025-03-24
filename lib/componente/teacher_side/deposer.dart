import 'package:flutter/material.dart';

class Deposer extends StatelessWidget {
  const Deposer({super.key});
  

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pushNamed(context, "/teacher_option");
      },
      icon: Icon(Icons.add, color: Colors.black),
      label: Text("OPTIONS"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightGreen[800],
        foregroundColor: Colors.white,
        textStyle: TextStyle(fontSize: 18),
      ),
    );
  }
}
