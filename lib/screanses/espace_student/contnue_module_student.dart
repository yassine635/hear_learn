import 'package:flutter/material.dart';
import 'package:hear_learn1/componente/student_side/cour.dart';
import 'package:hear_learn1/componente/student_side/td.dart';
import 'package:hear_learn1/componente/student_side/tp.dart';

class Contnue_Module_Student extends StatelessWidget {
  final  String module;
  const Contnue_Module_Student({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:Text(module,
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/home_student");
            },
            icon: const Icon(Icons.arrow_back, size: 30, color: Colors.white),
          ),
        ],
        backgroundColor: Colors.purple[800],
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
