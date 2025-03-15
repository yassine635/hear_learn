import 'package:flutter/material.dart';
import 'package:hear_learn1/componente/cour.dart';
import 'package:hear_learn1/componente/td.dart';
import 'package:hear_learn1/componente/tp.dart';

class ContnueModule extends StatelessWidget {
  const ContnueModule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      appBar: AppBar(
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
                 "/home"
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
