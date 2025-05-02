import 'package:flutter/material.dart';

class Deposer extends StatelessWidget {
  final VoidCallback onpressed; // better type than just Function

  const Deposer({
    super.key,
    required this.onpressed, // marked as required
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onpressed,
      icon: const Icon(Icons.add, color: Colors.black),
      label: const Text(
        "اضف",
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
        ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 51, 200, 93),
        foregroundColor: Colors.black,
        textStyle: const TextStyle(fontSize: 18),
      ),
    );
  }
}
