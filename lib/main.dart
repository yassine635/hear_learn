import 'package:flutter/material.dart';
import 'package:hear_learn1/screanses/Home_student.dart';
import 'package:hear_learn1/screanses/contnue_module.dart';

void main() {
  
  runApp(const hearlern());
}

class hearlern extends StatelessWidget {
  const hearlern({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/contnu_module": (context) => ContnueModule(),
        "/home": (context) => Home(),
      },
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
