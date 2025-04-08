import 'package:flutter/material.dart';
import 'package:hear_learn1/componente/student_side/module.dart';
import 'package:hear_learn1/data/listyears.dart';

//import 'package:hear_learn1/screanses/teacher_dashboard.dart';

class Home_student extends StatelessWidget {
  const Home_student({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("student Page",
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/fonctionalite_screen");
            },
            icon: const Icon(Icons.arrow_back, size: 30, color: Colors.white),
          ),
        ],
        backgroundColor: Colors.lightGreen[800],
      ),
      body: ListView.builder(
        itemCount: Listyears.L3_S1.length,
        itemBuilder: (context, index) {
          return Module(module: Listyears.L3_S1[index]);
        },
      ),
    );
  }
}
