import 'package:flutter/material.dart';
import 'package:hear_learn1/componente/teacher_side/module.dart';
import 'package:hear_learn1/data/listyears.dart';




class Home_Teacher extends StatelessWidget {
  const Home_Teacher({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("teacher Page",
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
