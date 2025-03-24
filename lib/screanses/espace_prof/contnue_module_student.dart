import 'package:flutter/material.dart';
import 'package:hear_learn1/componente/student_side/cour.dart';
import 'package:hear_learn1/componente/student_side/td.dart';
import 'package:hear_learn1/componente/student_side/tp.dart';

class Contnue_Module_Student extends StatelessWidget {
  const Contnue_Module_Student({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("module",
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                 "/home_student"
              );
            },
            icon: const Icon(Icons.arrow_back, size: 30, color: Colors.white),
          ),
        ],
        backgroundColor: Colors.lightGreen[800],
      ),
      body: Column(
        children: [
          Cour(),
          Td(),
          Tp(),
        ],
      ),
    );
  }
}
