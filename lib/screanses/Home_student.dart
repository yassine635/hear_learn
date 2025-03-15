import 'package:flutter/material.dart';
import 'package:hear_learn1/componente/module.dart';


class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      appBar: AppBar(
        title: const Text("student Page",
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {
             
            },
            icon: const Icon(Icons.arrow_back, size: 30, color: Colors.white),
          ),
        ],
        backgroundColor: Colors.lightGreen[800],
      ),
      body: Module(),
    );
  }
}
