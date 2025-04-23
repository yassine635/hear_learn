import 'package:flutter/material.dart';

class Deposer extends StatelessWidget {
  final VoidCallback onpressed; // better type than just Function

  const Deposer({
    Key? key,
    required this.onpressed, // marked as required
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onpressed,
      icon: const Icon(Icons.add, color: Colors.black),
      label: const Text("OPTIONS"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple[800],
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 18),
      ),
    );
  }
}
