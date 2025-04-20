import 'package:flutter/material.dart';
import 'package:hear_learn1/componente/teacher_side/cour.dart';
import 'package:hear_learn1/componente/teacher_side/td.dart';
import 'package:hear_learn1/componente/teacher_side/tp.dart';

class Contnue_Module_Teacher extends StatelessWidget {
  const Contnue_Module_Teacher({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure the arguments exist before casting
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    final String module = args is String ? args : "Unknown Module";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          module, // Using the received module name
          style: const TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/home_techer");
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
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.people,
                color: Colors.black,
              ),
              label: const Text(
                "messages",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
