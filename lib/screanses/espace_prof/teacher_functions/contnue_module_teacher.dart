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
    
    return Container(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            module, 
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back, size: 30, color: Colors.white),
            ),
          ],
          backgroundColor: Colors.purple[800],
        ),
        body: Column(
          children: [
            Cour(onpressed:() {
              Navigator.pushNamed(context, "/teacher_option", arguments: ["cour",module],);
            },),
            Td(onpressed:() {
              Navigator.pushNamed(context, "/teacher_option", arguments: ["TD",module]);
            },),
            Tp(onpressed:() {
              Navigator.pushNamed(context, "/teacher_option", arguments: ["TP",module]);
            },),
           
          ],
        ),
      ),
    );
  }
}
